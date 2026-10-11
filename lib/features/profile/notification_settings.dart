import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/entitlement/entitlement.dart';
import '../../core/limits.dart';

class NotificationSettings {
  const NotificationSettings({
    this.intentionReminder = false,
    this.pastIntentionReminder = false,
    this.intentionTime = const TimeOfDay(hour: 9, minute: 0),
    this.timeMoment = true,
    this.eveningReview = false,
    this.eveningReviewTime = const TimeOfDay(hour: 20, minute: 0),
    this.dailyMessage = false,
    this.dailyMessageTime = const TimeOfDay(hour: 10, minute: 0),
    this.quietHoursStart =
        const TimeOfDay(hour: AppLimits.defaultQuietHoursStart, minute: 0),
    this.quietHoursEnd =
        const TimeOfDay(hour: AppLimits.defaultQuietHoursEnd, minute: 0),
  });

  final bool intentionReminder;
  final bool pastIntentionReminder;
  final TimeOfDay intentionTime;
  final bool timeMoment;
  final bool eveningReview;
  final TimeOfDay eveningReviewTime;
  final bool dailyMessage;
  final TimeOfDay dailyMessageTime;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  NotificationSettings copyWith({
    bool? intentionReminder,
    bool? pastIntentionReminder,
    TimeOfDay? intentionTime,
    bool? timeMoment,
    bool? eveningReview,
    TimeOfDay? eveningReviewTime,
    bool? dailyMessage,
    TimeOfDay? dailyMessageTime,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      intentionReminder: intentionReminder ?? this.intentionReminder,
      pastIntentionReminder:
          pastIntentionReminder ?? this.pastIntentionReminder,
      intentionTime: intentionTime ?? this.intentionTime,
      timeMoment: timeMoment ?? this.timeMoment,
      eveningReview: eveningReview ?? this.eveningReview,
      eveningReviewTime: eveningReviewTime ?? this.eveningReviewTime,
      dailyMessage: dailyMessage ?? this.dailyMessage,
      dailyMessageTime: dailyMessageTime ?? this.dailyMessageTime,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController(this.prefs)
      : super(const NotificationSettings()) {
    _load();
  }

  final SharedPreferences prefs;

  TimeOfDay _parseTime(String? timeStr, TimeOfDay defaultTime) {
    if (timeStr == null) return defaultTime;
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return defaultTime;
  }

  String _formatTime(TimeOfDay time) => '${time.hour}:${time.minute}';

  void _load() {
    state = NotificationSettings(
      intentionReminder: prefs.getBool('notif_intention') ?? false,
      pastIntentionReminder: prefs.getBool('notif_past_intention') ?? false,
      intentionTime: _parseTime(
        prefs.getString('notif_intention_time'),
        const TimeOfDay(hour: 9, minute: 0),
      ),
      timeMoment: prefs.getBool('notif_time_moment') ?? true,
      eveningReview: prefs.getBool('notif_evening') ?? false,
      eveningReviewTime: _parseTime(
        prefs.getString('notif_evening_time'),
        const TimeOfDay(hour: 20, minute: 0),
      ),
      dailyMessage: prefs.getBool('notif_daily_message') ?? false,
      dailyMessageTime: _parseTime(
        prefs.getString('notif_daily_message_time'),
        const TimeOfDay(hour: 10, minute: 0),
      ),
      quietHoursStart: _parseTime(
        prefs.getString('notif_quiet_start'),
        const TimeOfDay(hour: 22, minute: 0),
      ),
      quietHoursEnd: _parseTime(
        prefs.getString('notif_quiet_end'),
        const TimeOfDay(hour: 8, minute: 0),
      ),
    );
  }

  Future<void> updateToggle(String key, bool value) async {
    await prefs.setBool('notif_$key', value);
    _load();
  }

  Future<void> updateTime(String key, TimeOfDay time) async {
    await prefs.setString('notif_${key}_time', _formatTime(time));
    _load();
  }

  Future<void> updateQuietTime(bool isStart, TimeOfDay time) async {
    final key = isStart ? 'notif_quiet_start' : 'notif_quiet_end';
    await prefs.setString(key, _formatTime(time));
    _load();
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
        (ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationSettingsController(prefs);
});
