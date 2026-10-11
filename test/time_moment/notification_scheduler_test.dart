import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruhun_parliyor/core/entitlement/entitlement.dart';
import 'package:ruhun_parliyor/core/limits.dart';
import 'package:ruhun_parliyor/data/repositories/user_profile_repository.dart';
import 'package:ruhun_parliyor/data/repositories/intention_repository.dart';
import 'package:ruhun_parliyor/domain/models/enums.dart';
import 'package:ruhun_parliyor/domain/services/notification_scheduler.dart';
import 'package:ruhun_parliyor/domain/time_moment/notification_payload.dart';
import 'package:ruhun_parliyor/domain/time_moment/special_times.dart';
import 'package:ruhun_parliyor/domain/time_moment/time_moment_copy.dart';
import 'package:ruhun_parliyor/domain/time_moment/time_moment_planner.dart';
import 'package:ruhun_parliyor/features/profile/notification_settings.dart';
import 'package:ruhun_parliyor/platform/notifications/notifications_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enabled Saat Anı plans future special times across seven days',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final adapter = _RecordingNotificationsAdapter();
    final scheduler = NotificationScheduler(
      adapter: adapter,
      planner: const TimeMomentPlanner(),
      copyEngine: const TimeMomentCopyEngine(),
    );
    final profile = UserProfile(
      birthDate: DateTime(1990, 5, 1),
      birthTimeKnown: false,
      tone: MessageTone.spiritual,
      themeId: 'amethystAurora',
    );

    await scheduler.rebuild(
      profile: profile,
      settings: const NotificationSettings(
        timeMoment: true,
        quietHoursStart: TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 8, minute: 0),
      ),
      entitlement: EntitlementService(prefs),
      personalSalt: 'test-user',
      intentionTitles: const [],
    );

    expect(adapter.scheduled.length, greaterThanOrEqualTo(30));
    expect(adapter.scheduled.length, lessThanOrEqualTo(35));
    expect(
      adapter.scheduled.every(
        (item) => SpecialTimes.isSpecial(
          '${item.scheduledTime.hour.toString().padLeft(2, '0')}:'
          '${item.scheduledTime.minute.toString().padLeft(2, '0')}',
        ),
      ),
      isTrue,
    );
    expect(
      adapter.scheduled
          .every((item) => item.scheduledTime.isAfter(DateTime.now())),
      isTrue,
    );
    expect(adapter.scheduled.map((item) => item.id).toSet().length,
        adapter.scheduled.length);
    expect(
      adapter.scheduled.map((item) => item.body).toSet().length,
      adapter.scheduled.length,
      reason: 'notification copy should not repeat inside the rolling window',
    );
    for (final item in adapter.scheduled) {
      final payload = TimeMomentPayload.tryParse(item.payload)!;
      final time = SpecialTimes.parse(payload.timeLabel)!;
      expect(
        item.body,
        const TimeMomentCopyEngine()
            .compose(
              time: time,
              localDate: payload.localDate,
              sign: profile.zodiacSign,
              tone: profile.tone,
              personalSalt: 'test-user',
            )
            .notificationBody,
      );
    }
  });

  test('night reminder is premium-only, opt-in, and may use the quiet window',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final entitlement = EntitlementService(prefs);
    final adapter = _RecordingNotificationsAdapter();
    final scheduler = NotificationScheduler(
      adapter: adapter,
      planner: const TimeMomentPlanner(),
      copyEngine: const TimeMomentCopyEngine(),
    );
    final profile = UserProfile(
      birthDate: DateTime(1990, 5, 1),
      birthTimeKnown: false,
      tone: MessageTone.soft,
      themeId: 'pearlMoon',
    );
    const settings = NotificationSettings(
      timeMoment: false,
      nightReminder: true,
      nightReminderTime: TimeOfDay(hour: 3, minute: 33),
    );

    await scheduler.rebuild(
      profile: profile,
      settings: settings,
      entitlement: entitlement,
      personalSalt: 'night-test',
      intentionTitles: const [],
    );
    expect(adapter.scheduled.where((item) => item.id >= 600000), isEmpty);

    await entitlement.setPremium(active: true);
    await scheduler.rebuild(
      profile: profile,
      settings: settings,
      entitlement: entitlement,
      personalSalt: 'night-test',
      intentionTitles: const [],
    );
    final nightItems =
        adapter.scheduled.where((item) => item.id >= 600000).toList();
    expect(nightItems, isNotEmpty);
    expect(nightItems.length, lessThanOrEqualTo(7));
    expect(
      nightItems.every((item) =>
          item.scheduledTime.hour == 3 && item.scheduledTime.minute == 33),
      isTrue,
    );
    expect(
      nightItems.length,
      lessThanOrEqualTo(entitlement.limitFor(AppFeature.nightNotifications) *
          AppLimits.notificationWindowDays),
    );
    expect(
      nightItems.map((item) => item.body).toSet().length,
      nightItems.length,
    );
    expect(nightItems.first.payload, contains('|gece'));
    final nightPayload = TimeMomentPayload.tryParse(nightItems.first.payload)!;
    expect(
      nightItems.first.body,
      const TimeMomentCopyEngine().composeNightNotification(
        localDate: nightPayload.localDate,
        sign: profile.zodiacSign,
        tone: profile.tone,
        personalSalt: 'night-test',
      ),
    );
  });

  test('night reminder preference persists and defaults to off', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = NotificationSettingsController(prefs);
    expect(controller.state.nightReminder, isFalse);
    expect(controller.state.nightReminderTime,
        const TimeOfDay(hour: 3, minute: 33));

    await controller.updateNightReminder(true);
    await controller
        .updateNightReminderTime(const TimeOfDay(hour: 23, minute: 15));
    final reloaded = NotificationSettingsController(prefs);
    expect(reloaded.state.nightReminder, isTrue);
    expect(reloaded.state.nightReminderTime,
        const TimeOfDay(hour: 23, minute: 15));
    controller.dispose();
    reloaded.dispose();
  });

  test('opt-in intention follow-ups are generic and scheduled at 1 and 7 days',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final adapter = _RecordingNotificationsAdapter();
    final scheduler = NotificationScheduler(
      adapter: adapter,
      planner: const TimeMomentPlanner(),
      copyEngine: const TimeMomentCopyEngine(),
    );
    final createdAt = DateTime.now().subtract(const Duration(hours: 20));
    final intention = IntentionModel(
      id: 42,
      title: 'Kimseye sızmaması gereken özel niyet',
      category: IntentionCategory.personalGrowth,
      status: IntentionStatus.active,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await scheduler.rebuild(
      profile: UserProfile(
        birthDate: DateTime(1990, 5, 1),
        birthTimeKnown: false,
        tone: MessageTone.soft,
        themeId: 'amethystAurora',
      ),
      settings: const NotificationSettings(
        timeMoment: false,
        pastIntentionReminder: true,
      ),
      entitlement: EntitlementService(prefs),
      personalSalt: 'test-user',
      intentionTitles: const [],
      intentions: [intention],
    );

    final followUps = adapter.scheduled
        .where((item) => item.payload?.contains('intention:42') == true)
        .toList();
    expect(followUps, hasLength(2));
    expect(followUps.every((item) => !item.body.contains(intention.title)),
        isTrue);
    expect(
        followUps.every((item) => item.scheduledTime.isAfter(DateTime.now())),
        isTrue);
    expect(followUps.map((item) => item.id).toSet(), hasLength(2));
  });
}

class _RecordingNotificationsAdapter implements NotificationsAdapter {
  List<ScheduledNotification> scheduled = const [];

  @override
  Future<void> initialize({NotificationTapCallback? onTap}) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> scheduleWindow({
    required List<ScheduledNotification> notifications,
  }) async {
    scheduled = notifications;
  }

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}

  @override
  Future<int> pendingCount() async => scheduled.length;

  @override
  TimeMomentPayload? consumeLaunchPayload() => null;
}
