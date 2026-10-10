import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/domain/compatibility/compatibility_engine.dart';
import 'package:ruhun_parliyor/domain/astrology/astrology_engine.dart';

void main() {
  late CompatibilityEngine engine;

  setUp(() {
    engine = CompatibilityEngine();
  });

  test('1. Skor simetrisi: calculate(a,b).score == calculate(b,a).score', () {
    for (var sign1 in ZodiacSign.values) {
      for (var sign2 in ZodiacSign.values) {
        final score1 = engine.calculate(sign1, sign2).score;
        final score2 = engine.calculate(sign2, sign1).score;
        expect(score1, score2, reason: 'Skor simetrisi hatalı: $sign1 - $sign2');
      }
    }
  });

  test('2. Aynı burç: always returns 78', () {
    for (var sign in ZodiacSign.values) {
      final res = engine.calculate(sign, sign);
      expect(res.score, 78);
    }
  });

  test('3. Skor aralığı: 40-95 sınırlarında', () {
    for (var sign1 in ZodiacSign.values) {
      for (var sign2 in ZodiacSign.values) {
        final res = engine.calculate(sign1, sign2);
        expect(res.score >= 40 && res.score <= 95, isTrue, reason: '${res.score} out of range for $sign1-$sign2');
      }
    }
  });

  test('4. Etiket doğruluğu', () {
    expect(engine.compatibilityLabel(85), 'Yüksek akış');
    expect(engine.compatibilityLabel(90), 'Yüksek akış');
    expect(engine.compatibilityLabel(70), 'Uyumlu ritim');
    expect(engine.compatibilityLabel(84), 'Uyumlu ritim');
    expect(engine.compatibilityLabel(55), 'Öğretici denge');
    expect(engine.compatibilityLabel(69), 'Öğretici denge');
    expect(engine.compatibilityLabel(40), 'Dönüştürücü bağ');
    expect(engine.compatibilityLabel(54), 'Dönüştürücü bağ');
  });

  test('5. Specific cases: Aries-Leo', () {
    // Fire-Fire (80), Cardinal-Fixed (+2) = 82 -> Uyumlu ritim
    final res = engine.calculate(ZodiacSign.aries, ZodiacSign.leo);
    expect(res.score, 82);
    expect(res.label, 'Uyumlu ritim');
  });

  test('6. Specific cases: Aries-Libra', () {
    // Fire-Air (88), Cardinal-Cardinal (-3) = 85 -> Yüksek akış
    final res = engine.calculate(ZodiacSign.aries, ZodiacSign.libra);
    expect(res.score, 85);
    expect(res.label, 'Yüksek akış');
  });
}
