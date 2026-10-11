import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final service = ref.watch(entitlementServiceProvider);
    final isPremium = service.isPremium;
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        title:
            Text('Ruhun Parlıyor Premium', style: AppTextStyles.title(tokens)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          CosmicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumBadge(),
                const SizedBox(height: 14),
                Text(
                  isPremium
                      ? 'Premium erişimin açık'
                      : 'Daha derin bir alan, kendi ritminde',
                  style: AppTextStyles.h2(tokens),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ücretsiz özelliklerin ve kendi kayıtların erişilebilir kalır. Premium, ek içerik ve daha geniş kullanım sunar.',
                  style: AppTextStyles.body(tokens),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Premium ile açılanlar', style: AppTextStyles.title(tokens)),
          const SizedBox(height: 12),
          for (final feature in _features)
            _FeatureRow(feature: feature, tokens: tokens),
          const SizedBox(height: 20),
          _LimitCard(tokens: tokens),
          const SizedBox(height: 20),
          if (!isPremium) ...[
            FilledButton.icon(
              onPressed: null,
              icon: Icon(PhosphorIcons.storefront()),
              label: const Text('Satın alma şu an kullanılamıyor'),
            ),
            const SizedBox(height: 8),
            Text(
              'Mağaza ürünleri bu uygulama için henüz yapılandırılmadı. Fiyat, deneme süresi ve yenileme koşulları mağazadan alınamadığı için satın alma başlatılamaz.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(tokens),
            ),
          ] else
            Text(
              service.debugPremiumEnabled
                  ? 'Premium durumu geliştirme anahtarıyla etkin. Bu bir mağaza satın alımı değildir.'
                  : 'Premium erişimi bu cihazda etkin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(tokens),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showRestoreStatus(context),
            icon: Icon(PhosphorIcons.arrowCounterClockwise()),
            label: const Text('Satın alımları geri yükle'),
          ),
          const SizedBox(height: 10),
          Text(
            'Geri yükleme, mağaza bağlantısı yapılandırıldığında kullanılabilir. Şu anda hesap veya satın alma bilgisi gönderilmez.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(tokens),
          ),
        ],
      ),
    );
  }

  void _showRestoreStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Mağaza bağlantısı henüz yapılandırılmadı; satın alım aranmadı.'),
      ),
    );
  }
}

const _features = [
  ('Daha geniş Saat Anı seçkisi', 'Günlük bildirim kotası 5’ten 12’ye çıkar.'),
  (
    'Daha fazla niyet',
    'Aktif niyet sınırı kalkar; mevcut niyetlerin her zaman sende kalır.'
  ),
  (
    'Derin içerikler',
    'Burç uyumluluğu, ruh hayvanı ve doğal taş için ek okumalar.'
  ),
  ('Günlük ve temalar', 'Günlüklerinde arama/istatistik ve üç ek tema.'),
  (
    'Rehber kullanımı',
    'Mock rehber döneminde gerçek AI veya premium AI hizmeti sunulmaz.'
  ),
];

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature, required this.tokens});

  final (String, String) feature;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: tokens.successColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.$1, style: AppTextStyles.titleSmall(tokens)),
                  const SizedBox(height: 2),
                  Text(feature.$2, style: AppTextStyles.caption(tokens)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.tokens});

  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) => CosmicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kullanım sınırları', style: AppTextStyles.titleSmall(tokens)),
            const SizedBox(height: 10),
            _limitLine(tokens, 'Saat Anı bildirimi', '5 / gün', '12 / gün'),
            _limitLine(tokens, 'Aktif niyet', '3', 'Sınırsız'),
            _limitLine(tokens, 'Rehber', '5 mesaj / gün · 30 sn',
                '50 mesaj / gün · 10 sn'),
          ],
        ),
      );

  Widget _limitLine(
          CosmicTokens tokens, String label, String free, String premium) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: AppTextStyles.caption(tokens))),
            Text('$free  ·  $premium', style: AppTextStyles.caption(tokens)),
          ],
        ),
      );
}
