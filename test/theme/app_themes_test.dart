import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/core/theme/theme.dart';

void main() {
  test('every theme has resolvable tokens, theme data and Turkish labels', () {
    for (final id in AppThemeId.values) {
      expect(
          AppThemes.getTheme(id).extensions[CosmicTokens], isA<CosmicTokens>());
      expect(AppThemes.getTokens(id).background, isNotNull);
      expect(id.description, isNotEmpty);
    }
  });

  test('requested six palettes exist and Sade remains free', () {
    expect(AppThemeId.pearlMoon.displayName, 'Sade');
    expect(AppThemeId.nature.displayName, 'Doğa');
    expect(AppThemeId.cyberNebula.displayName, 'Uzay');
    expect(AppThemeId.sand.displayName, 'Kum');
    expect(AppThemeId.oceanMoon.displayName, 'Deniz');
    expect(AppThemeId.fire.displayName, 'Ateş');
    expect(AppThemeId.pearlMoon.isPremium, isFalse);
    for (final id in [
      AppThemeId.nature,
      AppThemeId.cyberNebula,
      AppThemeId.sand,
      AppThemeId.oceanMoon,
      AppThemeId.fire
    ]) {
      expect(id.isPremium, isTrue);
    }
  });

  test('new profiles use the calm, high-contrast Sade palette by default', () {
    final tokens = AppThemes.getTokens(AppThemeId.pearlMoon);
    expect(tokens.background.toARGB32(), 0xFFFCFAFF);
    expect(tokens.onBackground.toARGB32(), 0xFF281F30);
    expect(tokens.accentPrimary.toARGB32(), 0xFF665277);
    expect(AppThemeId.pearlMoon.isPremium, isFalse);
  });
}
