import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../domain/models/enums.dart';
import '../../widgets/cosmic_widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_progress.dart';

/// Onboarding Ekran 3 — Mesaj Tonu Seçimi (Spec Bölüm 7)
/// Varsayılan: Spiritüel. Seçim Profil'den sonradan değiştirilebilir.
class ToneSelectionScreen extends ConsumerWidget {
  const ToneSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final ctrl = ref.read(onboardingControllerProvider.notifier);
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return SafeArea(
      child: Column(
        children: [
          OnboardingProgress(currentStep: 3, totalSteps: 3, tokens: tokens),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Mesaj Tonunu Seç', style: AppTextStyles.h1(tokens)),
                  const SizedBox(height: 8),
                  Text(
                    'Seçtiğin ton mesajlarını şekillendirir. Profil\'den istediğin zaman değiştirebilirsin.',
                    style: AppTextStyles.body(tokens)
                        .copyWith(color: tokens.onSurfaceSubtle),
                  ),
                  const SizedBox(height: 28),

                  // 4 ton kartı
                  ...MessageTone.values.map((tone) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ToneCard(
                          tone: tone,
                          isSelected: state.selectedTone == tone,
                          onTap: () => ctrl.setTone(tone),
                          tokens: tokens,
                        ),
                      )),

                  const SizedBox(height: 12),
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
                  label: 'Frekansı Ayarla',
                  isLoading: state.isLoading,
                  onPressed: () => ctrl.completeOnboarding(),
                ),
                const SizedBox(height: 8),
                CosmicGhostButton(
                  label: '← Geri',
                  onPressed: () => ctrl.goBack(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({
    required this.tone,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  final MessageTone tone;
  final bool isSelected;
  final VoidCallback onTap;
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accentPrimary.withValues(alpha: 0.12)
              : tokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? tokens.accentPrimary : tokens.glassStroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji/ikon
            Text(
              _toneEmoji(tone),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tone.displayName,
                    style: AppTextStyles.titleSmall(tokens).copyWith(
                      color:
                          isSelected ? tokens.accentPrimary : tokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tone.subtitle,
                    style: AppTextStyles.caption(tokens).copyWith(
                      color: tokens.onSurfaceSubtle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Örnek cümle
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.glassOverlay,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tokens.glassStroke),
                    ),
                    child: Text(
                      '"${tone.example}"',
                      style: AppTextStyles.caption(tokens).copyWith(
                        color: tokens.onSurfaceSubtle,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            // Seçim göstergesi
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? tokens.accentPrimary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? tokens.accentPrimary : tokens.onSurfaceMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _toneEmoji(MessageTone tone) => switch (tone) {
        MessageTone.soft => '🌸',
        MessageTone.strong => '⚡',
        MessageTone.spiritual => '✨',
        MessageTone.rational => '🧭',
      };
}
