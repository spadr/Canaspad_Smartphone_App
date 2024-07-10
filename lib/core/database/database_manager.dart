// lib/core/database/database_manager.dart

import 'package:drift/drift.dart';

import 'app_database.dart';

class DatabaseManager {
  final LazyDatabase _lazyDatabase;

  DatabaseManager(this._lazyDatabase);

  AppDatabase? _database;

  Future<AppDatabase> get database async {
    _database ??= await AppDatabase(_lazyDatabase); // _lazyDatabase を渡す
    return _database!;
  }

  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }
}
