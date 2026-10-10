import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/entitlement/entitlement.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/models/enums.dart';

// ─── Anahtarlar ────────────────────────────────────────────────────────────────
class _Keys {
  static const onboardingDone = 'onboarding_done';
  static const consentAcceptedAt = 'consent_accepted_at';
  static const birthDate = 'birth_date_iso'; // "YYYY-MM-DD"
  static const birthTimeKnown = 'birth_time_known';
  static const birthHour = 'birth_hour';
  static const birthMinute = 'birth_minute';
  static const displayName = 'display_name';
  static const messageTone = 'message_tone';
  static const themeId = 'theme_id';
}

// ─── UserProfile value object ─────────────────────────────────────────────────
class UserProfile {
  const UserProfile({
    required this.birthDate,
    required this.birthTimeKnown,
    this.birthHour,
    this.birthMinute,
    this.displayName,
    required this.tone,
    required this.themeId,
  });

  final DateTime birthDate;
  final bool birthTimeKnown;
  final int? birthHour;
  final int? birthMinute;
  final String? displayName;
  final MessageTone tone;
  final String themeId;

  /// Güneş burcu (deterministik)
  ZodiacSign get zodiacSign =>
      const AstrologyEngineImpl().sunSign(birthDate).sunSign;

  /// Doğum saati mevcut ve geçerliyse: doğum saatinden ruh hayvanı zamanı
  SpiritAnimalTimePeriod get spiritAnimalPeriod =>
      birthTimeKnown && birthHour != null
          ? SpiritAnimalTimePeriod.fromHour(birthHour!)
          : SpiritAnimalTimePeriod.day;

  UserProfile copyWith({
    DateTime? birthDate,
    bool? birthTimeKnown,
    int? birthHour,
    int? birthMinute,
    String? displayName,
    MessageTone? tone,
    String? themeId,
  }) {
    return UserProfile(
      birthDate: birthDate ?? this.birthDate,
      birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
      birthHour: birthHour ?? this.birthHour,
      birthMinute: birthMinute ?? this.birthMinute,
      displayName: displayName ?? this.displayName,
      tone: tone ?? this.tone,
      themeId: themeId ?? this.themeId,
    );
  }
}

// ─── Repository ────────────────────────────────────────────────────────────────
class UserProfileRepository {
  UserProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  bool get onboardingDone => _prefs.getBool(_Keys.onboardingDone) ?? false;
  bool get consentGiven => _prefs.getString(_Keys.consentAcceptedAt) != null;

  Future<void> saveConsent() async {
    await _prefs.setString(
      _Keys.consentAcceptedAt,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> saveProfile(UserProfile p) async {
    await _prefs.setString(_Keys.birthDate, p.birthDate.toIso8601String());
    await _prefs.setBool(_Keys.birthTimeKnown, p.birthTimeKnown);
    if (p.birthHour != null) await _prefs.setInt(_Keys.birthHour, p.birthHour!);
    if (p.birthMinute != null) {
      await _prefs.setInt(_Keys.birthMinute, p.birthMinute!);
    }
    if (p.displayName != null) {
      await _prefs.setString(_Keys.displayName, p.displayName!);
    }
    await _prefs.setString(_Keys.messageTone, p.tone.name);
    await _prefs.setString(_Keys.themeId, p.themeId);
    await _prefs.setBool(_Keys.onboardingDone, true);
  }

  Future<void> saveTone(MessageTone tone) async {
    await _prefs.setString(_Keys.messageTone, tone.name);
  }

  Future<void> saveThemeId(String themeId) async {
    await _prefs.setString(_Keys.themeId, themeId);
  }

  UserProfile? loadProfile() {
    final dateStr = _prefs.getString(_Keys.birthDate);
    if (dateStr == null) return null;

    final toneName = _prefs.getString(_Keys.messageTone) ?? 'spiritual';
    final tone = MessageTone.values.firstWhere(
      (t) => t.name == toneName,
      orElse: () => MessageTone.spiritual,
    );

    return UserProfile(
      birthDate: DateTime.parse(dateStr),
      birthTimeKnown: _prefs.getBool(_Keys.birthTimeKnown) ?? false,
      birthHour: _prefs.getInt(_Keys.birthHour),
      birthMinute: _prefs.getInt(_Keys.birthMinute),
      displayName: _prefs.getString(_Keys.displayName),
      tone: tone,
      themeId: _prefs.getString(_Keys.themeId) ?? 'amethystAurora',
    );
  }

  /// Tüm kullanıcı verilerini sil (KVKK silme hakkı)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserProfileRepository(prefs);
});

final userProfileProvider = StateProvider<UserProfile?>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.loadProfile();
});

/// Onboarding tamamlandı mı?
final onboardingDoneProvider = Provider<bool>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.onboardingDone;
});
