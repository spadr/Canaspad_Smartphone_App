-- 拡張機能の有効化
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "http";

-- テーブルの作成

-- センサーテーブル
CREATE TABLE SENSOR (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_name TEXT NOT NULL,
  name TEXT NOT NULL,
  sensor_type TEXT NOT NULL,
  anomaly_detection_method TEXT, -- 異常検知方法 (例: moving_average, etc.)
  anomaly_detection_params JSONB, -- 異常検知パラメータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  UNIQUE (group_name, name)
);

-- 数値センサーテーブル
CREATE TABLE NUMERIC_SENSOR (
  id UUID PRIMARY KEY REFERENCES SENSOR(id) ON DELETE CASCADE,
  unit TEXT NOT NULL
);

-- 画像センサーテーブル
CREATE TABLE IMAGE_SENSOR (
  id UUID PRIMARY KEY REFERENCES SENSOR(id) ON DELETE CASCADE,
  resolution TEXT NOT NULL
);

-- データテーブル
CREATE TABLE BASE_DATA (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sensor_id UUID NOT NULL REFERENCES SENSOR(id) ON DELETE CASCADE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid()
);

-- 数値データテーブル
CREATE TABLE NUMERIC_DATA (
  id UUID PRIMARY KEY REFERENCES BASE_DATA(id) ON DELETE CASCADE,
  value NUMERIC NOT NULL
);

-- 画像データテーブル
CREATE TABLE IMAGE_DATA (
  id UUID PRIMARY KEY REFERENCES BASE_DATA(id) ON DELETE CASCADE,
  file_path TEXT NOT NULL
);

-- 監視条件テーブル
CREATE TABLE monitoring_conditions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sensor_id UUID NOT NULL REFERENCES SENSOR(id) ON DELETE CASCADE,
  condition_type TEXT NOT NULL, -- 条件の種類 (例: threshold, range, etc.)
  parameters JSONB NOT NULL, -- 条件のパラメータ
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE, -- 有効かどうか
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid()
);

