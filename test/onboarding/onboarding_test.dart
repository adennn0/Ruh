import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruhun_parliyor/data/repositories/user_profile_repository.dart';
import 'package:ruhun_parliyor/domain/models/enums.dart';

/// OnboardingController form doğrulama ve veri kalıcılığı testleri
void main() {
  late SharedPreferences prefs;
  late UserProfileRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = UserProfileRepository(prefs);
  });

  group('UserProfileRepository — başlangıç durumu', () {
    test('onboardingDone: başlangıçta false', () {
      expect(repo.onboardingDone, false);
    });

    test('consentGiven: başlangıçta false', () {
      expect(repo.consentGiven, false);
    });

    test('loadProfile null döner — veri yokken', () {
      expect(repo.loadProfile(), isNull);
    });
  });

  group('UserProfileRepository — rıza', () {
    test('saveConsent → consentGiven true olur', () async {
      await repo.saveConsent();
      expect(repo.consentGiven, true);
    });
  });

  group('UserProfileRepository — profil kayıt/yükleme', () {
    test('saveProfile → loadProfile tutarlı', () async {
      final profile = UserProfile(
        birthDate: DateTime(1995, 4, 15),
        birthTimeKnown: true,
        birthHour: 14,
        birthMinute: 30,
        displayName: 'Elif',
        tone: MessageTone.spiritual,
        themeId: 'amethystAurora',
      );
      await repo.saveProfile(profile);
      expect(repo.onboardingDone, true);

      final loaded = repo.loadProfile();
      expect(loaded, isNotNull);
      expect(loaded!.birthDate.year, 1995);
      expect(loaded.birthDate.month, 4);
      expect(loaded.birthDate.day, 15);
      expect(loaded.birthTimeKnown, true);
      expect(loaded.birthHour, 14);
      expect(loaded.birthMinute, 30);
      expect(loaded.displayName, 'Elif');
      expect(loaded.tone, MessageTone.spiritual);
      expect(loaded.themeId, 'amethystAurora');
    });

    test('displayName null olarak kaydedilebilir', () async {
      await repo.saveProfile(UserProfile(
        birthDate: DateTime(1990, 1, 1),
        birthTimeKnown: false,
        tone: MessageTone.soft,
        themeId: 'amethystAurora',
      ));
      expect(repo.loadProfile()!.displayName, isNull);
    });

    test('saveTone tonu günceller', () async {
      await repo.saveProfile(UserProfile(
        birthDate: DateTime(1990, 1, 1),
        birthTimeKnown: false,
        tone: MessageTone.spiritual,
        themeId: 'amethystAurora',
      ));
      await repo.saveTone(MessageTone.strong);
      expect(repo.loadProfile()!.tone, MessageTone.strong);
    });

    test('saveThemeId temaId günceller', () async {
      await repo.saveProfile(UserProfile(
        birthDate: DateTime(1990, 1, 1),
        birthTimeKnown: false,
        tone: MessageTone.spiritual,
        themeId: 'amethystAurora',
      ));
      await repo.saveThemeId('pearlMoon');
      expect(repo.loadProfile()!.themeId, 'pearlMoon');
    });

    test('clearAll KVKK silme hakkı — her şeyi siler', () async {
      await repo.saveConsent();
      await repo.saveProfile(UserProfile(
        birthDate: DateTime(1990, 1, 1),
        birthTimeKnown: false,
        tone: MessageTone.rational,
        themeId: 'amethystAurora',
      ));
      await repo.clearAll();
      expect(repo.onboardingDone, false);
      expect(repo.consentGiven, false);
      expect(repo.loadProfile(), isNull);
    });
  });

  group('UserProfile.zodiacSign — güneş burcu hesaplama', () {
    UserProfile profile(DateTime d) => UserProfile(
          birthDate: d,
          birthTimeKnown: false,
          tone: MessageTone.spiritual,
          themeId: 'amethystAurora',
        );

    test('15 Nisan → Koç', () {
      expect(profile(DateTime(1990, 4, 15)).zodiacSign.displayName, 'Koç');
    });

    test('30 Mayıs → İkizler', () {
      expect(profile(DateTime(1990, 5, 30)).zodiacSign.displayName, 'İkizler');
    });

    test('15 Temmuz → Yengeç', () {
      expect(profile(DateTime(1990, 7, 15)).zodiacSign.displayName, 'Yengeç');
    });

    test('25 Aralık → Oğlak', () {
      expect(profile(DateTime(1990, 12, 25)).zodiacSign.displayName, 'Oğlak');
    });

    test('1 Ocak → Oğlak', () {
      expect(profile(DateTime(1990, 1, 1)).zodiacSign.displayName, 'Oğlak');
    });

    test('10 Şubat → Kova', () {
      expect(profile(DateTime(1990, 2, 10)).zodiacSign.displayName, 'Kova');
    });

    test('20 Şubat → Balık', () {
      expect(profile(DateTime(1990, 2, 20)).zodiacSign.displayName, 'Balık');
    });

    // Sınır günü: 21 Haziran İkizler veya Yengeç olabilir
    test('21 Haziran → İkizler veya Yengeç (sınır günü)', () {
      final sign = profile(DateTime(1990, 6, 21)).zodiacSign.displayName;
      expect(['İkizler', 'Yengeç'], contains(sign));
    });
  });

  group('UserProfile.spiritAnimalPeriod — ruh hayvanı zaman dilimi', () {
    UserProfile profileWithTime(int hour) => UserProfile(
          birthDate: DateTime(1990, 4, 15),
          birthTimeKnown: true,
          birthHour: hour,
          birthMinute: 0,
          tone: MessageTone.spiritual,
          themeId: 'amethystAurora',
        );

    test('Saat bilinmiyorsa → Gün', () {
      final p = UserProfile(
        birthDate: DateTime(1990, 4, 15),
        birthTimeKnown: false,
        tone: MessageTone.spiritual,
        themeId: 'amethystAurora',
      );
      expect(p.spiritAnimalPeriod.displayName, 'Gün');
    });

    test('Saat 5 → Şafak', () {
      expect(profileWithTime(5).spiritAnimalPeriod.displayName, 'Şafak');
    });

    test('Saat 12 → Gün', () {
      expect(profileWithTime(12).spiritAnimalPeriod.displayName, 'Gün');
    });

    test('Saat 18 → Akşam', () {
      expect(profileWithTime(18).spiritAnimalPeriod.displayName, 'Akşam');
    });

    test('Saat 23 → Gece', () {
      expect(profileWithTime(23).spiritAnimalPeriod.displayName, 'Gece');
    });
  });

  group('MessageTone enum — bütünlük', () {
    test('Tüm tonların displayName, subtitle ve example değeri var', () {
      for (final tone in MessageTone.values) {
        expect(tone.displayName.isNotEmpty, true,
            reason: '${tone.name} displayName');
        expect(tone.subtitle.isNotEmpty, true, reason: '${tone.name} subtitle');
        expect(tone.example.isNotEmpty, true, reason: '${tone.name} example');
      }
    });

    test('4 ton mevcut', () {
      expect(MessageTone.values.length, 4);
    });
  });
}
