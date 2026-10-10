import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserProfileTable,
  DailyContentTable,
  IntentionTable,
  JournalEntryTable,
  TimeMomentTable,
  FavoriteTable,
  SavedPersonTable,
  ReminderSettingTable,
  StreakDayTable,
  RestDayUseTable,
  BadgeTable,
  CatProfileTable,
  CatItemUnlockTable,
  ChatMessageTable,
  AppSettingsTable,
  EntitlementCacheTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // İlk açılışta AppSettings kaydı oluştur
          await into(appSettingsTable).insertOnConflictUpdate(
            AppSettingsTableCompanion.insert(),
          );
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Gelecek sürümlerde buraya migrasyon adımları eklenir
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ruhun_parliyor.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ─── Provider ────────────────────────────────────────────────────────────────
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
