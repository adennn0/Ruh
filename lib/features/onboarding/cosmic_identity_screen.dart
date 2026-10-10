import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/theme.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../widgets/cosmic_widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_progress.dart';

/// Onboarding Ekran 2 — Kozmik Kimlik (Spec Bölüm 7)
/// Güneş burcu, element, yönetici gezegen, nitelik gerçekten hesaplanır.
/// Yükselen + Ay burcu kilitli önizleme olarak gösterilir (Karar 2).
class CosmicIdentityScreen extends ConsumerWidget {
  const CosmicIdentityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    if (state.birthDate == null) {
      return const SizedBox.shrink();
    }

    const engine = AstrologyEngineImpl();
    final identity = engine.sunSign(state.birthDate!);
    final sign = identity.sunSign;

    return SafeArea(
      child: Column(
        children: [
          OnboardingProgress(currentStep: 2, totalSteps: 3, tokens: tokens),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Kozmik küre placeholder (gerçek asset Aşama 9)
                  Center(child: _CosmicOrb(sign: sign, tokens: tokens)),
                  const SizedBox(height: 24),

                  // Başlık
                  Text('Kozmik Kimliğin', style: AppTextStyles.h1(tokens)),
                  const SizedBox(height: 6),
                  if (state.displayName != null &&
                      state.displayName!.isNotEmpty)
                    Text(
                      'Merhaba, ${state.displayName}!',
                      style: AppTextStyles.body(tokens).copyWith(
                        color: tokens.accentPrimary,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Sınır günü uyarısı
                  if (identity.isBorderDay)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tokens.accentSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tokens.accentSecondary.withValues(alpha: 0.4),
                        ),
                      ),
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
                              'Burç sınır günlerinde doğum saatine göre değişebilir.',
                              style: AppTextStyles.caption(tokens).copyWith(
                                color: tokens.accentSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Burç kartı — ana
                  _IdentityCard(
                    title: 'Güneş Burcun',
                    value: sign.displayName,
                    subtitle: sign.energyTheme,
                    icon: PhosphorIcons.sun(PhosphorIconsStyle.light),
                    tokens: tokens,
                    isHero: true,
                  ),
                  const SizedBox(height: 10),

                  // Grid: 2 sütun
                  Row(
                    children: [
                      Expanded(
                        child: _IdentityCard(
                          title: 'Element',
                          value: sign.element.displayName,
                          icon: _elementIcon(sign.element),
                          tokens: tokens,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _IdentityCard(
                          title: 'Nitelik',
                          value: sign.modality.displayName,
                          icon: PhosphorIcons.star(PhosphorIconsStyle.light),
                          tokens: tokens,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _IdentityCard(
                          title: 'Yönetici Gezegen',
                          value: sign.rulingPlanet,
                          icon: PhosphorIcons.planet(PhosphorIconsStyle.light),
                          tokens: tokens,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _IdentityCard(
                          title: 'Doğal Taşın',
                          value: sign.primaryStone,
                          icon: PhosphorIcons.diamond(PhosphorIconsStyle.light),
                          tokens: tokens,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Yükselen — kilitli (Karar 2)
                  _LockedIdentityCard(
                    title: 'Yükselen Burç',
                    tokens: tokens,
                  ),
                  const SizedBox(height: 10),

                  // Ay burcu — kilitli (Karar 2)
                  _LockedIdentityCard(
                    title: 'Ay Burcu',
                    tokens: tokens,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Butonlar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                CosmicPrimaryButton(
                  label: 'Keşfet',
                  onPressed: () => ref
                      .read(onboardingControllerProvider.notifier)
                      .goToStep(3),
                ),
                const SizedBox(height: 8),
                CosmicGhostButton(
                  label: '← Geri',
                  onPressed: () =>
                      ref.read(onboardingControllerProvider.notifier).goBack(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _elementIcon(ZodiacElement el) => switch (el) {
        ZodiacElement.fire => PhosphorIcons.flame(PhosphorIconsStyle.light),
        ZodiacElement.earth =>
          PhosphorIcons.mountains(PhosphorIconsStyle.light),
        ZodiacElement.air => PhosphorIcons.wind(PhosphorIconsStyle.light),
        ZodiacElement.water => PhosphorIcons.drop(PhosphorIconsStyle.light),
      };
}

// ─── Alt bileşenler ────────────────────────────────────────────────────────────

class _CosmicOrb extends StatelessWidget {
  const _CosmicOrb({required this.sign, required this.tokens});
  final ZodiacSign sign;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış glow
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                tokens.accentPrimary.withValues(alpha: 0.35),
                tokens.accentSecondary.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // İç küre
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                tokens.accentPrimary.withValues(alpha: 0.6),
                tokens.accentSecondary.withValues(alpha: 0.8),
              ],
              center: const Alignment(-0.3, -0.3),
            ),
            boxShadow: tokens.primaryGlow(radius: 32, opacity: 0.4),
          ),
          child: Center(
            child: Text(
              sign.symbol,
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
          ),
        ),
        // İnce orbital halka
        SizedBox(
          width: 158,
          height: 158,
          child: CustomPaint(painter: _OrbitalRingPainter(tokens: tokens)),
        ),
      ],
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  const _OrbitalRingPainter({required this.tokens});
  final CosmicTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tokens.accentPrimary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawOval(
      Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tokens,
    this.subtitle,
    this.isHero = false,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final CosmicTokens tokens;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      padding: EdgeInsets.all(isHero ? 16 : 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.accentPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tokens.accentPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: tokens.onSurfaceSubtle,
                  ),
                ),
                Text(
                  value,
                  style: isHero
                      ? AppTextStyles.title(tokens)
                      : AppTextStyles.titleSmall(tokens),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption(tokens).copyWith(
                      color: tokens.onSurfaceMuted,
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

class _LockedIdentityCard extends StatelessWidget {
  const _LockedIdentityCard({required this.title, required this.tokens});
  final String title;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      borderColor: tokens.premiumBadge.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: tokens.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall(tokens),
                ),
                Text(
                  'Premium · Yakında',
                  style: AppTextStyles.caption(tokens).copyWith(
                    color: tokens.premiumBadge,
                  ),
                ),
              ],
            ),
          ),
          const PremiumBadge(compact: true),
        ],
      ),
    );
  }
}
