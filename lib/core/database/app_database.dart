// lib/core/database/app_database.dart

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// Supabaseのテーブル構造をDriftで再現

class Sensors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  TextColumn get groupName => text()();
  TextColumn get name => text()();
  TextColumn get sensorType => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get createdBy => text().nullable()(); // UUIDをテキストとして保存
}

class NumericSensors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  TextColumn get unit => text()();
}

class ImageSensors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  TextColumn get resolution => text()();
}

class SensorData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  TextColumn get sensorPublicId => text().references(Sensors, #publicId)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get createdByUserId => text().nullable()(); // UUIDをテキストとして保存
}

class NumericData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  RealColumn get value => real()();
}

class ImageData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get environmentId => text()();
  TextColumn get filePath => text()();
  BlobColumn get image => blob().nullable()(); // image カラムを追加
}

// 同期用のメタデータテーブル
class SyncMetadata extends Table {
  @override
  String? get tableName => 'sync_metadata'; // String? を返すように修正

  TextColumn get table => text().unique()(); // カラム名を変更
  DateTimeColumn get lastSyncedAt => dateTime()();
  TextColumn get lastSyncedId => text().nullable()(); // 最後に同期したレコードのID
}

// オフライン操作を追跡するテーブル
class OfflineOperations extends Table {
  @override
  String? get tableName => 'offline_operations'; // String? を返すように修正

  IntColumn get id => integer().autoIncrement()();
  TextColumn get table => text()();
  TextColumn get operation => text()();
  TextColumn get recordId => text()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [Sensors, NumericSensors, ImageSensors, SensorData, NumericData, ImageData, SyncMetadata, OfflineOperations],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // マイグレーションロジックをここに追加
      },
    );
  }

  Future<DateTime> getLastSyncTime(String tableName) async {
    final result = await (select(syncMetadata)..where((tbl) => tbl.table.equals(tableName))).getSingleOrNull();
    return result?.lastSyncedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> updateLastSyncTime(String tableName, DateTime syncTime) async {
    await into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        table: tableName,
        lastSyncedAt: syncTime,
      ),
    );
  }

  Future<void> upsertSensor(Map<String, dynamic> sensorData) async {
    final sensor = SensorsCompanion.insert(
      publicId: sensorData['id'],
      groupName: sensorData['group_name'],
      name: sensorData['name'],
      sensorType: sensorData['sensor_type'],
      createdAt: DateTime.parse(sensorData['created_at']),
      updatedAt: DateTime.parse(sensorData['updated_at']),
      createdBy: Value(sensorData['created_by']),
    );
    await into(sensors).insertOnConflictUpdate(sensor);
  }

  Future<void> insertSensorData(Map<String, dynamic> sensorData) async {
    final data = SensorDataCompanion.insert(
      publicId: sensorData['id'],
      sensorPublicId: sensorData['sensor_id'],
      timestamp: DateTime.parse(sensorData['created_at']),
      createdByUserId: Value(sensorData['created_by']),
    );
    await into(this.sensorData).insert(data);

    if (sensorData['value'] != null) {
      final numericData = NumericDataCompanion.insert(
        publicId: sensorData['id'],
        value: sensorData['value'],
      );
      await into(this.numericData).insert(numericData);
    } else if (sensorData['file_path'] != null) {
      final imageData = ImageDataCompanion.insert(
        publicId: sensorData['id'],
        filePath: sensorData['file_path'],
      );
      await into(this.imageData).insert(imageData);
    }
  }

  Future<void> upsertNumericData(Map<String, dynamic> numericData) async {
    final data = NumericDataCompanion.insert(
      publicId: numericData['id'],
      value: numericData['value'],
    );

    await into(this.numericData).insertOnConflictUpdate(data);

    // SensorData テーブルも更新
    final sensorData = SensorDataCompanion.insert(
      publicId: numericData['id'],
      sensorPublicId: numericData['sensor_id'],
      timestamp: DateTime.parse(numericData['created_at']),
      createdByUserId: Value(numericData['created_by']),
    );
    await into(this.sensorData).insertOnConflictUpdate(sensorData);
  }

  Future<void> upsertImageData(Map<String, dynamic> imageData) async {
    final data = ImageDataCompanion.insert(
      publicId: imageData['id'],
      filePath: imageData['file_path'],
      image: Value(imageData['local_file_path'] != null ? File(imageData['local_file_path']).readAsBytesSync() : null),
    );

    await into(this.imageData).insertOnConflictUpdate(data);

    // SensorData テーブルも更新
    final sensorData = SensorDataCompanion.insert(
      publicId: imageData['id'],
      sensorPublicId: imageData['sensor_id'],
      timestamp: DateTime.parse(imageData['created_at']),
      createdByUserId: Value(imageData['created_by']),
    );
    await into(this.sensorData).insertOnConflictUpdate(sensorData);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// AppDatabase クラスに以下のメソッドを追加
extension AppDatabaseExtension on AppDatabase {
  Future<void> updateSyncMetadata(SyncMetadataCompanion companion) async {
    await into(syncMetadata).insertOnConflictUpdate(companion);
  }
}

// flutter pub run build_runner build --delete-conflicting-outputs