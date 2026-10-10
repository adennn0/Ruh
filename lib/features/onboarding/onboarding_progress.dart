import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Üst ilerleme çubuğu — 3 onboarding adımı için
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep, // 1-indexed (1, 2, 3)
    required this.totalSteps,
    required this.tokens,
  });

  final int currentStep;
  final int totalSteps;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: isActive ? tokens.primaryGradient : null,
                  color: isActive
                      ? null
                      : tokens.onSurfaceMuted.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
