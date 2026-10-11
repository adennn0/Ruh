/// Astroloji hesaplama katmanı.
/// Tüm değerler deterministik ve hesaplanır; AI'a bırakılmaz.
library astrology_engine;

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'moon_phase_calculator.dart';

// ─── Burç ────────────────────────────────────────────────────────────────────
enum ZodiacSign {
  aries, // Koç
  taurus, // Boğa
  gemini, // İkizler
  cancer, // Yengeç
  leo, // Aslan
  virgo, // Başak
  libra, // Terazi
  scorpio, // Akrep
  sagittarius, // Yay
  capricorn, // Oğlak
  aquarius, // Kova
  pisces; // Balık

  String get displayName => switch (this) {
        ZodiacSign.aries => 'Koç',
        ZodiacSign.taurus => 'Boğa',
        ZodiacSign.gemini => 'İkizler',
        ZodiacSign.cancer => 'Yengeç',
        ZodiacSign.leo => 'Aslan',
        ZodiacSign.virgo => 'Başak',
        ZodiacSign.libra => 'Terazi',
        ZodiacSign.scorpio => 'Akrep',
        ZodiacSign.sagittarius => 'Yay',
        ZodiacSign.capricorn => 'Oğlak',
        ZodiacSign.aquarius => 'Kova',
        ZodiacSign.pisces => 'Balık',
      };

  String get symbol => switch (this) {
        ZodiacSign.aries => '♈',
        ZodiacSign.taurus => '♉',
        ZodiacSign.gemini => '♊',
        ZodiacSign.cancer => '♋',
        ZodiacSign.leo => '♌',
        ZodiacSign.virgo => '♍',
        ZodiacSign.libra => '♎',
        ZodiacSign.scorpio => '♏',
        ZodiacSign.sagittarius => '♐',
        ZodiacSign.capricorn => '♑',
        ZodiacSign.aquarius => '♒',
        ZodiacSign.pisces => '♓',
      };

  ZodiacElement get element => switch (this) {
        ZodiacSign.aries ||
        ZodiacSign.leo ||
        ZodiacSign.sagittarius =>
          ZodiacElement.fire,
        ZodiacSign.taurus ||
        ZodiacSign.virgo ||
        ZodiacSign.capricorn =>
          ZodiacElement.earth,
        ZodiacSign.gemini ||
        ZodiacSign.libra ||
        ZodiacSign.aquarius =>
          ZodiacElement.air,
        ZodiacSign.cancer ||
        ZodiacSign.scorpio ||
        ZodiacSign.pisces =>
          ZodiacElement.water,
      };

  ZodiacModality get modality => switch (this) {
        ZodiacSign.aries ||
        ZodiacSign.cancer ||
        ZodiacSign.libra ||
        ZodiacSign.capricorn =>
          ZodiacModality.cardinal,
        ZodiacSign.taurus ||
        ZodiacSign.leo ||
        ZodiacSign.scorpio ||
        ZodiacSign.aquarius =>
          ZodiacModality.fixed,
        ZodiacSign.gemini ||
        ZodiacSign.virgo ||
        ZodiacSign.sagittarius ||
        ZodiacSign.pisces =>
          ZodiacModality.mutable,
      };

  String get rulingPlanet => switch (this) {
        ZodiacSign.aries => 'Mars',
        ZodiacSign.taurus => 'Venüs',
        ZodiacSign.gemini => 'Merkür',
        ZodiacSign.cancer => 'Ay',
        ZodiacSign.leo => 'Güneş',
        ZodiacSign.virgo => 'Merkür',
        ZodiacSign.libra => 'Venüs',
        ZodiacSign.scorpio => 'Plüton',
        ZodiacSign.sagittarius => 'Jüpiter',
        ZodiacSign.capricorn => 'Satürn',
        ZodiacSign.aquarius => 'Uranüs',
        ZodiacSign.pisces => 'Neptün',
      };

  String get energyTheme => switch (this) {
        ZodiacSign.aries => 'Öncülük ve cesaret',
        ZodiacSign.taurus => 'Sabır ve kararlılık',
        ZodiacSign.gemini => 'Merak ve uyumluluk',
        ZodiacSign.cancer => 'Sezgi ve koruma',
        ZodiacSign.leo => 'Yaratıcılık ve ifade',
        ZodiacSign.virgo => 'Titizlik ve hizmet',
        ZodiacSign.libra => 'Denge ve uyum',
        ZodiacSign.scorpio => 'Dönüşüm ve derinlik',
        ZodiacSign.sagittarius => 'Özgürlük ve bilgelik',
        ZodiacSign.capricorn => 'Sorumluluk ve azim',
        ZodiacSign.aquarius => 'Yenilik ve vizyon',
        ZodiacSign.pisces => 'Empati ve hayal gücü',
      };

