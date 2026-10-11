import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'daily_content_dao.g.dart';

@DriftAccessor(tables: [DailyContentTable])
class DailyContentDao extends DatabaseAccessor<AppDatabase>
    with _$DailyContentDaoMixin {
  DailyContentDao(super.db);

  Future<DailyContentTableData?> forDate(String localDate) =>
      (select(dailyContentTable)..where((t) => t.localDate.equals(localDate)))
          .getSingleOrNull();

  Future<int> upsert(DailyContentTableCompanion companion) async {
    final localDate = companion.localDate.value;
    return transaction(() async {
      await (delete(dailyContentTable)
            ..where((row) => row.localDate.equals(localDate)))
          .go();
      return into(dailyContentTable).insert(companion);
    });
  }

  Future<void> incrementRegenCount(String localDate) async {
    await (update(dailyContentTable)
          ..where((t) => t.localDate.equals(localDate)))
        .write(
      DailyContentTableCompanion(
        regenCount: Value(
          ((await forDate(localDate))?.regenCount ?? 0) + 1,
        ),
      ),
    );
  }

  // Son N günün contentKey'leri (tekrar önleme için)
  Future<List<String>> recentContentKeys(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    final rows = await (select(dailyContentTable)
          ..where((t) => t.localDate.isBiggerOrEqualValue(cutoffStr))
          ..where((t) => t.contentKey.isNotNull()))
        .get();
    return rows
        .map((r) => r.contentKey ?? '')
        .where((k) => k.isNotEmpty)
        .toList();
  }
}
