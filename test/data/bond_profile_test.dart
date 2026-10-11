import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/data/db/app_database.dart';
import 'package:ruhun_parliyor/data/repositories/bond_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('bond notes and shared moments persist locally and cascade on removal',
      () async {
    final bondId = await database.into(database.bondProfileTable).insert(
          BondProfileTableCompanion.insert(
            name: 'Yakınım',
            relationCategory: 'Arkadaş',
            intention: const Value('Daha açık iletişim'),
            privateNote: const Value('Özel not'),
          ),
        );
    await database.into(database.bondMomentTable).insert(
          BondMomentTableCompanion.insert(
            bondId: bondId,
            title: 'Birlikte yürüyüş',
            occurredOn: '2026-10-11',
          ),
        );

    final profile =
        (await database.select(database.bondProfileTable).get()).single;
    final moment =
        (await database.select(database.bondMomentTable).get()).single;
    expect(profile.intention, 'Daha açık iletişim');
    expect(profile.privateNote, 'Özel not');
    expect(moment.bondId, bondId);

    await deleteBondProfile(database, bondId);
    expect(await database.select(database.bondMomentTable).get(), isEmpty);
  });
}
