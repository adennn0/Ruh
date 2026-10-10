import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'saved_person_dao.g.dart';

@DriftAccessor(tables: [SavedPersonTable])
class SavedPersonDao extends DatabaseAccessor<AppDatabase> with _$SavedPersonDaoMixin {
  SavedPersonDao(super.db);

  Stream<List<SavedPersonTableData>> watchAll() {
    return select(savedPersonTable).watch();
  }

  Future<int> insertPerson(SavedPersonTableCompanion companion) {
    return into(savedPersonTable).insert(companion);
  }

  Future<bool> updatePerson(SavedPersonTableCompanion companion) {
    return update(savedPersonTable).replace(companion);
  }

  Future<int> deletePerson(int id) {
    return (delete(savedPersonTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countAll() async {
    final countExp = savedPersonTable.id.count();
    final query = selectOnly(savedPersonTable)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
