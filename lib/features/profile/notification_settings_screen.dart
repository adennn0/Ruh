import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/theme/theme.dart';
import '../../data/repositories/intention_repository.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../platform/notifications/notifications_adapter.dart';
import '../../widgets/cosmic_widgets.dart';
import 'notification_settings.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    void Function(TimeOfDay) onSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        final tokens = Theme.of(context).extension<CosmicTokens>()!;
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: tokens.accentPrimary,
              onSurface: tokens.onBackground,
              surface: tokens.surface,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: tokens.surface,
              dialBackgroundColor: tokens.surfaceElevated,
              dialHandColor: tokens.accentPrimary,
              hourMinuteColor: tokens.surfaceElevated,
              hourMinuteTextColor: tokens.onSurface,
              dayPeriodColor: tokens.surfaceElevated,
              dayPeriodTextColor: tokens.onSurface,
              entryModeIconColor: tokens.accentPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _afterChange(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;
    final settings = ref.read(notificationSettingsProvider);
    final scheduler = ref.read(notificationSchedulerProvider);
    if (settings.timeMoment ||
        settings.intentionReminder ||
        settings.eveningReview ||
        settings.dailyMessage) {
      final granted = await scheduler.enableAndRebuild(
        profile: profile,
        settings: settings,
        entitlement: ref.read(entitlementServiceProvider),
        personalSalt: ref.read(userProfileRepositoryProvider).contentSalt,
        intentionTitles: (ref.read(activeIntentionsProvider).valueOrNull ?? [])
            .map((i) => i.title)
            .toList(),
        intentions: ref.read(activeIntentionsProvider).valueOrNull ?? const [],
      );
      if (!granted && context.mounted) {
        showCosmicSnackbar(
          context,
          'Bildirim izni olmadan hatırlatıcı kurulamaz. Ayarlardan izin verebilirsin.',
        );
      }
    } else {
      await scheduler.cancelAll();
    }
    ref.invalidate(notificationAvailabilityProvider);
  }

  Future<void> _enableAndRefresh(BuildContext context, WidgetRef ref) async {
    await ref
        .read(notificationSettingsProvider.notifier)
        .updateToggle('time_moment', true);
    if (!context.mounted) return;
    await _afterChange(context, ref);
    ref.invalidate(notificationAvailabilityProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final state = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);
    final isPremium = ref.watch(isPremiumProvider);
    final notificationAvailability =
        ref.watch(notificationAvailabilityProvider).valueOrNull;
    final maxLimit = ref
        .watch(entitlementServiceProvider)
        .limitFor(AppFeature.dailyNotifications);

    Widget extraRow({
      required String title,
      required String subtitle,
      required String key,
      required bool value,
      required TimeOfDay time,
      required String timeKey,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: CosmicCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall(tokens)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.caption(tokens)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context, time, (t) async {
                        await controller.updateTime(timeKey, t);
                        if (context.mounted) await _afterChange(context, ref);
                      }),
                      child: Text(
                        time.format(context),
                        style: AppTextStyles.bodyLarge(tokens).copyWith(
                          color: tokens.accentPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeTrackColor: tokens.accentPrimary,
                onChanged: (val) async {
                  await controller.updateToggle(key, val);
                  if (!context.mounted) return;
                  await _afterChange(context, ref);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text('Bildirim Ayarları', style: AppTextStyles.h2(tokens)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Kişisel Saat Anı: günde en fazla $maxLimit '
              '(${isPremium ? 'Premium' : 'Ücretsiz'}). '
              'Saatler burcuna, tonuna ve niyetlerine göre her gün yeniden seçilir. '
              'Aynı metin herkese gitmez.',
              style: AppTextStyles.body(tokens),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CosmicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationAvailability?.hasPermission == true
                        ? 'Bildirim durumu'
                        : 'Bildirim izni gerekli',
                    style: AppTextStyles.titleSmall(tokens),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notificationAvailability?.hasPermission == true
                        ? '${notificationAvailability!.pendingCount} bildirim sıraya alındı.'
                        : 'İzin verilmediği için çift ve palindrom saat bildirimleri planlanmıyor.',
                    style: AppTextStyles.body(tokens),
                  ),
                  const SizedBox(height: 12),
                  CosmicPrimaryButton(
                    label: notificationAvailability?.hasPermission == true
                        ? 'Planlamayı yenile'
                        : 'İzin ver ve bildirimleri etkinleştir',
                    height: 48,
                    onPressed: () => _enableAndRefresh(context, ref),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CosmicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kişisel Saat Anı',
                            style: AppTextStyles.titleSmall(tokens)),
                        const SizedBox(height: 4),
                        Text(
                          '11:11, 14:14, 14:41, 22:22 gibi çift ve palindrom saatlerden '
                          'sana özel bir seçki. Bildirime dokununca o ana özel mesaj açılır.',
                          style: AppTextStyles.caption(tokens),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.timeMoment,
                    activeTrackColor: tokens.accentPrimary,
                    onChanged: (val) async {
                      await controller.updateToggle('time_moment', val);
                      if (!context.mounted) return;
                      await _afterChange(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ),
          extraRow(
            title: 'Günlük niyet hatırlatıcısı',
            subtitle: 'Sabit saat; kota dolunca planlanmaz',
            key: 'intention',
            value: state.intentionReminder,
            time: state.intentionTime,
            timeKey: 'intention',
          ),
          extraRow(
            title: 'Akşam değerlendirmesi',
            subtitle: 'Günü kapatma hatırlatıcısı',
            key: 'evening',
            value: state.eveningReview,
            time: state.eveningReviewTime,
            timeKey: 'evening',
          ),
          extraRow(
            title: 'Günlük mesaj hazır',
            subtitle: 'Burcuna özel günün mesajı',
            key: 'daily_message',
            value: state.dailyMessage,
            time: state.dailyMessageTime,
            timeKey: 'daily_message',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CosmicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Geçmiş niyet hatırlatmaları',
                            style: AppTextStyles.titleSmall(tokens)),
                        const SizedBox(height: 4),
                        Text(
                            'Aktif niyetlerini 1 gün ve 1 hafta sonra tekrar gözden geçir.',
                            style: AppTextStyles.caption(tokens)),
                      ],
                    ),
                  ),
                  Switch(
                    value: state.pastIntentionReminder,
                    activeTrackColor: tokens.accentPrimary,
                    onChanged: (value) async {
                      await controller.updateToggle('past_intention', value);
                      if (context.mounted) await _afterChange(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sessiz Saatler',
              style: AppTextStyles.title(tokens),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: CosmicCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => _selectTime(
                      context,
                      state.quietHoursStart,
                      (t) async {
                        await controller.updateQuietTime(true, t);
                        if (context.mounted) await _afterChange(context, ref);
                      },
                    ),
                    child: Column(
                      children: [
                        Text('Başlangıç', style: AppTextStyles.caption(tokens)),
                        Text(
                          state.quietHoursStart.format(context),
                          style: AppTextStyles.titleSmall(tokens),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CosmicCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => _selectTime(
                      context,
                      state.quietHoursEnd,
                      (t) async {
                        await controller.updateQuietTime(false, t);
                        if (context.mounted) await _afterChange(context, ref);
                      },
                    ),
                    child: Column(
                      children: [
                        Text('Bitiş', style: AppTextStyles.caption(tokens)),
                        Text(
                          state.quietHoursEnd.format(context),
                          style: AppTextStyles.titleSmall(tokens),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'İzin vermeden bildirim planlanmaz. Metinler kesin gerçekleşme vaadi taşımaz; '
              'sembolik bir durak ve niyet hatırlatıcısıdır.',
              style: AppTextStyles.caption(tokens)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationAvailability {
  const NotificationAvailability({
    required this.hasPermission,
    required this.pendingCount,
  });

  final bool hasPermission;
  final int pendingCount;
}

final notificationAvailabilityProvider =
    FutureProvider<NotificationAvailability>((ref) async {
  final adapter = ref.watch(notificationsAdapterProvider);
  final hasPermission = await adapter.hasPermission();
  final pendingCount = hasPermission ? await adapter.pendingCount() : 0;
  return NotificationAvailability(
    hasPermission: hasPermission,
    pendingCount: pendingCount,
  );
});