  /// Güneş taşı (deterministik)
  String get primaryStone => switch (this) {
        ZodiacSign.aries => 'Kırmızı Yaspis',
        ZodiacSign.taurus => 'Gül Kuvars',
        ZodiacSign.gemini => 'Akik',
        ZodiacSign.cancer => 'Ay Taşı',
        ZodiacSign.leo => 'Kaplan Gözü',
        ZodiacSign.virgo => 'Yeşil Aventurin',
        ZodiacSign.libra => 'Opal',
        ZodiacSign.scorpio => 'Obsidyen',
        ZodiacSign.sagittarius => 'Turkuaz',
        ZodiacSign.capricorn => 'Oniks',
        ZodiacSign.aquarius => 'Ametist',
        ZodiacSign.pisces => 'Akuamarin',
      };

  /// Ana ruh hayvanı (deterministik)
  String get primarySpiritAnimal => switch (this) {
        ZodiacSign.aries => 'Şahin',
        ZodiacSign.taurus => 'Ayı',
        ZodiacSign.gemini => 'Kelebek',
        ZodiacSign.cancer => 'Kaplumbağa',
        ZodiacSign.leo => 'Aslan',
        ZodiacSign.virgo => 'Baykuş',
        ZodiacSign.libra => 'Kuğu',
        ZodiacSign.scorpio => 'Yılan',
        ZodiacSign.sagittarius => 'At',
        ZodiacSign.capricorn => 'Dağ Keçisi',
        ZodiacSign.aquarius => 'Kuzgun',
        ZodiacSign.pisces => 'Yunus',
      };
}

// ─── Element ──────────────────────────────────────────────────────────────────
enum ZodiacElement {
  fire,
  earth,
  air,
  water;

  String get displayName => switch (this) {
        ZodiacElement.fire => 'Ateş',
        ZodiacElement.earth => 'Toprak',
        ZodiacElement.air => 'Hava',
        ZodiacElement.water => 'Su',
      };

  String get symbol => switch (this) {
        ZodiacElement.fire => '🔥',
        ZodiacElement.earth => '🌿',
        ZodiacElement.air => '💨',
        ZodiacElement.water => '💧',
      };
}

// ─── Nitelik ──────────────────────────────────────────────────────────────────
enum ZodiacModality {
  cardinal,
  fixed,
  mutable;

  String get displayName => switch (this) {
        ZodiacModality.cardinal => 'Öncü',
        ZodiacModality.fixed => 'Sabit',
        ZodiacModality.mutable => 'Değişken',
      };
}

// ─── Ay Evresi ────────────────────────────────────────────────────────────────
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  String get displayName => switch (this) {
        MoonPhase.newMoon => 'Yeni Ay',
        MoonPhase.waxingCrescent => 'Hilal',
        MoonPhase.firstQuarter => 'İlk Dördün',
        MoonPhase.waxingGibbous => 'Büyüyen Ay',
        MoonPhase.fullMoon => 'Dolunay',
        MoonPhase.waningGibbous => 'Küçülen Ay',
        MoonPhase.lastQuarter => 'Son Dördün',
        MoonPhase.waningCrescent => 'Küçük Hilal',
      };

  String get symbol => switch (this) {
        MoonPhase.newMoon => '🌑',
        MoonPhase.waxingCrescent => '🌒',
        MoonPhase.firstQuarter => '🌓',
        MoonPhase.waxingGibbous => '🌔',
        MoonPhase.fullMoon => '🌕',
        MoonPhase.waningGibbous => '🌖',
        MoonPhase.lastQuarter => '🌗',
        MoonPhase.waningCrescent => '🌘',
      };

  String get intentionTheme => switch (this) {
        MoonPhase.newMoon => 'Niyet başlat, yeni tohumlar ek',
        MoonPhase.waxingCrescent => 'Niyetleri besle, harekete geç',
        MoonPhase.firstQuarter => 'Engelleri aş, kararlar al',
        MoonPhase.waxingGibbous => 'Geliştir, ince ayar yap',
        MoonPhase.fullMoon => 'Farkındalık, tamamlama, bırakma',
        MoonPhase.waningGibbous => 'Şükran ve paylaşım',
        MoonPhase.lastQuarter => 'Bırak, affet, temizle',
        MoonPhase.waningCrescent => 'Dinlen, geri çekil, hazırlan',
      };
}

// ─── Kozmik Kimlik ─────────────────────────────────────────────────────────────
class CosmicIdentity extends Equatable {
  const CosmicIdentity({
    required this.sunSign,
    this.isBorderDay = false,
  });

  final ZodiacSign sunSign;

  /// Sınır günü uyarısı gösterilsin mi?
  final bool isBorderDay;

  ZodiacElement get element => sunSign.element;
  ZodiacModality get modality => sunSign.modality;
  String get rulingPlanet => sunSign.rulingPlanet;
  String get energyTheme => sunSign.energyTheme;

  @override
  List<Object?> get props => [sunSign, isBorderDay];
}

// ─── Ruh Hayvanı Zaman Dilimi ─────────────────────────────────────────────────
enum SpiritAnimalTimePeriod {
  dawn, // Şafak 04:00–09:59
  day, // Gün   10:00–15:59
  evening, // Akşam 16:00–21:59
  night; // Gece  22:00–03:59

