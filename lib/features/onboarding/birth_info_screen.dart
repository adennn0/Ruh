import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../widgets/cosmic_widgets.dart';
import 'onboarding_controller.dart';
import 'onboarding_progress.dart';
import 'birth_date_input_formatter.dart';

/// Onboarding Ekran 1 — Doğum bilgisi (Spec Bölüm 7)
class BirthInfoScreen extends ConsumerStatefulWidget {
  const BirthInfoScreen({super.key});

  @override
  ConsumerState<BirthInfoScreen> createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends ConsumerState<BirthInfoScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, CosmicTokens tokens) async {
    final state = ref.read(onboardingControllerProvider);
    final initial = state.birthDate ?? DateTime(DateTime.now().year - 25, 1, 1);

    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      helpText: 'Doğum Tarihi',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: tokens.accentPrimary,
            surface: tokens.surface,
            onSurface: tokens.onSurface,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: tokens.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      ref.read(onboardingControllerProvider.notifier).setBirthDate(picked);
      _birthDateController.text = _formatDate(picked);
    }
  }

  Future<void> _pickTime(BuildContext ctx, CosmicTokens tokens) async {
    final state = ref.read(onboardingControllerProvider);
    final initial = state.birthHour != null
        ? TimeOfDay(hour: state.birthHour!, minute: state.birthMinute ?? 0)
        : const TimeOfDay(hour: 12, minute: 0);

    final picked = await showTimePicker(
      context: ctx,
      initialTime: initial,
      helpText: 'Doğum Saati',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: tokens.accentPrimary,
            surface: tokens.surface,
            onSurface: tokens.onSurface,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: tokens.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      ref.read(onboardingControllerProvider.notifier).setBirthTime(
            picked.hour,
            picked.minute,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final ctrl = ref.read(onboardingControllerProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          // İlerleme göstergesi (adım 1/3)
          OnboardingProgress(currentStep: 1, totalSteps: 3, tokens: tokens),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Ouroboros placeholder (gerçek asset Aşama 9)
                  Center(
                    child: _OuroborosPlaceholder(tokens: tokens),
                  ),
                  const SizedBox(height: 28),

                  // Başlık
                  Text(
                    'İlk Adımın: Kökenin',
                    style: AppTextStyles.h1(tokens),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enerjini analiz edebilmemiz için doğum bilgilerine ihtiyacımız var.',
                    style: AppTextStyles.body(tokens).copyWith(
                      color: tokens.onSurfaceSubtle,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Hitap adı (isteğe bağlı)
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: tokens.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Sana nasıl hitap edelim? (İsteğe bağlı)',
                      hintText: 'Adın veya takma adın',
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: ctrl.setDisplayName,
                  ),
                  const SizedBox(height: 20),

                  // Doğum tarihi
                  Text(
                    'Doğum Tarihi *',
                    style: AppTextStyles.label(tokens),
                  ),
                  const SizedBox(height: 8),
                  CosmicCard(
                    borderColor: state.birthDate != null
                        ? tokens.accentPrimary
                        : tokens.glassStroke,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _birthDateController,
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            inputFormatters: const [BirthDateInputFormatter()],
                            onChanged: ctrl.setBirthDateInput,
                            decoration: const InputDecoration(
                              counterText: '',
                              labelText: 'Doğum tarihi',
                              hintText: 'gg.aa.yyyy',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Takvimden tarih seç',
                          onPressed: () => _pickDate(context, tokens),
                          icon: Icon(Icons.calendar_today_outlined,
                              color: tokens.accentPrimary),
                        ),
                      ],
                    ),
                  ),

                  // Hata mesajı
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.caption(tokens).copyWith(
                        color: tokens.errorColor,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Doğum saati
                  Text(
                    'Doğum Saati',
                    style: AppTextStyles.label(tokens),
                  ),
                  const SizedBox(height: 8),

                  if (!state.birthTimeKnown) ...[
                    CosmicSecondaryButton(
                      label: 'Saati seç',
                      icon: const Icon(Icons.access_time_outlined, size: 18),
                      onPressed: () => _pickTime(context, tokens),
                    ),
                    const SizedBox(height: 8),
                    CosmicGhostButton(
                      label: 'Tam saatten emin değilim',
                      onPressed: ctrl.setTimeUnknown,
                      color: tokens.onSurfaceMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Doğum saati bilinmiyorsa bazı yorumlar yaklaşık olabilir.',
                      style: AppTextStyles.caption(tokens).copyWith(
                        color: tokens.onSurfaceMuted,
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () => _pickTime(context, tokens),
                      child: CosmicCard(
                        borderColor: tokens.accentPrimary,
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: tokens.accentPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_pad(state.birthHour!)}:${_pad(state.birthMinute!)}',
                              style: AppTextStyles.body(tokens),
                            ),
                            const Spacer(),
                            CosmicGhostButton(
                              label: 'Değiştir',
                              onPressed: () => _pickTime(context, tokens),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CosmicGhostButton(
                      label: 'Saatimi bilmiyorum',
                      onPressed: ctrl.setTimeUnknown,
                      color: tokens.onSurfaceMuted,
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Alt buton
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: CosmicPrimaryButton(
              label: 'Yolculuğa Başla',
              isDisabled: !state.canProceedFromStep1,
              isLoading: state.isLoading,
              onPressed: state.canProceedFromStep1
                  ? () => ref
                      .read(onboardingControllerProvider.notifier)
                      .goToStep(2)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}

/// Ouroboros görsel placeholder — gerçek 3D asset gelene kadar
class _OuroborosPlaceholder extends StatelessWidget {
  const _OuroborosPlaceholder({required this.tokens});
  final CosmicTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            tokens.accentPrimary.withValues(alpha: 0.4),
            tokens.accentSecondary.withValues(alpha: 0.2),
            tokens.background,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: tokens.primaryGlow(radius: 40, opacity: 0.3),
      ),
      child: Center(
        child: Text(
          '☽',
          style: TextStyle(
            fontSize: 72,
            color: tokens.accentPrimary,
          ),
        ),
      ),
    );
  }
}
