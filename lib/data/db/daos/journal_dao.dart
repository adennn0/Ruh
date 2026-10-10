import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntryTable])
class JournalDao extends DatabaseAccessor<AppDatabase>
    with _$JournalDaoMixin {
  JournalDao(super.db);

  Stream<List<JournalEntryTableData>> watchAll() =>
      (select(journalEntryTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<JournalEntryTableData>> watchByType(String type) =>
      (select(journalEntryTable)
            ..where((t) => t.type.equals(type))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<JournalEntryTableData>> forDate(String localDate) =>
      (select(journalEntryTable)
            ..where((t) => t.entryDate.equals(localDate)))
          .get();

  Future<int> countByType(String type) async {
    final count = journalEntryTable.id.count();
    final q = selectOnly(journalEntryTable)
      ..addColumns([count])
      ..where(journalEntryTable.type.equals(type));
    return (await q.getSingle()).read(count) ?? 0;
  }

  Future<JournalEntryTableData?> getById(int id) =>
      (select(journalEntryTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertEntry(JournalEntryTableCompanion companion) =>
      into(journalEntryTable).insert(companion);

  Future<bool> updateEntry(JournalEntryTableCompanion companion) =>
      (update(journalEntryTable)
            ..where((t) => t.id.equals(companion.id.value)))
          .write(companion)
          .then((count) => count > 0);

  Future<int> deleteEntry(int id) =>
      (delete(journalEntryTable)..where((t) => t.id.equals(id))).go();
}
