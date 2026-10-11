import '../../core/stable_hash.dart';
import '../astrology/astrology_engine.dart';
import '../models/enums.dart';

class PersonalEnergyWindow {
  const PersonalEnergyWindow({
    required this.time,
    required this.title,
    required this.energy,
    required this.focus,
    required this.reflection,
  });

  final String time;
  final String title;
  final int energy;
  final int focus;
  final String reflection;
}

/// A deterministic, symbolic daily planning guide, not a forecast or diagnosis.
class PersonalEnergyFlow {
  const PersonalEnergyFlow._();

  static const _periods = [
    ('09:00', 'Güne başlarken'),
    ('14:00', 'Günün ortasında'),
    ('19:00', 'Günü tamamlarken'),
  ];

  static List<PersonalEnergyWindow> forDate({
    required DateTime date,
    required ZodiacSign sign,
    required MessageTone tone,
    required String personalSalt,
  }) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final tonePrompts = _promptsFor(tone);
    return List.generate(_periods.length, (index) {
      final (time, title) = _periods[index];
      final seed = stableHashParts([
        dateKey,
        sign.index,
        tone.index,
        personalSalt,
        index,
      ]);
      final energy = 2 + seed.abs() % 4;
      final focus = 2 + (seed ~/ 7).abs() % 4;
      final promptIndex = (seed ~/ 13).abs() % tonePrompts.length;
      final reflection = tonePrompts[promptIndex]
          .replaceAll('{sign}', sign.displayName)
          .replaceAll('{theme}', sign.energyTheme.toLowerCase());
      return PersonalEnergyWindow(
        time: time,
        title: title,
        energy: energy,
        focus: focus,
        reflection: reflection,
      );
    }, growable: false);
  }

  static List<String> _promptsFor(MessageTone tone) => switch (tone) {
        MessageTone.soft => const [
            '{sign}, bugün kendi temponu gözeterek hangi küçük işi seçebilirsin?',
            '{theme} temasını düşün: kendine biraz daha alan açmanın yolu ne?',
            'Günün bu bölümünde sana iyi gelecek nazik bir sınır hangisi?',
          ],
        MessageTone.strong => const [
            '{sign}: bu zaman aralığında tamamlayacağın tek somut iş ne?',
            '{theme} odağını seç ve ona ayıracağın kısa zamanı belirle.',
            'Bugün ilerleme sayacağın küçük, ölçülebilir adım hangisi?',
          ],
        MessageTone.spiritual => const [
            '{sign} temasını kişisel bir düşünme başlığı olarak al; bugün neye yer açmak istersin?',
            '{theme} üzerine düşün: günün hangi anında kendine dönmek istersin?',
            'Bu aralıkta niyetini destekleyen sade bir davranış seçebilirsin.',
          ],
        MessageTone.rational => const [
            '{sign} ve {theme} yalnızca sembolik başlıklar; bugünkü önceliğini hangi bilgi belirliyor?',
            'Bu zaman aralığı için gerçekçi hedefini ve bitiş ölçütünü yaz.',
            'Enerjini koruyacak planlı bir mola için hangi saati ayırabilirsin?',
          ],
      };
}
