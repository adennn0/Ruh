import 'package:flutter/material.dart';

/// Tema sisteminin kalbi. Tüm renk, gradient, yüzey ve glow
/// tokenları buradan gelir. Widget'larda sabit renk kullanılmaz.
@immutable
class CosmicTokens extends ThemeExtension<CosmicTokens> {
  const CosmicTokens({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primaryGradientStart,
    required this.primaryGradientMid,
    required this.primaryGradientEnd,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentTertiary,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceSubtle,
    required this.onSurfaceMuted,
    required this.heroBg,
    required this.glassOverlay,
    required this.glassStroke,
    required this.premiumBadge,
    required this.errorColor,
    required this.successColor,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;

  // Primary gradient (CTA, hero, seçim vurgusu)
  final Color primaryGradientStart;
  final Color primaryGradientMid;
  final Color primaryGradientEnd;

  // Aksan renkler
  final Color accentPrimary; // ana renk (mor/elektrik vb)
  final Color accentSecondary; // ikincil (magenta/turkuaz vb)
  final Color accentTertiary; // üçüncül (pembe/lavanta vb)

  // Metin
  final Color onBackground; // birincil metin
  final Color onSurface; // yüzey üzeri metin
  final Color onSurfaceSubtle; // ikincil metin
  final Color onSurfaceMuted; // devre dışı / placeholder

  // Hero / özel alanlar
  final Color heroBg;
  final Color glassOverlay;
  final Color glassStroke;
  final Color premiumBadge;

  // Durum renkleri
  final Color errorColor;
  final Color successColor;

  final bool isDark;

  /// Birincil gradient
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryGradientStart, primaryGradientMid, primaryGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Yüzey gradient (hafif)
  LinearGradient get surfaceGradient => LinearGradient(
        colors: [surface, surfaceElevated],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Glow efekti için box shadow
  List<BoxShadow> primaryGlow({double radius = 24, double opacity = 0.35}) => [
        BoxShadow(
          color: accentPrimary.withValues(alpha: opacity),
          blurRadius: radius,
          spreadRadius: radius * 0.15,
        ),
      ];

  @override
  CosmicTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primaryGradientStart,
    Color? primaryGradientMid,
    Color? primaryGradientEnd,
    Color? accentPrimary,
    Color? accentSecondary,
    Color? accentTertiary,
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceSubtle,
    Color? onSurfaceMuted,
    Color? heroBg,
    Color? glassOverlay,
    Color? glassStroke,
    Color? premiumBadge,
    Color? errorColor,
    Color? successColor,
    bool? isDark,
  }) {
    return CosmicTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientMid: primaryGradientMid ?? this.primaryGradientMid,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentTertiary: accentTertiary ?? this.accentTertiary,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceSubtle: onSurfaceSubtle ?? this.onSurfaceSubtle,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      heroBg: heroBg ?? this.heroBg,
      glassOverlay: glassOverlay ?? this.glassOverlay,
      glassStroke: glassStroke ?? this.glassStroke,
      premiumBadge: premiumBadge ?? this.premiumBadge,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ThemeExtension<CosmicTokens> lerp(
    ThemeExtension<CosmicTokens>? other,
    double t,
  ) {
    if (other is! CosmicTokens) return this;
    return CosmicTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      primaryGradientStart:
          Color.lerp(primaryGradientStart, other.primaryGradientStart, t)!,
      primaryGradientMid:
          Color.lerp(primaryGradientMid, other.primaryGradientMid, t)!,
      primaryGradientEnd:
          Color.lerp(primaryGradientEnd, other.primaryGradientEnd, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentTertiary: Color.lerp(accentTertiary, other.accentTertiary, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceSubtle: Color.lerp(onSurfaceSubtle, other.onSurfaceSubtle, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      heroBg: Color.lerp(heroBg, other.heroBg, t)!,
      glassOverlay: Color.lerp(glassOverlay, other.glassOverlay, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
      premiumBadge: Color.lerp(premiumBadge, other.premiumBadge, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
