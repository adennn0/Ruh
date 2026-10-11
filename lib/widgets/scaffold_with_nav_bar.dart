import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/preferences/app_preferences.dart';
import '../core/theme/theme.dart';

/// Five predictable destinations with equal width and native Material behavior.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _labels = ['Ana', 'Günlük', 'Rehber', 'Keşfet', 'Profil'];

  static const _icons = [
    Icons.home_outlined,
    Icons.auto_stories_outlined,
    Icons.forum_outlined,
    Icons.explore_outlined,
    Icons.person_outline,
  ];

  static const _selectedIcons = [
    Icons.home_rounded,
    Icons.auto_stories_rounded,
    Icons.forum_rounded,
    Icons.explore_rounded,
    Icons.person_rounded,
  ];

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    if (ref.read(hapticsEnabledProvider)) HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final destinations = List.generate(
      _labels.length,
      (index) => NavigationDestination(
        icon: Icon(_icons[index]),
        selectedIcon: Icon(_selectedIcons[index]),
        label: _labels[index],
        tooltip: _labels[index],
      ),
    );

    return Scaffold(
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(top: BorderSide(color: tokens.glassStroke)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, ref, index),
            destinations: destinations,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 80,
            backgroundColor: tokens.surface,
            indicatorColor: tokens.heroBg,
            surfaceTintColor: tokens.surface,
            elevation: 0,
            overlayColor: WidgetStatePropertyAll(
              tokens.accentPrimary.withValues(alpha: .08),
            ),
          ),
        ),
      ),
    );
  }
}
