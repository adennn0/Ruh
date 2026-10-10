import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(title: Text('Keşfet', style: AppTextStyles.title(tokens))),
      body: const EmptyStateWidget(
        title: 'Keşfet',
        subtitle:
            'Aşama 4\'te uyumluluk, doğal taş, ruh hayvanı ve ay takvimi burada görünecek.',
      ),
    );
  }
}
