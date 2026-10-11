import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/domain/astrology/astrology_engine.dart';
import 'package:ruhun_parliyor/domain/astrology/moon_phase_calculator.dart';

void main() {
  const engine = AstrologyEngineImpl();

  group('Güneş Burcu Hesabı', () {
    test('Koç — 21 Mart', () {
      final result = engine.sunSign(DateTime(2000, 3, 21));
      expect(result.sunSign, ZodiacSign.aries);
    });

    test('Boğa — 20 Nisan', () {
      final result = engine.sunSign(DateTime(2000, 4, 20));
      expect(result.sunSign, ZodiacSign.taurus);
    });

    test('İkizler — 21 Mayıs', () {
      final result = engine.sunSign(DateTime(2000, 5, 21));
      expect(result.sunSign, ZodiacSign.gemini);
    });

    test('Yengeç — 21 Haziran', () {
      final result = engine.sunSign(DateTime(2000, 6, 21));
      expect(result.sunSign, ZodiacSign.cancer);
    });

    test('Aslan — 23 Temmuz', () {
      final result = engine.sunSign(DateTime(2000, 7, 23));
      expect(result.sunSign, ZodiacSign.leo);
    });

    test('Başak — 23 Ağustos', () {
      final result = engine.sunSign(DateTime(2000, 8, 23));
      expect(result.sunSign, ZodiacSign.virgo);
    });

    test('Terazi — 23 Eylül', () {
      final result = engine.sunSign(DateTime(2000, 9, 23));
      expect(result.sunSign, ZodiacSign.libra);
    });

    test('Akrep — 23 Ekim', () {
      final result = engine.sunSign(DateTime(2000, 10, 23));
      expect(result.sunSign, ZodiacSign.scorpio);
    });

    test('Yay — 22 Kasım', () {
      final result = engine.sunSign(DateTime(2000, 11, 22));
      expect(result.sunSign, ZodiacSign.sagittarius);
    });

    test('Oğlak — 22 Aralık', () {
      final result = engine.sunSign(DateTime(2000, 12, 22));
      expect(result.sunSign, ZodiacSign.capricorn);
    });

    test('Kova — 20 Ocak', () {
      final result = engine.sunSign(DateTime(2000, 1, 20));
      expect(result.sunSign, ZodiacSign.aquarius);
    });

    test('Balık — 19 Şubat', () {
      final result = engine.sunSign(DateTime(2000, 2, 19));
      expect(result.sunSign, ZodiacSign.pisces);
    });

    test('Oğlak — 1 Ocak (yılı aşan)', () {
      final result = engine.sunSign(DateTime(2000, 1, 1));
      expect(result.sunSign, ZodiacSign.capricorn);
    });

    group('Sınır günleri isBorderDay=true döner', () {
      test('21 Mart sınır günü', () {
        final result = engine.sunSign(DateTime(2000, 3, 21));
        expect(result.isBorderDay, true);
      });

      test('4 Nisan sınır günü değil', () {
        final result = engine.sunSign(DateTime(2000, 4, 4));
        expect(result.isBorderDay, false);
      });
    });
  });

  group('Element ve Nitelik', () {
    test('Koç — Ateş, Öncü', () {
      final result = engine.sunSign(DateTime(2000, 4, 1));
      expect(result.element, ZodiacElement.fire);
      expect(result.modality, ZodiacModality.cardinal);
    });

    test('Boğa — Toprak, Sabit', () {
      final result = engine.sunSign(DateTime(2000, 5, 1));
      expect(result.element, ZodiacElement.earth);
      expect(result.modality, ZodiacModality.fixed);
    });

    test('İkizler — Hava, Değişken', () {
      final result = engine.sunSign(DateTime(2000, 6, 1));
      expect(result.element, ZodiacElement.air);
      expect(result.modality, ZodiacModality.mutable);
    });

    test('Yengeç — Su, Öncü', () {
      final result = engine.sunSign(DateTime(2000, 7, 1));
      expect(result.element, ZodiacElement.water);
      expect(result.modality, ZodiacModality.cardinal);
    });
  });

  group('Ay Evresi Hesabı (USNO referansları)', () {
    test('2000-01-06 18:14 UTC Yeni Ay', () {
      final phase = engine.moonPhase(DateTime.utc(2000, 1, 6, 18, 15));
      expect(phase, MoonPhase.newMoon);
    });

    test('2000-01-21 04:40 UTC Dolunay', () {
      final phase = engine.moonPhase(DateTime.utc(2000, 1, 21, 4, 42));
      expect(phase, MoonPhase.fullMoon);
    });

    test('2024-01-11 11:57 UTC Yeni Ay', () {
      final phase = engine.moonPhase(DateTime.utc(2024, 1, 11, 11, 58));
      expect(phase, MoonPhase.newMoon);
    });

    test('2026 USNO primary phases match within two minutes', () {
      const calculator = MoonPhaseCalculator();
      final events = calculator.eventsBetween(
        DateTime.utc(2026, 10, 10),
        DateTime.utc(2026, 11, 2),
      );
      final references = [
        (MoonPhase.newMoon, DateTime.utc(2026, 10, 10, 15, 50)),
        (MoonPhase.firstQuarter, DateTime.utc(2026, 10, 18, 16, 12)),
        (MoonPhase.fullMoon, DateTime.utc(2026, 10, 26, 4, 12)),
        (MoonPhase.lastQuarter, DateTime.utc(2026, 11, 1, 20, 28)),
      ];
      for (final (phase, expectedUtc) in references) {
        final event = events.firstWhere((item) =>
            item.phase == phase &&
            item.localTime.toUtc().day == expectedUtc.day);
        expect(event.localTime.toUtc().difference(expectedUtc).inSeconds.abs(),
            lessThanOrEqualTo(120));
      }
    });
  });

  group('Ruh Hayvanı', () {
    test('Koç + Şafak → Şafak Şahin', () {
      final name = engine.spiritAnimalName(
        ZodiacSign.aries,
        SpiritAnimalTimePeriod.dawn,
      );
      expect(name, 'Şafak Şahin');
    });

    test('Kova + Gece → Gece Kuzgun', () {
      final name = engine.spiritAnimalName(
        ZodiacSign.aquarius,
        SpiritAnimalTimePeriod.night,
      );
      expect(name, 'Gece Kuzgun');
    });
  });

  group('SpiritAnimalTimePeriod.fromHour', () {
    test('Saat 4 → Şafak', () {
      expect(SpiritAnimalTimePeriod.fromHour(4), SpiritAnimalTimePeriod.dawn);
    });

    test('Saat 9 → Şafak', () {
      expect(SpiritAnimalTimePeriod.fromHour(9), SpiritAnimalTimePeriod.dawn);
    });

    test('Saat 10 → Gün', () {
      expect(SpiritAnimalTimePeriod.fromHour(10), SpiritAnimalTimePeriod.day);
    });

    test('Saat 15 → Gün', () {
      expect(SpiritAnimalTimePeriod.fromHour(15), SpiritAnimalTimePeriod.day);
    });

    test('Saat 16 → Akşam', () {
      expect(
          SpiritAnimalTimePeriod.fromHour(16), SpiritAnimalTimePeriod.evening);
    });

    test('Saat 21 → Akşam', () {
      expect(
          SpiritAnimalTimePeriod.fromHour(21), SpiritAnimalTimePeriod.evening);
    });

    test('Saat 22 → Gece', () {
      expect(SpiritAnimalTimePeriod.fromHour(22), SpiritAnimalTimePeriod.night);
    });

    test('Saat 3 → Gece', () {
      expect(SpiritAnimalTimePeriod.fromHour(3), SpiritAnimalTimePeriod.night);
    });

    test('Saat 0 → Gece', () {
      expect(SpiritAnimalTimePeriod.fromHour(0), SpiritAnimalTimePeriod.night);
    });
  });
}
