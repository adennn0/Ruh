import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/theme.dart';
import '../../core/router/app_router.dart';
import '../../widgets/cosmic_widgets.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Rehber', style: AppTextStyles.title(tokens)),
        actions: [
          // Zil simgesi → Bildirim ayarları (Bölüm 8, 11)
          IconButton(
            icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.light)),
            tooltip: 'Bildirim ayarları',
            onPressed: () => context.push(AppRoutes.notificationSettings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Geliştirme modu bandı (Aşama 6'ya kadar gösterilir)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: tokens.accentSecondary.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.info(PhosphorIconsStyle.fill),
                  color: tokens.accentSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Geliştirme modu: örnek yanıtlar gösteriliyor',
                    style: AppTextStyles.caption(tokens).copyWith(
                      color: tokens.accentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: EmptyStateWidget(
              title: 'Rehber',
              subtitle:
                  'Aşama 3\'te AI sohbeti (mock) ve günlük mesajlar burada görünecek.',
              icon: Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.light),
                color: tokens.accentPrimary,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
