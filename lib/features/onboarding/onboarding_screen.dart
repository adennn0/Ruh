import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_controller.dart';
import 'consent_screen.dart';
import 'birth_info_screen.dart';
import 'cosmic_identity_screen.dart';
import 'tone_selection_screen.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/user_profile_repository.dart';

/// Onboarding ana kabuk — 4 adım arasında geçiş koordinasyonu.
/// Her adım kendi widget'ında; bu widget PageView ile geçiş sağlar.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    // Onboarding tamamlandıysa Ana Sayfa'ya yönlendir
    ref.listen<OnboardingState>(onboardingControllerProvider, (_, next) {
      if (next.currentStep == 4) {
        // userProfileProvider'ı yenile
        ref.invalidate(userProfileRepositoryProvider);
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: tokens.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        child: _pageForStep(state.currentStep),
      ),
    );
  }

  Widget _pageForStep(int step) {
    return switch (step) {
      0 => const ConsentScreen(key: ValueKey(0)),
      1 => const BirthInfoScreen(key: ValueKey(1)),
      2 => const CosmicIdentityScreen(key: ValueKey(2)),
      3 => const ToneSelectionScreen(key: ValueKey(3)),
      _ => const SizedBox.shrink(key: ValueKey(99)),
    };
  }
}
