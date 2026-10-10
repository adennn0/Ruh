import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'intention_dao.g.dart';

@DriftAccessor(tables: [IntentionTable])
class IntentionDao extends DatabaseAccessor<AppDatabase>
    with _$IntentionDaoMixin {
  IntentionDao(super.db);

  Stream<List<IntentionTableData>> watchActive() =>
      (select(intentionTable)
            ..where((t) => t.status.equals('active'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<IntentionTableData>> watchCompleted() =>
      (select(intentionTable)
            ..where((t) => t.status.equals('completed'))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();

  Stream<List<IntentionTableData>> watchArchived() =>
      (select(intentionTable)
            ..where((t) => t.status.equals('archived'))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  Future<int> countActive() async {
    final count = intentionTable.id.count();
    final query = selectOnly(intentionTable)
      ..addColumns([count])
      ..where(intentionTable.status.equals('active'));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<IntentionTableData?> getById(int id) =>
      (select(intentionTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertIntention(IntentionTableCompanion companion) =>
      into(intentionTable).insert(companion);

  Future<bool> updateIntention(IntentionTableCompanion companion) =>
      (update(intentionTable)..where((t) => t.id.equals(companion.id.value)))
          .write(companion)
          .then((count) => count > 0);

  Future<void> setStatus(int id, String status) async {
    final now = DateTime.now();
    await (update(intentionTable)..where((t) => t.id.equals(id))).write(
      IntentionTableCompanion(
        status: Value(status),
        updatedAt: Value(now),
        completedAt: status == 'completed' ? Value(now) : const Value.absent(),
      ),
    );
  }

  Future<int> deleteIntention(int id) =>
      (delete(intentionTable)..where((t) => t.id.equals(id))).go();
}
