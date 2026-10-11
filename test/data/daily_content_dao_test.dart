import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/data/db/app_database.dart';
import 'package:ruhun_parliyor/data/db/daos/daily_content_dao.dart';

void main() {
  late AppDatabase database;
  late DailyContentDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DailyContentDao(database);
  });
  tearDown(() => database.close());

  test('daily content replaces by local date and retains only one row',
      () async {
    Future<void> save(String message, {int refreshCount = 0}) => dao.upsert(
          DailyContentTableCompanion.insert(
            localDate: '2026-10-11',
            message: message,
            affirmation: 'Küçük adımlar atabilirim.',
            contentKey: Value(message),
            regenCount: Value(refreshCount),
          ),
        );

    await save('İlk mesaj');
    await save('Yeni mesaj', refreshCount: 1);

    final rows = await database.select(database.dailyContentTable).get();
    expect(rows, hasLength(1));
    expect(rows.single.message, 'Yeni mesaj');
    expect(rows.single.regenCount, 1);
    expect(await dao.recentContentKeys(7), ['Yeni mesaj']);
  });
}
