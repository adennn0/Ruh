import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/time_moment/notification_payload.dart';

typedef NotificationTapCallback = void Function(TimeMomentPayload payload);

/// Bildirim platform adaptörü arayüzü.
/// UI ve domain Android/iOS API'sini doğrudan çağırmaz.
abstract class NotificationsAdapter {
  Future<void> initialize({NotificationTapCallback? onTap});

  /// İzin iste (yalnızca kullanıcı bildirim açmak istediğinde)
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  Future<void> scheduleWindow({
    required List<ScheduledNotification> notifications,
  });

  Future<void> cancelAll();

  Future<void> cancelById(int id);

  Future<int> pendingCount();

  TimeMomentPayload? consumeLaunchPayload();
}

class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;
}

class LocalNotificationsAdapter implements NotificationsAdapter {
  LocalNotificationsAdapter({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  NotificationTapCallback? _onTap;
  TimeMomentPayload? _launchPayload;
  bool _initialized = false;
  static const _channelId = 'saat_ani';
  static const _channelName = 'Saat Anı';

  @override
  Future<void> initialize({NotificationTapCallback? onTap}) async {
    _onTap = onTap;
    if (_initialized) return;

    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: android, iOS: darwin);

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          final parsed = TimeMomentPayload.tryParse(response.payload);
          if (parsed != null) _onTap?.call(parsed);
        },
      );

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description:
            'Kişiselleştirilmiş çift ve palindrom saat hatırlatıcıları',
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        _launchPayload =
            TimeMomentPayload.tryParse(launch?.notificationResponse?.payload);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notifications initialize skipped: $e');
      _initialized = true;
    }
  }

  @override
  TimeMomentPayload? consumeLaunchPayload() {
    final value = _launchPayload;
    _launchPayload = null;
    return value;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize(onTap: _onTap);
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission();
        if (granted != true) return false;

        // Exact alarms are needed for minute-specific Saat Anı reminders on
        // Android 12+. If the user declines, scheduling still falls back to
        // inexact delivery in scheduleWindow.
        await android?.requestExactAlarmsPermission();
        return true;
      }
      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
    return false;
  }

  @override
  Future<bool> hasPermission() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<void> scheduleWindow({
    required List<ScheduledNotification> notifications,
  }) async {
    await initialize(onTap: _onTap);
    await cancelAll();
    for (final item in notifications) {
      if (!item.scheduledTime.isAfter(DateTime.now())) continue;
      final when = tz.TZDateTime.from(item.scheduledTime, tz.local);
      try {
        await _plugin.zonedSchedule(
          item.id,
          item.title,
          item.body,
          when,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription:
                  'Kişiselleştirilmiş çift ve palindrom saat hatırlatıcıları',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(item.body),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: item.payload,
        );
      } catch (e) {
        debugPrint('Exact schedule failed, inexact fallback: $e');
        try {
          await _plugin.zonedSchedule(
            item.id,
            item.title,
            item.body,
            when,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                _channelName,
                importance: Importance.high,
                priority: Priority.high,
                styleInformation: BigTextStyleInformation(item.body),
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: item.payload,
          );
        } catch (e2) {
          debugPrint('Inexact schedule failed: $e2');
        }
      }
    }
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> cancelById(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<int> pendingCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }
}

final notificationsAdapterProvider = Provider<NotificationsAdapter>((ref) {
  return LocalNotificationsAdapter();
});
