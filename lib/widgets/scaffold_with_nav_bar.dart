import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/theme.dart';

/// 5 sekmeli alt navigasyon çubuğu.
/// Ortadaki Rehber butonu öne çıkan, gradient ve glow'lu özel tasarım.
/// Her sekme kendi navigasyon yığınını korur (StatefulShellRoute).
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        height: 80 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: tokens.glassStroke, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                index: 0,
                currentIndex: current,
                icon: PhosphorIcons.house(PhosphorIconsStyle.light),
                activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'Ana Sayfa',
                onTap: () => _onTap(context, 0),
                tokens: tokens,
              ),
              _NavItem(
                index: 1,
                currentIndex: current,
                icon: PhosphorIcons.notebook(PhosphorIconsStyle.light),
                activeIcon: PhosphorIcons.notebook(PhosphorIconsStyle.fill),
                label: 'Günlük',
                onTap: () => _onTap(context, 1),
                tokens: tokens,
              ),
              // ─── Merkez Rehber butonu ─────────────────────────────────────
              _CenterGuideButton(
                isActive: current == 2,
                onTap: () => _onTap(context, 2),
                tokens: tokens,
              ),
              _NavItem(
                index: 3,
                currentIndex: current,
                icon: PhosphorIcons.compassRose(PhosphorIconsStyle.light),
                activeIcon: PhosphorIcons.compassRose(PhosphorIconsStyle.fill),
                label: 'Keşfet',
                onTap: () => _onTap(context, 3),
                tokens: tokens,
              ),
              _NavItem(
                index: 4,
                currentIndex: current,
                icon: PhosphorIcons.user(PhosphorIconsStyle.light),
                activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                label: 'Profil',
                onTap: () => _onTap(context, 4),
                tokens: tokens,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    required this.tokens,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final CosmicTokens tokens;

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: isActive,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color:
                      isActive ? tokens.accentPrimary : tokens.onSurfaceMuted,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color:
                      isActive ? tokens.accentPrimary : tokens.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ortadaki öne çıkan Rehber butonu — gradient, glow, büyük
class _CenterGuideButton extends StatelessWidget {
  const _CenterGuideButton({
    required this.isActive,
    required this.onTap,
    required this.tokens,
  });

  final bool isActive;
  final VoidCallback onTap;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rehber, yapay zekâ mesajları',
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: SizedBox(
          width: 64,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: tokens.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tokens.accentPrimary
                          .withValues(alpha: isActive ? 0.5 : 0.25),
                      blurRadius: isActive ? 20 : 12,
                      spreadRadius: isActive ? 3 : 1,
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
