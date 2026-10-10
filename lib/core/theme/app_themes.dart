import 'package:flutter/material.dart';
import 'cosmic_tokens.dart';
import 'text_styles.dart';

/// 5 temanın tanımlandığı merkezi dosya.
/// Tüm temalar ThemeData + CosmicTokens extension olarak gelir.
/// Premium temalar da burada tanımlı; erişim EntitlementService ile kısıtlanır.
enum AppThemeId {
  amethystAurora, // Koyu - Ücretsiz (varsayılan)
  pearlMoon, // Açık - Ücretsiz
  cyberNebula, // Koyu - Premium
  roseQuartzAurora, // Koyu - Premium
  oceanMoon, // Koyu - Premium
}

extension AppThemeIdExt on AppThemeId {
  String get id => name;
  bool get isPremium =>
      this == AppThemeId.cyberNebula ||
      this == AppThemeId.roseQuartzAurora ||
      this == AppThemeId.oceanMoon;
  String get displayName => switch (this) {
        AppThemeId.amethystAurora => 'Amethyst Aurora',
        AppThemeId.pearlMoon => 'Pearl Moon',
        AppThemeId.cyberNebula => 'Cyber Nebula',
        AppThemeId.roseQuartzAurora => 'Rose Quartz Aurora',
        AppThemeId.oceanMoon => 'Ocean Moon',
      };
  String get description => switch (this) {
        AppThemeId.amethystAurora => 'Koyu, mor-pembe aurora',
        AppThemeId.pearlMoon => 'Açık, inci beyazı',
        AppThemeId.cyberNebula => 'Futuristik, elektrik neon',
        AppThemeId.roseQuartzAurora => 'Koyu, gül kuvarsı tonları',
        AppThemeId.oceanMoon => 'Koyu, okyanus mavisi',
      };
}

class AppThemes {
  AppThemes._();

  static ThemeData getTheme(AppThemeId id) => switch (id) {
        AppThemeId.amethystAurora => _amethystAurora,
        AppThemeId.pearlMoon => _pearlMoon,
        AppThemeId.cyberNebula => _cyberNebula,
        AppThemeId.roseQuartzAurora => _roseQuartzAurora,
        AppThemeId.oceanMoon => _oceanMoon,
      };

  static CosmicTokens getTokens(AppThemeId id) => switch (id) {
        AppThemeId.amethystAurora => _amethystTokens,
        AppThemeId.pearlMoon => _pearlTokens,
        AppThemeId.cyberNebula => _cyberTokens,
        AppThemeId.roseQuartzAurora => _roseTokens,
        AppThemeId.oceanMoon => _oceanTokens,
      };

  // ─── AMETHYST AURORA (varsayılan koyu) ───────────────────────────────────
  static const _amethystTokens = CosmicTokens(
    background: Color(0xFF0B0615),
    surface: Color(0xFF1A0B2E),
    surfaceElevated: Color(0xFF221040),
    primaryGradientStart: Color(0xFF6A00FF),
    primaryGradientMid: Color(0xFF9D00FF),
    primaryGradientEnd: Color(0xFFFF2DAA),
    accentPrimary: Color(0xFF8B5CFF),
    accentSecondary: Color(0xFFFF2DAA),
    accentTertiary: Color(0xFFFF4DCE),
    onBackground: Color(0xFFFAF8FF),
    onSurface: Color(0xFFEAE6FF),
    onSurfaceSubtle: Color(0xFFCFC7E8),
    onSurfaceMuted: Color(0xFF7B7097),
    heroBg: Color(0xFF0D0720),
    glassOverlay: Color(0x1AFFFFFF),
    glassStroke: Color(0x338B5CFF),
    premiumBadge: Color(0xFFFFB3F1),
    errorColor: Color(0xFFFF6B6B),
    successColor: Color(0xFF6BFFB3),
    isDark: true,
  );

  static final _amethystAurora = _buildDarkTheme(_amethystTokens);

  // ─── PEARL MOON (açık) ───────────────────────────────────────────────────
  static const _pearlTokens = CosmicTokens(
    background: Color(0xFFFAF8FF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0ECFF),
    primaryGradientStart: Color(0xFF6A00FF),
    primaryGradientMid: Color(0xFF9D00FF),
    primaryGradientEnd: Color(0xFFFF2DAA),
    accentPrimary: Color(0xFF6A00FF),
    accentSecondary: Color(0xFFFF2DAA),
    accentTertiary: Color(0xFFFF4DCE),
    onBackground: Color(0xFF1A0B2E),
    onSurface: Color(0xFF2D1A4E),
    onSurfaceSubtle: Color(0xFF5A4A7A),
    onSurfaceMuted: Color(0xFFAA99CC),
    heroBg: Color(0xFFEAE6FF),
    glassOverlay: Color(0x0A6A00FF),
    glassStroke: Color(0x336A00FF),
    premiumBadge: Color(0xFF8B5CFF),
    errorColor: Color(0xFFCC2222),
    successColor: Color(0xFF227744),
    isDark: false,
  );

  static final _pearlMoon = _buildLightTheme(_pearlTokens);

