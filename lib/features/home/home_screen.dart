import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

/// Ana Sayfa iskelet (Aşama 3'te içerikle dolacak)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'Ruhun Parlıyor',
          style: AppTextStyles.title(tokens),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Bildirimler',
            onPressed: () {},
          ),
        ],
      ),
      body: const EmptyStateWidget(
        title: 'Ana Sayfa',
        subtitle:
            'Aşama 3\'te günlük içerik, mesajlar ve ritüeller burada görünecek.',
      ),
    );
  }
}