-- 通知テーブル
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sensor_id UUID NOT NULL REFERENCES SENSOR(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- 例: error, warning, info
  status TEXT NOT NULL DEFAULT 'unread', -- 例: unread, read
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- インデックスの作成
CREATE INDEX idx_sensor_group_name ON SENSOR(group_name);
CREATE INDEX idx_sensor_name ON SENSOR(name);
CREATE INDEX idx_sensor_type ON SENSOR(sensor_type);
CREATE INDEX idx_base_data_sensor_id ON BASE_DATA(sensor_id);
CREATE INDEX idx_base_data_timestamp ON BASE_DATA(timestamp);
CREATE INDEX idx_numeric_data_value ON NUMERIC_DATA(value);
CREATE INDEX idx_image_data_file_path ON IMAGE_DATA(file_path);

-- 統合された RESTful API 関数の作成

-- センサー操作のための RESTful 関数
CREATE OR REPLACE FUNCTION api_sensors_post(payload JSONB)
RETURNS JSONB AS $$
DECLARE
  new_sensor_id UUID;
  v_group_name TEXT;
  v_name TEXT;
  v_sensor_type TEXT;
  v_anomaly_detection_method TEXT;
  v_anomaly_detection_params JSONB;
  v_additional_info JSONB;
BEGIN
  -- 権限チェック
  IF NOT auth.role() = 'authenticated' THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- ペイロードからデータを抽出
  v_group_name := payload->>'group_name';
  v_name := payload->>'name';
  v_sensor_type := payload->>'sensor_type';
  v_anomaly_detection_method := payload->>'anomaly_detection_method';
  v_anomaly_detection_params := payload->'anomaly_detection_params';
  v_additional_info := payload->'additional_info';

  -- 入力値の検証
  IF v_group_name IS NULL OR v_name IS NULL OR v_sensor_type IS NULL THEN
    RAISE EXCEPTION 'Invalid input parameters';
  END IF;

  -- トランザクション開始
  BEGIN
    -- SENSORテーブルに挿入
    INSERT INTO SENSOR (group_name, name, sensor_type, anomaly_detection_method, anomaly_detection_params)
    VALUES (v_group_name, v_name, v_sensor_type, v_anomaly_detection_method, v_anomaly_detection_params)
    RETURNING id INTO new_sensor_id;

    -- センサータイプに応じて追加情報を挿入
    CASE v_sensor_type
      WHEN 'numeric' THEN
        INSERT INTO NUMERIC_SENSOR (id, unit)
        VALUES (new_sensor_id, v_additional_info->>'unit');
      WHEN 'image' THEN
        INSERT INTO IMAGE_SENSOR (id, resolution)
        VALUES (new_sensor_id, v_additional_info->>'resolution');
      ELSE
        RAISE EXCEPTION 'Unsupported sensor type: %', v_sensor_type;
    END CASE;

    -- 新しく作成されたセンサーの情報を返す
    RETURN jsonb_build_object(
      'id', new_sensor_id,
      'group_name', v_group_name,
      'name', v_name,
      'sensor_type', v_sensor_type,
      'anomaly_detection_method', v_anomaly_detection_method,
      'anomaly_detection_params', v_anomaly_detection_params,
      'additional_info', v_additional_info
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 数値データ操作のための RESTful 関数
CREATE OR REPLACE FUNCTION api_numeric_data_post(payload JSONB)
RETURNS JSONB AS $$
DECLARE
  new_data_id UUID;
  v_sensor_id UUID;
  v_value NUMERIC;
  v_timestamp TIMESTAMP WITH TIME ZONE;
BEGIN
  -- 権限チェック
  IF NOT auth.role() = 'authenticated' THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- ペイロードからデータを抽出
  v_sensor_id := (payload->>'sensor_id')::UUID;
  v_value := (payload->>'value')::NUMERIC;
  v_timestamp := COALESCE((payload->>'timestamp')::TIMESTAMP WITH TIME ZONE, now());

  -- 入力値の検証
  IF v_sensor_id IS NULL OR v_value IS NULL THEN
    RAISE EXCEPTION 'Invalid input parameters';
  END IF;

  -- トランザクション開始
  BEGIN
    -- センサーの存在と型の確認
    IF NOT EXISTS (SELECT 1 FROM SENSOR WHERE id = v_sensor_id AND sensor_type = 'numeric') THEN
      RAISE EXCEPTION 'Invalid sensor ID or sensor type is not numeric';
    END IF;

    -- BASE_DATAテーブルに挿入
    INSERT INTO BASE_DATA (sensor_id, timestamp)
    VALUES (v_sensor_id, v_timestamp)
    RETURNING id INTO new_data_id;

    -- NUMERIC_DATAテーブルに挿入
    INSERT INTO NUMERIC_DATA (id, value)
    VALUES (new_data_id, v_value);

    RETURN jsonb_build_object(
      'id', new_data_id,
      'sensor_id', v_sensor_id,
      'value', v_value,
      'timestamp', v_timestamp
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 画像データ操作のための RESTful 関数
CREATE OR REPLACE FUNCTION api_image_data_post(payload JSONB)
RETURNS JSONB AS $$
DECLARE
  v_data_id UUID;
  v_sensor_id UUID;
  v_file_name TEXT;
  v_file_type TEXT;
  v_file_size INT;
  v_timestamp TIMESTAMP WITH TIME ZONE;
  v_path TEXT;
  v_bucket TEXT := 'sensor-images';
  v_signed_url TEXT;
  v_expires_in INT := 3600;
BEGIN
  -- 権限チェック
  IF NOT auth.role() = 'authenticated' THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- ペイロードからデータを抽出
  v_sensor_id := (payload->>'sensor_id')::UUID;
  v_file_name := payload->>'file_name';
  v_file_type := payload->>'file_type';
  v_file_size := (payload->>'file_size')::INT;
  v_timestamp := COALESCE((payload->>'timestamp')::TIMESTAMP WITH TIME ZONE, now());

  -- 入力値の検証
  IF v_sensor_id IS NULL OR v_file_name IS NULL OR v_file_type IS NULL OR v_file_size IS NULL THEN
    RAISE EXCEPTION 'Invalid input parameters';
  END IF;

  -- センサーの存在確認
  IF NOT EXISTS (SELECT 1 FROM SENSOR WHERE id = v_sensor_id AND sensor_type = 'image') THEN
    RAISE EXCEPTION 'Invalid sensor ID or sensor type';
  END IF;

  -- ファイルサイズの制限チェック（例：10MB）
  IF v_file_size > 10 * 1024 * 1024 THEN
    RAISE EXCEPTION 'File size exceeds the limit';
  END IF;

  -- ファイルタイプの制限チェック
  IF v_file_type NOT IN ('image/jpeg', 'image/png', 'image/gif') THEN
    RAISE EXCEPTION 'Unsupported file type';
  END IF;

  -- トランザクション開始
  BEGIN
    -- 画像の保存パスを生成
    v_path := 'uploads/' || to_char(v_timestamp, 'YYYY/MM/DD') || '/' || v_file_name;

    -- 署名付きURLを生成
    v_signed_url := storage.create_signed_url(
      v_bucket,
      v_path,
      v_expires_in
    );

    -- BASE_DATAテーブルに挿入
    INSERT INTO BASE_DATA (sensor_id, timestamp)
    VALUES (v_sensor_id, v_timestamp)
    RETURNING id INTO v_data_id;

    -- IMAGE_DATAテーブルに挿入
    INSERT INTO IMAGE_DATA (id, file_path)
    VALUES (v_data_id, v_path);

    -- 必要な情報を返す
    RETURN jsonb_build_object(
      'data_id', v_data_id,
      'sensor_id', v_sensor_id,
      'path', v_path,
      'signed_url', v_signed_url,
      'expires_in', v_expires_in,
      'timestamp', v_timestamp
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- セキュリティ設定

-- Row Level Security (RLS) を有効化
ALTER TABLE SENSOR ENABLE ROW LEVEL SECURITY;
ALTER TABLE NUMERIC_SENSOR ENABLE ROW LEVEL SECURITY;
ALTER TABLE IMAGE_SENSOR ENABLE ROW LEVEL SECURITY;
ALTER TABLE BASE_DATA ENABLE ROW LEVEL SECURITY;
ALTER TABLE NUMERIC_DATA ENABLE ROW LEVEL SECURITY;
ALTER TABLE IMAGE_DATA ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_conditions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ポリシーの作成
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON SENSOR FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ挿入可能" ON SENSOR FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "作成者のみ更新可能" ON SENSOR FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "作成者のみ削除可能" ON SENSOR FOR DELETE USING (auth.uid() = created_by);

-- 他のテーブルにも同様のポリシーを適用
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON NUMERIC_SENSOR FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON IMAGE_SENSOR FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON BASE_DATA FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON NUMERIC_DATA FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON IMAGE_DATA FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON monitoring_conditions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "認証済みユーザーのみ読み取り可能" ON notifications FOR SELECT USING (auth.role() = 'authenticated');

-- 関数の実行権限を設定
REVOKE ALL ON FUNCTION api_sensors_post(JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_sensors_post(JSONB) TO authenticated;

REVOKE ALL ON FUNCTION api_numeric_data_post(JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_numeric_data_post(JSONB) TO authenticated;

REVOKE ALL ON FUNCTION api_image_data_post(JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api_image_data_post(JSONB) TO authenticated;

-- トリガー関数

CREATE OR REPLACE FUNCTION notify_sensor_data_change()
RETURNS TRIGGER AS $$
DECLARE
  v_sensor_id UUID;
  v_latest_data RECORD;
  v_anomaly_detection_method TEXT;
  v_anomaly_detection_params JSONB;
  v_response JSONB;
BEGIN
  -- 変更されたデータのセンサーIDを取得
  v_sensor_id := NEW.sensor_id;

  -- 最新のセンサーデータを取得
  SELECT * INTO v_latest_data
  FROM BASE_DATA bd
  LEFT JOIN NUMERIC_DATA nd ON bd.id = nd.id
  WHERE bd.sensor_id = v_sensor_id
  ORDER BY bd.timestamp DESC
  LIMIT 1;

  -- センサーに関連付けられた異常検知方法とパラメータを取得
  SELECT 
    anomaly_detection_method,
    anomaly_detection_params
  INTO 
    v_anomaly_detection_method, 
    v_anomaly_detection_params
  FROM SENSOR
  WHERE id = v_sensor_id;

  -- Supabase Functions を呼び出し
  v_response := pg_http.post(
    'https://[your-project-ref].supabase.co/functions/v1/detect-anomaly',
    json_build_object(
      'sensor_id', v_sensor_id,
      'value', v_latest_data.value,
      'timestamp', v_latest_data.timestamp,
      'method', v_anomaly_detection_method,
      'params', v_anomaly_detection_params
    )::text,
    'Authorization', 'Bearer ' || auth.token()
  );

  -- Functions からの戻り値を処理
  IF (v_response->>'isAnomaly')::boolean THEN
    INSERT INTO notifications (sensor_id, user_id, title, message, type, status)
    VALUES (
      v_sensor_id,
      v_latest_data.created_by,  -- データの作成者を通知先に設定
      'Sensor Anomaly Detected',
      format('Sensor %s showed an anomaly (score: %s).', v_sensor_id, v_response->>'anomalyScore'),
      'warning',
      'unread'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- NUMERIC_DATA テーブルにトリガーを設定
CREATE TRIGGER numeric_data_change_trigger
AFTER INSERT OR UPDATE ON NUMERIC_DATA
FOR EACH ROW EXECUTE PROCEDURE notify_sensor_data_change();

-- IMAGE_DATA テーブルにトリガーを設定
CREATE TRIGGER image_data_change_trigger
AFTER INSERT OR UPDATE ON IMAGE_DATA
FOR EACH ROW EXECUTE PROCEDURE notify_sensor_data_change();

-- センサーデータを取得する関数（ページネーション付き）
CREATE OR REPLACE FUNCTION get_sensor_data(
  p_sensor_id UUID,
  p_limit INT DEFAULT 100,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  sensor_id UUID,
  "data_timestamp" TIMESTAMP WITH TIME ZONE,
  value NUMERIC,
  file_path TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    bd.id,
    bd.sensor_id,
    bd.timestamp AS "data_timestamp", 
    nd.value,
    id.file_path
  FROM
    BASE_DATA bd
    LEFT JOIN NUMERIC_DATA nd ON bd.id = nd.id
    LEFT JOIN IMAGE_DATA id ON bd.id = id.id
  WHERE
    bd.sensor_id = p_sensor_id
  ORDER BY
    bd.timestamp DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- 関数の実行権限を設定
REVOKE ALL ON FUNCTION get_sensor_data(UUID, INT, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_sensor_data(UUID, INT, INT) TO authenticated;