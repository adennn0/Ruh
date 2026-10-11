import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../limits.dart';

/// Premium katmanı
enum EntitlementTier { free, premium }

/// Her özellik için entitlement anahtarları.
enum AppFeature {
  // Bildirimler
  dailyNotifications,
  nightNotifications,
  customNotificationTimes,
  // Niyetler
  activeIntentions,
  // AI Rehber
  dailyMessages,
  priorityAiQueue,
  messageCooldown,
  // İçerik yenileme
  messageRefresh,
  // Uyumluluk
  savedPersons,
  compatDetailedReport,
  // Taşlar / hayvan
  moonRisingStone,
  deepAnimalReading,
  // Günlük
  journalSearch,
  journalStats,
  // Ay takvimi
  moonIntentionSuggestion,
  // Temalar (her premium tema ayrı feature olarak değil, tek kapı)
  premiumThemes,
  // Kedi
  premiumCatCosmetics,
  // Widget
  catWidget,
  premiumWidgetThemes,
  // Derin mesaj
  deepDailyMessage,
  personalEnergyFlow,
  // Ay/yükselen
  moonAndRising,
}

/// Kullanıcının entitlement durumunu yöneten servis.
/// Tüm premium/ücretsiz kararları buradan geçer.
/// Debug build'de geliştirici anahtarı ile açılıp kapatılabilir.
class EntitlementService extends ChangeNotifier {
  EntitlementService(this._prefs);

  final SharedPreferences _prefs;
  static const _tierKey = 'entitlement_tier';

  // ─── DEBUG anahtarı (sadece kDebugMode'da) ───────────────────────────────
  bool _debugOverridePremium = false;

  EntitlementTier get tier {
    if (kDebugMode && _debugOverridePremium) return EntitlementTier.premium;
    final stored = _prefs.getString(_tierKey);
    return stored == 'premium' ? EntitlementTier.premium : EntitlementTier.free;
  }

  bool get isPremium => tier == EntitlementTier.premium;
  bool get isFree => tier == EntitlementTier.free;

  // Debug only
  bool get debugPremiumEnabled => kDebugMode && _debugOverridePremium;

  void toggleDebugPremium() {
    assert(
        kDebugMode, 'toggleDebugPremium sadece debug build\'de kullanılabilir');
    _debugOverridePremium = !_debugOverridePremium;
    notifyListeners();
  }

  /// Gerçek abonelik bilgisi gelince çağrılır (Aşama 7)
  Future<void> setPremium({required bool active}) async {
    await _prefs.setString(_tierKey, active ? 'premium' : 'free');
    notifyListeners();
  }

  /// Belirli bir özellik kullanılabilir mi?
  bool isFeatureAvailable(AppFeature feature) {
    if (isPremium) return true;
    // Ücretsizde açık özellikler
    return _freeFeatures.contains(feature);
  }

  /// Bir özellik için sayısal limit. -1 = sınırsız.
  int limitFor(AppFeature feature) {
    if (isPremium) {
      return _premiumLimits[feature] ?? -1;
    }
    return _freeLimits[feature] ?? 0;
  }

  static const _freeFeatures = {
    AppFeature.dailyNotifications,
    AppFeature.activeIntentions,
    AppFeature.dailyMessages,
    AppFeature.messageCooldown,
    AppFeature.messageRefresh,
    AppFeature.savedPersons,
    AppFeature.personalEnergyFlow,
  };

  static const _freeLimits = {
    AppFeature.dailyNotifications: AppLimits.freeMaxDailyNotifications,
    AppFeature.activeIntentions: AppLimits.freeMaxActiveIntentions,
    AppFeature.dailyMessages: AppLimits.freeMaxDailyMessages,
    AppFeature.messageCooldown: AppLimits.freeCooldownSeconds,
    AppFeature.messageRefresh: AppLimits.freeMaxDailyMessageRefresh,
    AppFeature.savedPersons: AppLimits.freeMaxSavedPersons,
    AppFeature.personalEnergyFlow: AppLimits.freeEnergyFlowPreviewSlots,
  };

  static const _premiumLimits = {
    AppFeature.dailyNotifications: AppLimits.premiumMaxDailyNotifications,
    AppFeature.nightNotifications: AppLimits.premiumNightReminderCount,
    AppFeature.activeIntentions: AppLimits.premiumMaxActiveIntentions,
    AppFeature.dailyMessages: AppLimits.premiumMaxDailyMessages,
    AppFeature.messageCooldown: AppLimits.premiumCooldownSeconds,
    AppFeature.messageRefresh: AppLimits.premiumMaxDailyMessageRefresh,
    AppFeature.savedPersons: AppLimits.premiumMaxSavedPersons,
    AppFeature.personalEnergyFlow: AppLimits.premiumEnergyFlowSlots,
  };
}

// ─── Riverpod Provider'ları ──────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final entitlementServiceProvider =
    ChangeNotifierProvider<EntitlementService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EntitlementService(prefs);
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(entitlementServiceProvider).isPremium;
});
