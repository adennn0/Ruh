/// Tüm sayısal limitler tek dosyada.
/// Bu sayılar EntitlementService ve UI tarafından buradan okunur.
/// Hiçbir yerde hardcode limit yazılmaz.
library limits;

class AppLimits {
  AppLimits._();

  // Bildirimler — çekirdek ürün: kişiselleştirilmiş Saat Anı
  // Ücretsiz: günde 5 özel saat; premium: günde 12.
  static const int freeMaxDailyNotifications = 5;
  static const int premiumMaxDailyNotifications = 12;
  static const int notificationWindowDays = 7;
  static const int defaultQuietHoursStart = 22;
  static const int defaultQuietHoursEnd = 8;

  // Niyetler
  static const int freeMaxActiveIntentions = 3;
  static const int premiumMaxActiveIntentions = -1; // sinirrsiz

  // AI Rehber
  static const int freeMaxDailyMessages = 5;
  static const int premiumMaxDailyMessages = 50;
  static const int freeCooldownSeconds = 30;
  static const int premiumCooldownSeconds = 10;

  // Gunluk icerik yenileme
  static const int freeMaxDailyMessageRefresh = 1;
  static const int premiumMaxDailyMessageRefresh = -1;

  // Kayitli kisi (uyumluluk)
  static const int freeMaxSavedPersons = 3;
  static const int premiumMaxSavedPersons = -1;

  // Kişiye özel sembolik günlük plan: ücretsiz kısa önizleme, premium tam akış.
  static const int freeEnergyFlowPreviewSlots = 1;
  static const int premiumEnergyFlowSlots = 3;

  // Isik Serisi dinlenme
  static const int streakRestDaysPerWeek = 1;

  // Isik Serisi kilometre taslari
  static const List<int> streakMilestones = [3, 7, 14, 21, 49, 100, 365];

  // Icerik tekrarlama
  static const int contentNoRepeatDays = 7;

  // Icerik kutuphanesi minimum
  static const int minContentPerSignTone = 7;

  // API zaman asimi
  static const Duration aiRequestTimeout = Duration(seconds: 20);
  static const int aiRetryMaxAttempts = 2;

  // UI limitleri
  static const int maxChatHistoryDisplay = 100;
  static const String guideCounterKeyPrefix = 'guide_count_';

  // Parcacik efekti
  static const int maxParticleCount = 60;
}
