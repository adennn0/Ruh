import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(title: Text('Profil', style: AppTextStyles.title(tokens))),
      body: const EmptyStateWidget(
        title: 'Profil',
        subtitle:
            'Aşama 3\'te tüm ayarlar, tema seçimi ve kişisel bilgiler burada görünecek.',
      ),
    );
  }
}
