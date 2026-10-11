import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruhun_parliyor/core/entitlement/entitlement.dart';
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

    await scheduler.rebuild(
      profile: UserProfile(
        birthDate: DateTime(1990, 5, 1),
        birthTimeKnown: false,
        tone: MessageTone.spiritual,
        themeId: 'amethystAurora',
      ),
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
