import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Bildirim Ayarları', style: AppTextStyles.title(tokens)),
      ),
      body: const EmptyStateWidget(
        title: 'Bildirim Ayarları',
        subtitle:
            'Aşama 3\'te tüm bildirim türleri ve saatleri burada ayarlanacak.',
      ),
    );
  }
}
