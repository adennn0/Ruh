import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(title: Text('Günlük', style: AppTextStyles.title(tokens))),
      body: const EmptyStateWidget(
        title: 'Günlük',
        subtitle:
            'Aşama 3\'te bugün, niyetler, yazılar ve favoriler burada görünecek.',
      ),
    );
  }
}
