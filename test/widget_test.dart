import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruhun_parliyor/app.dart';
import 'package:ruhun_parliyor/core/entitlement/entitlement.dart';
import 'package:ruhun_parliyor/data/db/app_database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // In-memory database for tests
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const RuhunParliyorApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    // Uygulama çökmeden açılıyor
    expect(find.byType(MaterialApp), findsOneWidget);

    await db.close();
  });
}
