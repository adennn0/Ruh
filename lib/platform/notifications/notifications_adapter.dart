import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bildirim platform adaptörü arayüzü.
/// Tüm bildirim planlama mantığı bu adaptörün arkasında durur.
/// UI ve domain katmanı Android/iOS API'sini doğrudan çağırmaz.
abstract class NotificationsAdapter {
  /// İzin iste (yalnızca kullanıcı ilk kez bildirim açmak istediğinde)
  Future<bool> requestPermission();

  /// Mevcut bildirim iznini kontrol et
  Future<bool> hasPermission();

  /// Önümüzdeki 7 günlük kayan pencereyi planla
  Future<void> scheduleWindow({
    required List<ScheduledNotification> notifications,
  });

  /// Tüm planlanmış bildirimleri iptal et
  Future<void> cancelAll();

  /// Belirli ID'li bildirimi iptal et
  Future<void> cancelById(int id);

  /// Kaç bildirim planlanmış?
  Future<int> pendingCount();
}

class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
}

/// flutter_local_notifications tabanlı uygulama
/// Gerçek implementasyon Aşama 3'te tamamlanacak
class LocalNotificationsAdapter implements NotificationsAdapter {
  @override
  Future<bool> requestPermission() async {
    // TODO Aşama 3: flutter_local_notifications + timezone
    return false;
  }

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> scheduleWindow({
    required List<ScheduledNotification> notifications,
  }) async {
    // TODO Aşama 3
  }

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancelById(int id) async {}

  @override
  Future<int> pendingCount() async => 0;
}

final notificationsAdapterProvider = Provider<NotificationsAdapter>((ref) {
  return LocalNotificationsAdapter();
});