  String get displayName => switch (this) {
        SpiritAnimalTimePeriod.dawn => 'Şafak',
        SpiritAnimalTimePeriod.day => 'Gün',
        SpiritAnimalTimePeriod.evening => 'Akşam',
        SpiritAnimalTimePeriod.night => 'Gece',
      };

  static SpiritAnimalTimePeriod fromHour(int hour) {
    if (hour >= 4 && hour < 10) return SpiritAnimalTimePeriod.dawn;
    if (hour >= 10 && hour < 16) return SpiritAnimalTimePeriod.day;
    if (hour >= 16 && hour < 22) return SpiritAnimalTimePeriod.evening;
    return SpiritAnimalTimePeriod.night;
  }
}

// ─── Astroloji Motoru ─────────────────────────────────────────────────────────
abstract class AstrologyEngine {
  /// Doğum tarihinden güneş burcu hesapla (deterministik)
  CosmicIdentity sunSign(DateTime birthDate);

  /// Verilen tarih ve saat için yerel takvim anındaki ay evresini hesapla.
  MoonPhase moonPhase(DateTime date);

  /// Ruh hayvanı adı (burç + doğum saati dilimi)
  String spiritAnimalName(ZodiacSign sign, SpiritAnimalTimePeriod period);

  // Aşama 8'de implement edilecek
  // MoonSign moonSign(DateTime birthDateTimeUtc);
  // ZodiacSign ascendant(DateTime birthDateTimeUtc, double lat, double lon);
}

class AstrologyEngineImpl implements AstrologyEngine {
  const AstrologyEngineImpl();

  // ─── Güneş burcu hesabı ──────────────────────────────────────────────────
  /// Sınır günleri: ay/gün çifti ±1 gün toleranslı
  static const _signBorders = [
    // (ayBaşlangıç, günBaşlangıç, ayBitiş, günBitiş, burç)
    // Not: Ocak = 1, Aralık = 12
    (3, 21, 4, 19, ZodiacSign.aries),
    (4, 20, 5, 20, ZodiacSign.taurus),
    (5, 21, 6, 20, ZodiacSign.gemini),
    (6, 21, 7, 22, ZodiacSign.cancer),
    (7, 23, 8, 22, ZodiacSign.leo),
    (8, 23, 9, 22, ZodiacSign.virgo),
    (9, 23, 10, 22, ZodiacSign.libra),
    (10, 23, 11, 21, ZodiacSign.scorpio),
    (11, 22, 12, 21, ZodiacSign.sagittarius),
    (12, 22, 1, 19, ZodiacSign.capricorn), // Oğlak yılı aşar
    (1, 20, 2, 18, ZodiacSign.aquarius),
    (2, 19, 3, 20, ZodiacSign.pisces),
  ];

  /// Sınır günleri (ay-gün çifti)
  static const _borderDays = {
    (3, 21),
    (4, 19),
    (4, 20),
    (5, 20),
    (5, 21),
    (6, 20),
    (6, 21),
    (7, 22),
    (7, 23),
    (8, 22),
    (8, 23),
    (9, 22),
    (9, 23),
    (10, 22),
    (10, 23),
    (11, 21),
    (11, 22),
    (12, 21),
    (12, 22),
    (1, 19),
    (1, 20),
    (2, 18),
    (2, 19),
    (3, 20),
  };

  @override
  CosmicIdentity sunSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    final isBorder = _borderDays.contains((month, day));

    for (final (sm, sd, em, ed, sign) in _signBorders) {
      if (_inRange(month, day, sm, sd, em, ed)) {
        return CosmicIdentity(sunSign: sign, isBorderDay: isBorder);
      }
    }
    // Fallback (olmamalı ama güvenlik için)
    return const CosmicIdentity(sunSign: ZodiacSign.aries, isBorderDay: false);
  }

  bool _inRange(int month, int day, int sm, int sd, int em, int ed) {
    // Yılı aşan Oğlak için özel durum
    if (sm > em) {
      return (month == sm && day >= sd) ||
          (month == em && day <= ed) ||
          (month > sm) ||
          (month < em);
    }
    if (month == sm && month == em) return day >= sd && day <= ed;
    if (month == sm) return day >= sd;
    if (month == em) return day <= ed;
    return month > sm && month < em;
  }

  @override
  MoonPhase moonPhase(DateTime date) =>
      const MoonPhaseCalculator().phaseAt(date);

  // ─── Ruh hayvanı ──────────────────────────────────────────────────────────
  @override
  String spiritAnimalName(ZodiacSign sign, SpiritAnimalTimePeriod period) {
    final prefix = period.displayName;
    final animal = sign.primarySpiritAnimal;
    return '$prefix $animal';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final astrologyEngineProvider = Provider<AstrologyEngine>((ref) {
  return const AstrologyEngineImpl();
});