  // ─── CYBER NEBULA (premium koyu) ─────────────────────────────────────────
  static const _cyberTokens = CosmicTokens(
    background: Color(0xFF05030D),
    surface: Color(0xFF0E0A1F),
    surfaceElevated: Color(0xFF151030),
    primaryGradientStart: Color(0xFF3DF5FF),
    primaryGradientMid: Color(0xFF7B5CFF),
    primaryGradientEnd: Color(0xFFFF2DAA),
    accentPrimary: Color(0xFF3DF5FF),
    accentSecondary: Color(0xFF7B5CFF),
    accentTertiary: Color(0xFFFF2DAA),
    onBackground: Color(0xFFE9F7FF),
    onSurface: Color(0xFFCCEEFF),
    onSurfaceSubtle: Color(0xFF88AACC),
    onSurfaceMuted: Color(0xFF446688),
    heroBg: Color(0xFF080515),
    glassOverlay: Color(0x1A3DF5FF),
    glassStroke: Color(0x553DF5FF),
    premiumBadge: Color(0xFF3DF5FF),
    errorColor: Color(0xFFFF6B6B),
    successColor: Color(0xFF3DF5FF),
    isDark: true,
  );

  static final _cyberNebula = _buildDarkTheme(_cyberTokens);

  // ─── ROSE QUARTZ AURORA (premium koyu) ───────────────────────────────────
  static const _roseTokens = CosmicTokens(
    background: Color(0xFF12060F),
    surface: Color(0xFF1F0B1A),
    surfaceElevated: Color(0xFF2A1225),
    primaryGradientStart: Color(0xFFFF4DCE),
    primaryGradientMid: Color(0xFFDB7FFF),
    primaryGradientEnd: Color(0xFFFFB3F1),
    accentPrimary: Color(0xFFFF4DCE),
    accentSecondary: Color(0xFFC77DFF),
    accentTertiary: Color(0xFFFFB3F1),
    onBackground: Color(0xFFFFF0FA),
    onSurface: Color(0xFFFFDDF5),
    onSurfaceSubtle: Color(0xFFCCAACF),
    onSurfaceMuted: Color(0xFF886680),
    heroBg: Color(0xFF0E0310),
    glassOverlay: Color(0x1AFF4DCE),
    glassStroke: Color(0x55FF4DCE),
    premiumBadge: Color(0xFFFFB3F1),
    errorColor: Color(0xFFFF6B6B),
    successColor: Color(0xFF88FFCC),
    isDark: true,
  );

  static final _roseQuartzAurora = _buildDarkTheme(_roseTokens);

  // ─── OCEAN MOON (premium koyu) ───────────────────────────────────────────
  static const _oceanTokens = CosmicTokens(
    background: Color(0xFF050A1A),
    surface: Color(0xFF0B1530),
    surfaceElevated: Color(0xFF121E3C),
    primaryGradientStart: Color(0xFF5B8CFF),
    primaryGradientMid: Color(0xFF8B5CFF),
    primaryGradientEnd: Color(0xFF52E0D0),
    accentPrimary: Color(0xFF5B8CFF),
    accentSecondary: Color(0xFF8B5CFF),
    accentTertiary: Color(0xFF52E0D0),
    onBackground: Color(0xFFEEF4FF),
    onSurface: Color(0xFFCCDDFF),
    onSurfaceSubtle: Color(0xFF8899BB),
    onSurfaceMuted: Color(0xFF445577),
    heroBg: Color(0xFF030815),
    glassOverlay: Color(0x1A5B8CFF),
    glassStroke: Color(0x555B8CFF),
    premiumBadge: Color(0xFF52E0D0),
    errorColor: Color(0xFFFF6B6B),
    successColor: Color(0xFF52E0D0),
    isDark: true,
  );

  static final _oceanMoon = _buildDarkTheme(_oceanTokens);

  // ─── Builder'lar ─────────────────────────────────────────────────────────
  static ThemeData _buildDarkTheme(CosmicTokens tokens) {
    final colorScheme = ColorScheme.dark(
      primary: tokens.accentPrimary,
      secondary: tokens.accentSecondary,
      tertiary: tokens.accentTertiary,
      surface: tokens.surface,
      error: tokens.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: tokens.onSurface,
      onError: Colors.white,
    );
    return _baseTheme(colorScheme, tokens);
  }

  static ThemeData _buildLightTheme(CosmicTokens tokens) {
    final colorScheme = ColorScheme.light(
      primary: tokens.accentPrimary,
      secondary: tokens.accentSecondary,
      tertiary: tokens.accentTertiary,
      surface: tokens.surface,
      error: tokens.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: tokens.onSurface,
      onError: Colors.white,
    );
    return _baseTheme(colorScheme, tokens);
  }

  static ThemeData _baseTheme(ColorScheme colorScheme, CosmicTokens tokens) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      textTheme: AppTextStyles.textTheme(tokens),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title(tokens),
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.glassStroke,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: tokens.onSurface, size: 24),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: tokens.accentPrimary,
        unselectedItemColor: tokens.onSurfaceMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.glassStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.glassStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: tokens.onSurfaceSubtle),
        hintStyle: TextStyle(color: tokens.onSurfaceMuted),
        errorStyle: TextStyle(color: tokens.errorColor, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.surfaceElevated,
        contentTextStyle: TextStyle(color: tokens.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTextStyles.h2(tokens),
        contentTextStyle: AppTextStyles.body(tokens),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surface,
        selectedColor: tokens.accentPrimary.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: tokens.onSurface, fontSize: 13),
        side: BorderSide(color: tokens.glassStroke),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
