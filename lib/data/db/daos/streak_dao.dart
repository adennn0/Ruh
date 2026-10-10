import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'streak_dao.g.dart';

@DriftAccessor(tables: [StreakDayTable, RestDayUseTable, BadgeTable])
class StreakDao extends DatabaseAccessor<AppDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  // ── Streak Days ──────────────────────────────────────────────────────────────

  Future<StreakDayTableData?> dayRecord(String localDate) =>
      (select(streakDayTable)..where((t) => t.localDate.equals(localDate)))
          .getSingleOrNull();

  Future<void> markActivity(String localDate, int activityBit) async {
    final existing = await dayRecord(localDate);
    if (existing == null) {
      await into(streakDayTable).insert(
        StreakDayTableCompanion(
          localDate: Value(localDate),
          activityMask: Value(activityBit),
        ),
      );
    } else {
      await (update(streakDayTable)
            ..where((t) => t.localDate.equals(localDate)))
          .write(
        StreakDayTableCompanion(
          activityMask: Value(existing.activityMask | activityBit),
        ),
      );
    }
  }

  Future<List<StreakDayTableData>> allDays() =>
      (select(streakDayTable)..orderBy([(t) => OrderingTerm.desc(t.localDate)]))
          .get();

  // ── Rest Days ────────────────────────────────────────────────────────────────

  Future<RestDayUseTableData?> restDayForWeek(String weekStartDate) =>
      (select(restDayUseTable)
            ..where((t) => t.weekStartDate.equals(weekStartDate)))
          .getSingleOrNull();

  Future<void> useRestDay(String weekStartDate, String usedOn) =>
      into(restDayUseTable).insertOnConflictUpdate(
        RestDayUseTableCompanion(
          weekStartDate: Value(weekStartDate),
          usedOn: Value(usedOn),
        ),
      );

  // ── Badges ───────────────────────────────────────────────────────────────────

  Stream<List<BadgeTableData>> watchBadges() => select(badgeTable).watch();

  Future<bool> hasBadge(String badgeId) async {
    final row = await (select(badgeTable)
          ..where((t) => t.badgeId.equals(badgeId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> awardBadge(String badgeId) =>
      into(badgeTable).insertOnConflictUpdate(
        BadgeTableCompanion(
          badgeId: Value(badgeId),
          earnedAt: Value(DateTime.now()),
        ),
      );
}
