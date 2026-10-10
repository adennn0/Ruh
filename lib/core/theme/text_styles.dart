import 'package:flutter/material.dart';
import 'cosmic_tokens.dart';

/// Uygulama geneli tipografi sistemi.
/// Ölçek: display 32/28 · h1 24 · h2 20 · title 17 · body 15–16 · caption 13 · label 12
/// Başlık: Fraunces (serif) · Gövde/UI: Manrope
/// Türkçe karakterler (ı İ ş Ş ğ Ğ ü Ü ö Ö ç Ç) gömülü fontlarla desteklenir.
class AppTextStyles {
  AppTextStyles._();

  static const _serifFamily = 'Fraunces';
  static const _sansFamily = 'Manrope';

  // ─── TextTheme ────────────────────────────────────────────────────────────
  static TextTheme textTheme(CosmicTokens tokens) {
    return TextTheme(
      displayLarge: display(tokens),
      displayMedium: displayMedium(tokens),
      headlineLarge: h1(tokens),
      headlineMedium: h2(tokens),
      titleLarge: title(tokens),
      titleMedium: titleSmall(tokens),
      bodyLarge: bodyLarge(tokens),
      bodyMedium: body(tokens),
      bodySmall: caption(tokens),
      labelLarge: labelLarge(tokens),
      labelMedium: label(tokens),
      labelSmall: labelSmall(tokens),
    );
  }

  // ─── Bireysel stil metodları ──────────────────────────────────────────────
  static TextStyle display(CosmicTokens tokens) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(CosmicTokens tokens) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle h1(CosmicTokens tokens) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle h2(CosmicTokens tokens) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: tokens.onBackground,
        height: 1.3,
      );

  static TextStyle title(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.35,
      );

  static TextStyle titleSmall(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: tokens.onSurface,
        height: 1.4,
      );

  static TextStyle bodyLarge(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: tokens.onSurface,
        height: 1.55,
      );

  static TextStyle body(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 15, // min 15sp — spec zorunluluğu
        fontWeight: FontWeight.w400,
        color: tokens.onSurface,
        height: 1.55,
      );

  static TextStyle caption(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: tokens.onSurfaceSubtle,
        height: 1.45,
      );

  static TextStyle label(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tokens.onSurfaceSubtle,
        height: 1.4,
        letterSpacing: 0.3,
      );

  static TextStyle labelLarge(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle labelSmall(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: tokens.onSurfaceMuted,
        height: 1.4,
        letterSpacing: 0.5,
      );

  /// Kısa uppercase etiket (üst başlık)
  static TextStyle overline(CosmicTokens tokens) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: tokens.onSurfaceSubtle,
        height: 1.3,
        letterSpacing: 1.2,
      );

  /// Buton metni (her zaman beyaz — gradient buton üzerinde)
  static TextStyle button(CosmicTokens tokens) => const TextStyle(
        fontFamily: _sansFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        height: 1.2,
        letterSpacing: 0.2,
      );

  /// Hero/spiritüel başlık (serif, büyük)
  static TextStyle heroTitle(CosmicTokens tokens) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: tokens.onBackground,
        height: 1.25,
        letterSpacing: -0.3,
        fontStyle: FontStyle.italic,
      );
}
