import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/data/db/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('multiple user check-ins in a day are kept as a timeline', () async {
    final table = database.dailyEnergyEntryTable;
    final morning = DateTime(2026, 10, 11, 9);
    final evening = DateTime(2026, 10, 11, 21);
    await database.into(table).insert(
          DailyEnergyEntryTableCompanion.insert(
            localDate: '2026-10-11',
            energy: 2,
            mood: 'Durgun',
            focus: 3,
            updatedAt: Value(morning),
          ),
        );
    await database.into(table).insert(
          DailyEnergyEntryTableCompanion.insert(
            localDate: '2026-10-11',
            energy: 4,
            mood: 'İyi',
            focus: 5,
            updatedAt: Value(evening),
          ),
        );

    final entries = await database.select(table).get();
    expect(entries, hasLength(2));
    expect(entries.first.energy, 2);
    expect(entries.last.energy, 4);
    expect(entries.last.mood, 'İyi');
    expect(entries.last.focus, 5);
    expect(entries.last.updatedAt, evening);
  });

  test('time moment intention can be edited and deleted', () async {
    final table = database.timeMomentTable;
    final id = await database.into(table).insert(
          TimeMomentTableCompanion.insert(
            date: '2026-10-11',
            timeLabel: '11:11',
            intentionText: const Value('İlk niyet'),
          ),
        );
    await (database.update(table)..where((row) => row.id.equals(id))).write(
      const TimeMomentTableCompanion(intentionText: Value('Düzenlenen niyet')),
    );
    expect((await database.select(table).get()).single.intentionText,
        'Düzenlenen niyet');
    expect((await database.select(table).get()).single.timeLabel, '11:11');
    expect((await database.select(table).get()).single.date, '2026-10-11');
    await (database.delete(table)..where((row) => row.id.equals(id))).go();
    expect(await database.select(table).get(), isEmpty);
  });
}
