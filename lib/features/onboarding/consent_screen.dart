import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';
import 'onboarding_controller.dart';

/// Rıza / KVKK aydınlatma ekranı (Spec Bölüm 7, Karar 15, Bölüm 22)
/// 16 yaş üstü onayı + veri kapsam açıklaması + açık rıza butonu.
class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo / başlık
            Center(
              child: Text(
                'Ruhun Parlıyor',
                style: AppTextStyles.displayMedium(tokens),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Gizlilik ve Rıza',
                style: AppTextStyles.title(tokens).copyWith(
                  color: tokens.accentPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'Verileriniz Güvende',
                      body:
                          'Doğum tarihi, saati ve günlükleriniz yalnızca bu cihazda saklanır. '
                          'Sunucuya gönderilmez, üçüncü taraflarla paylaşılmaz.',
                      tokens: tokens,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Neden Doğum Bilgisi İstiyoruz?',
                      body:
                          'Güneş burcunuzu, element enerjinizi ve spiritüel profilinizi '
                          'hesaplamak için kullanılır. Bu bilgi olmadan kişiselleştirilmiş '
                          'içerik sunulamaz.',
                      tokens: tokens,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.delete_outline_rounded,
                      title: 'Haklarınız',
                      body:
                          'Verilerinizi istediğiniz zaman Profil → Hesabım ekranından '
                          'görüntüleyebilir, güncelleyebilir veya tamamıyla silebilirsiniz. '
                          'Kendi yazdıklarınıza (niyet, günlük) erişim hiçbir zaman '
                          'kısıtlanmaz.',
                      tokens: tokens,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.person_outline_rounded,
                      title: '16 Yaş Üstü İçindir',
                      body:
                          'Bu uygulama 16 yaş ve üzeri kullanıcılar için tasarlanmıştır. '
                          'İlerlemeye devam ederek bu yaş koşulunu kabul etmiş olursunuz.',
                      tokens: tokens,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.info_outline_rounded,
                      title: 'Sembolik Çerçeve',
                      body:
                          'Burç yorumları, doğal taş anlamları ve manifestasyon içerikleri '
                          'sembolik, eğlenceli ve kişisel anlam yüklenebilen araçlardır. '
                          'Bilimsel gerçek, tıbbi/finansal/psikolojik danışmanlık veya '
                          'kader kehaneti olarak sunulmaz.',
                      tokens: tokens,
                    ),
                    const SizedBox(height: 24),

                    // Sözleşme onay metni
                    Text(
                      'Devam ederek yukarıdakileri okuduğunuzu, anladığınızı ve 16 yaş '
                      'üstü olduğunuzu onaylıyorsunuz.',
                      style: AppTextStyles.caption(tokens).copyWith(
                        color: tokens.onSurfaceSubtle,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            CosmicPrimaryButton(
              label: 'Kabul Ediyorum, Başlayalım',
              onPressed: () {
                ref.read(onboardingControllerProvider.notifier).acceptConsent();
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Vazgeçmek için uygulamayı kapatın.',
                style: AppTextStyles.caption(tokens).copyWith(
                  color: tokens.onSurfaceMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.tokens,
  });

  final IconData icon;
  final String title;
  final String body;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.accentPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tokens.accentPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall(tokens)),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: tokens.onSurfaceSubtle,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
