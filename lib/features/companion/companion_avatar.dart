import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/theme.dart';
import 'companion_profile.dart';

/// A compact, token-driven symbolic animal portrait. The illustration remains
/// honest about the fact that the finished 3D animal assets are still pending.
class CompanionAvatar extends StatelessWidget {
  const CompanionAvatar({
    super.key,
    required this.profile,
    required this.tokens,
    this.size = 112,
    this.glow = true,
  });

  final CompanionProfile profile;
  final CosmicTokens tokens;
  final double size;
  final bool glow;

  Color get _coat => switch (profile.coat) {
        'İnci' => tokens.onSurfaceSubtle,
        'Gümüş' => tokens.onSurfaceMuted,
        'Ametist' => tokens.accentSecondary,
        _ => tokens.accentPrimary,
      };

  Color get _eye => switch (profile.eyeColor) {
        'İnci' => tokens.onSurface,
        'Gümüş' => tokens.onSurfaceSubtle,
        'Turkuaz' => tokens.successColor,
        _ => tokens.accentSecondary,
      };

  IconData get _animalIcon {
    final animal = profile.species.toLowerCase();
    if (animal.contains('kelebek')) return PhosphorIcons.butterfly();
    if (animal.contains('at')) return PhosphorIcons.horse();
    if (animal.contains('yunus')) return PhosphorIcons.fish();
    if (animal.contains('baykuş')) return PhosphorIcons.eye();
    if (animal.contains('kuzgun') || animal.contains('şahin')) {
      return PhosphorIcons.bird();
    }
    if (animal.contains('yılan')) return PhosphorIcons.scribbleLoop();
    if (animal.contains('kaplumbağa')) return PhosphorIcons.shield();
    if (animal.contains('kedi')) return PhosphorIcons.cat();
    if (animal.contains('ayı')) return PhosphorIcons.pawPrint();
    if (animal.contains('aslan')) return PhosphorIcons.sun();
    if (animal.contains('kuğu')) return PhosphorIcons.feather();
    if (animal.contains('keçi')) return PhosphorIcons.mountains();
    return PhosphorIcons.pawPrint();
  }

  @override
  Widget build(BuildContext context) {
    final equipped = profile.equippedItems.values.toSet();
    final cosmetics = companionCosmetics
        .where((item) => equipped.contains(item.id))
        .toList(growable: false);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size * .82,
            height: size * .82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: tokens.primaryGradient,
              boxShadow: glow
                  ? [
                      BoxShadow(
                          color: _coat.withValues(alpha: .24),
                          blurRadius: size * .2)
                    ]
                  : null,
              border: Border.all(color: tokens.glassStroke, width: 1.5),
            ),
            child: Icon(_animalIcon, size: size * .43, color: _eye),
          ),
          for (final item in cosmetics)
            Positioned(
              top: switch (item.slot) {
                'şapka' => size * .01,
                'aura' => -size * .03,
                _ => null
              },
              bottom: switch (item.slot) {
                'kolye' || 'atkı' => size * .1,
                _ => null
              },
              right: switch (item.slot) {
                'gözlük' => size * .24,
                'pelerin' => -size * .02,
                _ => null
              },
              child: Icon(
                _cosmeticIcon(item.id),
                size: size * .19,
                color: tokens.onSurface,
                shadows: [Shadow(color: tokens.background, blurRadius: 5)],
              ),
            ),
        ],
      ),
    );
  }

  IconData _cosmeticIcon(String id) => switch (id) {
        'hilal-kolye' => PhosphorIcons.moonStars(PhosphorIconsStyle.fill),
        'aurora-pelerini' ||
        'gece-pelerini' =>
          PhosphorIcons.tShirt(PhosphorIconsStyle.fill),
        'kozmik-taç' => PhosphorIcons.crown(PhosphorIconsStyle.fill),
        'ay-kanatlari' => PhosphorIcons.feather(PhosphorIconsStyle.fill),
        'yildiz-halesi' ||
        'kozmos-isiltisi' =>
          PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
        _ => PhosphorIcons.star(PhosphorIconsStyle.fill),
      };
}
