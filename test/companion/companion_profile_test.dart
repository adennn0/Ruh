import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/features/companion/companion_profile.dart';

void main() {
  group('CompanionProfile', () {
    test('JSON round trip preserves the selected companion', () {
      const profile = CompanionProfile(
        name: 'Luna',
        species: 'Kuzgun',
        coat: 'İnci',
        eyeColor: 'Turkuaz',
        equippedCosmetic: 'hilal-kolye',
        equippedItems: {'kolye': 'hilal-kolye', 'aura': 'yildiz-isigi'},
      );

      final restored = CompanionProfile.decode(jsonEncode(profile.toJson()));

      expect(restored?.name, 'Luna');
      expect(restored?.species, 'Kuzgun');
      expect(restored?.coat, 'İnci');
      expect(restored?.eyeColor, 'Turkuaz');
      expect(restored?.equippedCosmetic, 'hilal-kolye');
      expect(restored?.equippedItems['kolye'], 'hilal-kolye');
      expect(restored?.equippedItems['aura'], 'yildiz-isigi');
    });

    test('older saved profiles migrate their equipped cosmetic to aura slot', () {
      final restored = CompanionProfile.decode(
        '{"name":"Luna","species":"Kuzgun","equippedCosmetic":"yildiz-halesi"}',
      );
      expect(restored?.equippedItems, {'aura': 'yildiz-halesi'});
    });
  });

  group('CompanionCosmetic', () {
    test('milestone unlocks remain based on the all-time best streak', () {
      const item = CompanionCosmetic(
        id: 'hilal-kolye',
        name: 'Hilal Kolye',
        milestone: 3,
        description: '3 günlük en uzun seride açılır',
        slot: 'kolye',
      );

      expect(item.isUnlocked(2), isFalse);
      expect(item.isUnlocked(3), isTrue);
      expect(item.isUnlocked(14), isTrue);
    });

    test('all documented milestone levels are represented', () {
      expect(
        companionCosmetics.map((item) => item.milestone).toList(),
        [0, 3, 7, 14, 21, 49, 100, 365],
      );
      expect(companionCosmetics.last.isUnlocked(365), isTrue);
      expect(companionCosmetics.last.isUnlocked(364), isFalse);
      expect(companionCosmetics.map((item) => item.slot).toSet(),
          containsAll(['aura', 'kolye', 'pelerin', 'şapka', 'atkı', 'gözlük']));
    });
  });
}
