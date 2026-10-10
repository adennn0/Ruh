import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../db/app_database.dart';
import '../db/daos/saved_person_dao.dart';

class SavedPerson {
  final int id;
  final String nickname;
  final DateTime birthDate;

  SavedPerson({
    required this.id,
    required this.nickname,
    required this.birthDate,
  });

  factory SavedPerson.fromRow(SavedPersonTableData row) {
    return SavedPerson(
      id: row.id,
      nickname: row.nickname,
      birthDate: row.birthDate,
    );
  }
}

class SavedPersonRepository {
  final SavedPersonDao _dao;
  final EntitlementService _entitlement;

  SavedPersonRepository(this._dao, this._entitlement);

  Future<({bool success, String? error})> addPerson(
      String nickname, DateTime birthDate) async {
    final count = await _dao.countAll();
    final limit = _entitlement.limitFor(AppFeature.savedPersons);

    if (limit != -1 && count >= limit) {
      return (success: false, error: 'Ücretsiz sürümde en fazla $limit kişi kaydedebilirsiniz.');
    }

    try {
      await _dao.insertPerson(SavedPersonTableCompanion.insert(
        nickname: nickname,
        birthDate: birthDate,
      ));
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: 'Kayıt sırasında bir hata oluştu.');
    }
  }

  Stream<List<SavedPerson>> watchAll() {
    return _dao.watchAll().map((list) => list.map((e) => SavedPerson.fromRow(e)).toList());
  }

  Future<void> deletePerson(int id) async {
    await _dao.deletePerson(id);
  }
}

final savedPersonRepositoryProvider = Provider<SavedPersonRepository>((ref) {
  return SavedPersonRepository(
    ref.watch(savedPersonDaoProvider),
    ref.watch(entitlementServiceProvider),
  );
});
