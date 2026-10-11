import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/core/entitlement/entitlement.dart';
import 'package:ruhun_parliyor/core/theme/app_themes.dart';
import 'package:ruhun_parliyor/features/premium/premium_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows transparent store placeholder and honest restore result',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppThemes.getTheme(AppThemeId.amethystAurora),
          home: const PremiumScreen(),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Satın alma şu an kullanılamıyor'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Satın alma şu an kullanılamıyor'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Satın alımları geri yükle'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Satın alımları geri yükle'));
    await tester.pump();
    expect(
      find.text(
          'Mağaza bağlantısı henüz yapılandırılmadı; satın alım aranmadı.'),
      findsOneWidget,
    );
  });
}
