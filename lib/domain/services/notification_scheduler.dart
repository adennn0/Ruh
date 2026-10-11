import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/limits.dart';
import '../../core/router/app_router.dart';
import '../../data/repositories/intention_repository.dart'; // activeIntentionsProvider
import '../../data/repositories/user_profile_repository.dart';
import '../models/enums.dart';
import '../../features/profile/notification_settings.dart';
import '../../platform/notifications/notifications_adapter.dart';
import '../time_moment/notification_payload.dart';
import '../time_moment/quiet_hours.dart';
import '../time_moment/time_moment_copy.dart';
import '../time_moment/time_moment_planner.dart';

class NotificationScheduler {
  NotificationScheduler({
    required this.adapter,
    required this.planner,
    required this.copyEngine,
  });

  final NotificationsAdapter adapter;
  final TimeMomentPlanner planner;
  final TimeMomentCopyEngine copyEngine;

  Future<void> attachTapHandler() async {
    await adapter.initialize(onTap: openPayload);
    final launch = adapter.consumeLaunchPayload();
    if (launch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openPayload(launch);
      });
    }
  }

  void openPayload(TimeMomentPayload payload) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (payload.timeLabel.startsWith('intention:')) {
      final id = int.tryParse(payload.timeLabel.substring('intention:'.length));
      final query = <String, String>{'tab': '1'};
      if (id != null) query['intention'] = '$id';
      GoRouter.of(context)
          .go(Uri(path: AppRoutes.journal, queryParameters: query).toString());
      return;
    }
    GoRouter.of(context).push(
      '${AppRoutes.timeMomentOpen}?date=${Uri.encodeComponent(payload.localDate)}&time=${Uri.encodeComponent(payload.timeLabel)}',
    );
  }

  Future<bool> enableAndRebuild({
    required UserProfile profile,
    required NotificationSettings settings,
    required EntitlementService entitlement,
    required String personalSalt,
    required List<String> intentionTitles,
    List<IntentionModel> intentions = const [],
  }) async {
    final granted = await adapter.requestPermission();
    if (!granted) {
      await adapter.cancelAll();
      return false;
    }
    await rebuild(
      profile: profile,
      settings: settings,
      entitlement: entitlement,
      personalSalt: personalSalt,
      intentionTitles: intentionTitles,
      intentions: intentions,
    );
    return true;
  }

  Future<void> rebuild({
    required UserProfile profile,
    required NotificationSettings settings,
    required EntitlementService entitlement,
    required String personalSalt,
    required List<String> intentionTitles,
    List<IntentionModel> intentions = const [],
  }) async {
    final permitted = await adapter.hasPermission();
    if (!permitted) {
      await adapter.cancelAll();
      return;
    }

    final dailyCap = entitlement.limitFor(AppFeature.dailyNotifications);
    final cap = dailyCap < 0 ? 12 : dailyCap;
    final now = DateTime.now();
    final quiet = QuietHours(
      startMinutes:
          settings.quietHoursStart.hour * 60 + settings.quietHoursStart.minute,
      endMinutes:
          settings.quietHoursEnd.hour * 60 + settings.quietHoursEnd.minute,
    );

    final items = <ScheduledNotification>[];
    for (var dayOffset = 0;
        dayOffset <= AppLimits.notificationWindowDays;
        dayOffset++) {
      final day =
          DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
      var remaining = cap;

      if (settings.timeMoment &&
          remaining > 0 &&
          dayOffset < AppLimits.notificationWindowDays) {
        final planned = planner.plan(
          TimeMomentPlannerInput(
            localDay: day,
            sign: profile.zodiacSign,
            toneIndex: profile.tone.index,
            personalSalt: personalSalt,
            maxCount: remaining,
            quietHours: quiet,
            birthHour: profile.birthTimeKnown ? profile.birthHour : null,
            intentionTitles: intentionTitles,
            now: dayOffset == 0 ? now : null,
          ),
        );
        for (var i = 0; i < planned.length; i++) {
          final slot = planned[i];
          remaining--;
          final intention = copyEngine.pickIntentionTitle(
            intentionTitles,
            slot.localDate,
            slot.time.label,
          );
          final copy = copyEngine.compose(
            time: slot.time,
            localDate: slot.localDate,
            sign: profile.zodiacSign,
            tone: profile.tone,
            personalSalt: personalSalt,
            intentionTitle: intention.isEmpty ? null : intention,
          );
          items.add(
            ScheduledNotification(
              id: 300000 + dayOffset * 40 + i,
              title: copy.title,
              body: copy.notificationBody,
              scheduledTime: slot.scheduledAt,
              payload: TimeMomentPayload(
                localDate: slot.localDate,
                timeLabel: slot.time.label,
              ).encode(),
            ),
          );
        }
      }

      void addExtra({
        required bool enabled,
        required TimeOfDay time,
        required int typeIndex,
        required String title,
        required String body,
        required String routeTimeLabel,
      }) {
        if (!enabled ||
            remaining <= 0 ||
            dayOffset >= AppLimits.notificationWindowDays) {
          return;
        }
        final when =
            DateTime(day.year, day.month, day.day, time.hour, time.minute);
        final minutes = time.hour * 60 + time.minute;
        if (quiet.contains(minutes)) return;
        if (dayOffset == 0 && !when.isAfter(now)) return;
        remaining--;
        items.add(
          ScheduledNotification(
            id: 400000 + dayOffset * 10 + typeIndex,
            title: title,
            body: body,
            scheduledTime: when,
            payload: TimeMomentPayload(
              localDate:
                  '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
              timeLabel: routeTimeLabel,
            ).encode(),
          ),
        );
      }

      addExtra(
        enabled: settings.intentionReminder,
        time: settings.intentionTime,
        typeIndex: 1,
        title: 'Niyet hatırlatıcısı',
        body: 'Bugünkü niyetin için küçük bir adım seçmeye hazır mısın?',
        routeTimeLabel: 'niyet',
      );
      addExtra(
        enabled: settings.eveningReview,
        time: settings.eveningReviewTime,
        typeIndex: 2,
        title: 'Akşam duruşu',
        body: 'Günü nazikçe kapatmak için kısa bir bakış.',
        routeTimeLabel: 'aksam',
      );
      addExtra(
        enabled: settings.dailyMessage,
        time: settings.dailyMessageTime,
        typeIndex: 3,
        title: 'Günün mesajı hazır',
        body: 'Burcuna ve tonuna göre bugünkü mesajın seni bekliyor.',
        routeTimeLabel: 'mesaj',
      );

      if (settings.pastIntentionReminder && remaining > 0) {
        for (final intention in intentions.where(
          (item) => item.status == IntentionStatus.active,
        )) {
          for (final days in const [1, 7]) {
            var due = intention.createdAt.add(Duration(days: days));
            if (!due.isAfter(now)) continue;
            final dueMinutes = due.hour * 60 + due.minute;
            if (quiet.contains(dueMinutes)) {
              final end = DateTime(due.year, due.month, due.day,
                  settings.quietHoursEnd.hour, settings.quietHoursEnd.minute);
              due = dueMinutes < quiet.endMinutes
                  ? end
                  : end.add(const Duration(days: 1));
            }
            if (due.year != day.year ||
                due.month != day.month ||
                due.day != day.day) {
              continue;
            }
            if (remaining <= 0) break;
            remaining--;
            items.add(ScheduledNotification(
              id: 500000 + intention.id * 10 + days,
              title: 'Bir niyetine dön',
              body:
                  'Daha önce belirlediğin bir niyeti yeniden gözden geçirmek ister misin?',
              scheduledTime: due,
              payload: TimeMomentPayload(
                localDate:
                    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
                timeLabel: 'intention:${intention.id}',
              ).encode(),
            ));
          }
        }
      }
    }

    await adapter.scheduleWindow(notifications: items);
  }

  Future<void> cancelAll() => adapter.cancelAll();
}

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(
    adapter: ref.watch(notificationsAdapterProvider),
    planner: const TimeMomentPlanner(),
    copyEngine: const TimeMomentCopyEngine(),
  );
});

/// Profil/ayar değişince 7 günlük pencereyi yenile.
Future<void> rebuildNotificationWindow(WidgetRef ref) async {
  final profile = ref.read(userProfileProvider);
  if (profile == null) return;
  final settings = ref.read(notificationSettingsProvider);
  final entitlement = ref.read(entitlementServiceProvider);
  final salt = ref.read(userProfileRepositoryProvider).contentSalt;
  final intentions =
      await ref.read(intentionRepositoryProvider).watchActive().first;
  await ref.read(notificationSchedulerProvider).rebuild(
        profile: profile,
        settings: settings,
        entitlement: entitlement,
        personalSalt: salt,
        intentionTitles: intentions.map((i) => i.title).toList(),
        intentions: intentions,
      );
}
