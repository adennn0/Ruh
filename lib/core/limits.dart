/// Tüm sayısal limitler tek dosyada.
/// Bu sayılar EntitlementService ve UI tarafından buradan okunur.
/// Hiçbir yerde hardcode limit yazılmaz.
library limits;

class AppLimits {
  AppLimits._();

  // ─── Bildirimler ──────────────────────────────────────────────────────────
  static const int freeMaxDailyNotifications = 2;
  static const int premiumMaxDailyNotifications = 8;

  /// iOS uyumlu kayan pencere (gün)
  static const int notificationWindowDays = 7;

  /// Varsayılan sessiz saat başlangıcı (saat)
  static const int defaultQuietHoursStart = 22;

  /// Varsayılan sessiz saat bitişi (saat)
  static const int defaultQuietHoursEnd = 8;

  // ─── Niyetler ─────────────────────────────────────────────────────────────
  static const int freeMaxActiveIntentions = 3;
  static const int premiumMaxActiveIntentions = -1; // sınırsız

  // ─── AI Rehber ────────────────────────────────────────────────────────────
  static const int freeMaxDailyMessages = 5;
  static const int premiumMaxDailyMessages = 50;

  /// Saniye cinsinden bekleme süresi (cooldown)
  static const int freeCooldownSeconds = 30;
  static const int premiumCooldownSeconds = 10;

  // ─── Günlük içerik yenileme ───────────────────────────────────────────────
  static const int freeMaxDailyMessageRefresh = 1; // ücretsiz günde 1 yenileme
  static const int premiumMaxDailyMessageRefresh = -1; // sınırsız

  // ─── Kayıtlı kişi (uyumluluk) ────────────────────────────────────────────
  static const int freeMaxSavedPersons = 3;
  static const int premiumMaxSavedPersons = -1; // sınırsız

  // ─── Işık Serisi dinlenme ─────────────────────────────────────────────────
  /// Her hafta 1 kaçırma seriyi korur (pazartesi başlangıçlı)
  static const int streakRestDaysPerWeek = 1;

  // ─── İçerik tekrarlama ────────────────────────────────────────────────────
  /// Son N günde gösterilen içerik tekrarlanmaz
  static const int contentNoRepeatDays = 7;

  // ─── API zaman aşımı ─────────────────────────────────────────────────────
  static const Duration aiRequestTimeout = Duration(seconds: 20);
  static const int aiRetryMaxAttempts = 2;

  // ─── Parçacık efekti ─────────────────────────────────────────────────────
  static const int maxParticleCount = 60;
}
