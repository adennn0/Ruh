import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'daos/intention_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/streak_dao.dart';
import 'daos/daily_content_dao.dart';
import 'daos/favorites_dao.dart';
import 'daos/saved_person_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfileTable,
    DailyContentTable,
    IntentionTable,
    JournalEntryTable,
    TimeMomentTable,
    DailyEnergyEntryTable,
    BondProfileTable,
    BondMomentTable,
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
  ],
  daos: [
    IntentionDao,
    JournalDao,
    StreakDao,
    DailyContentDao,
    FavoritesDao,
    SavedPersonDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Varsayılan AppSettings satırı ekle
          await into(appSettingsTable).insert(
            const AppSettingsTableCompanion(),
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dailyEnergyEntryTable);
          }
          if (from < 3) {
            await m.createTable(bondProfileTable);
            await m.createTable(bondMomentTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ruhun_parliyor.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}

/// Riverpod provider — main.dart'ta overrideWithValue ile başlatılır
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main()');
});

/// DAO providers (kolaylık için)
final intentionDaoProvider = Provider<IntentionDao>((ref) {
  return ref.watch(appDatabaseProvider).intentionDao;
});

final journalDaoProvider = Provider<JournalDao>((ref) {
  return ref.watch(appDatabaseProvider).journalDao;
});

final streakDaoProvider = Provider<StreakDao>((ref) {
  return ref.watch(appDatabaseProvider).streakDao;
});

final dailyContentDaoProvider = Provider<DailyContentDao>((ref) {
  return ref.watch(appDatabaseProvider).dailyContentDao;
});

final favoritesDaoProvider = Provider<FavoritesDao>((ref) {
  return ref.watch(appDatabaseProvider).favoritesDao;
});

final favoritesProvider = StreamProvider<List<FavoriteTableData>>((ref) {
  return ref.watch(favoritesDaoProvider).watchAll();
});

final favoriteStatusProvider =
    Provider.family<AsyncValue<bool>, ({String contentType, String contentId})>(
        (ref, key) {
  return ref.watch(favoritesProvider).whenData((favorites) => favorites.any(
        (item) =>
            item.contentType == key.contentType &&
            item.contentId == key.contentId,
      ));
});

final savedPersonDaoProvider = Provider<SavedPersonDao>((ref) {
  return ref.watch(appDatabaseProvider).savedPersonDao;
});
