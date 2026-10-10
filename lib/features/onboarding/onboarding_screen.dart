import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      body: const EmptyStateWidget(
        title: 'Hoş Geldin',
        subtitle:
            'Aşama 2\'de rıza ekranı ve 3 onboarding adımı burada görünecek.',
      ),
    );
  }
}
