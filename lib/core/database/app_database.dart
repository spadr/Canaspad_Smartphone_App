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
  TextColumn get unit => text()();
}

class ImageSensors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get resolution => text()();
}

class SensorData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  TextColumn get sensorPublicId => text().references(Sensors, #publicId)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get createdByUserId => text().nullable()(); // UUIDをテキストとして保存
}

class NumericData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
  RealColumn get value => real()();
}

class ImageData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get publicId => text().unique()();
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
  AppDatabase(QueryExecutor e) : super(e); // コンストラクタを修正

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

  // データベース操作メソッドをここに追加
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// flutter pub run build_runner build --delete-conflicting-outputs