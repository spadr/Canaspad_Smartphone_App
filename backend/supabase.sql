-- SENSORテーブルの作成
CREATE TABLE SENSOR (
    id UUID PRIMARY KEY,
    public_id UUID UNIQUE,
    "group" TEXT,
    name TEXT,
    data_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    UNIQUE ("group", name)
);

-- DATAテーブルの作成
CREATE TABLE DATA (
    id UUID PRIMARY KEY,
    sensor_id UUID REFERENCES SENSOR(id) ON DELETE CASCADE,
    public_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    value NUMERIC,
    file_path TEXT,
    created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    CONSTRAINT chk_value_or_file_path CHECK (
        (value IS NULL AND file_path IS NOT NULL) OR
        (value IS NOT NULL AND file_path IS NULL)
    )
);

-- 両方のテーブルにRow Level Securityを有効化
ALTER TABLE SENSOR ENABLE ROW LEVEL SECURITY;
ALTER TABLE DATA ENABLE ROW LEVEL SECURITY;

-- SENSORテーブルのポリシー
-- 認証済みユーザーに読み取りアクセスを許可
create policy "認証済みユーザーの読み取りアクセスを許可" on SENSOR for
select
  using (auth.role () = 'authenticated');

-- 認証済みユーザーに挿入を許可
create policy "認証済みユーザーの挿入を許可" on SENSOR for insert
with
  check (auth.role () = 'authenticated');

-- 認証済みユーザーに更新を許可（自身のレコードのみ）
create policy "認証済みユーザーの更新を許可" on SENSOR
for update
  using (auth.uid () = created_by)
with
  check (auth.role () = 'authenticated');

-- 認証済みユーザーに削除を許可（自身のレコードのみ）
create policy "認証済みユーザーの削除を許可" on SENSOR for delete using (auth.uid () = created_by);

-- DATAテーブルのポリシー
-- 認証済みユーザーに読み取りアクセスを許可
create policy "認証済みユーザーの読み取りアクセスを許可" on data for
select
  using (auth.role () = 'authenticated');

-- 認証済みユーザーに挿入を許可
create policy "認証済みユーザーの挿入を許可" on data for insert
with
  check (auth.role () = 'authenticated');

-- 認証済みユーザーに更新を許可（自身のレコードのみ）
create policy "認証済みユーザーの更新を許可" on data
for update
  using (auth.uid () = created_by)
with
  check (auth.role () = 'authenticated');

-- 認証済みユーザーに削除を許可（自身のレコードのみ）
create policy "認証済みユーザーの削除を許可" on data for delete using (auth.uid () = created_by);