import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Ä°Ã§erik lint testi â€” yasaklÄ± kalÄ±plar ve uzunluk kontrolleri.
/// Yeni JSON ÅŸemasÄ±: {id, sign, tone, type, text, tags}
/// Bu test baÅŸarÄ±sÄ±z olursa iÃ§erik teslim edilmez (spec BÃ¶lÃ¼m 18.1).
void main() {
  const forbiddenPatterns = [
    'kesinlikle gerÃ§ekleÅŸecek',
    'kesinlikle olacak',
    'iyileÅŸtirir',
    'hastalÄ±ÄŸa iyi gelir',
    'tedavi eder',
    'uÄŸursuz',
    'kÃ¶tÃ¼ ÅŸey olacak',
    'kÃ¶tÃ¼lÃ¼k gelecek',
    'ÅŸifa verir',
    'ÅŸifa bulursun',
    'seni kurtarÄ±r',
    'garanti',
    'kaderinde var',
    'kaÃ§Ä±nÄ±lmaz',
    'mutlaka gerÃ§ekleÅŸir',
    'kesin olarak',
  ];

  const maxMessageLength = 300;
  const maxAffirmationLength = 150;

  const validSigns = {
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
  };
  const validTones = {'soft', 'strong', 'spiritual', 'rational'};
  const validTypes = {'message', 'affirmation'};

  /// Flat entries listesini lint'le
  void lintEntries(List<Map<String, dynamic>> entries) {
    for (final entry in entries) {
      final id = entry['id'] as String? ?? 'unknown';
      final text = entry['text'] as String? ?? '';
      final type = entry['type'] as String? ?? '';

      // Zorunlu alanlar
      expect(entry['id'], isNotNull, reason: 'id eksik: $entry');
      expect(entry['sign'], isNotNull, reason: 'sign eksik: $id');
      expect(entry['tone'], isNotNull, reason: 'tone eksik: $id');
      expect(entry['type'], isNotNull, reason: 'type eksik: $id');
      expect(text.isNotEmpty, true, reason: 'text boÅŸ: $id');

      // GeÃ§erli deÄŸer alanlarÄ±
      expect(
        validSigns.contains(entry['sign']),
        true,
        reason: 'GeÃ§ersiz sign "${entry['sign']}": $id',
      );
      expect(
        validTones.contains(entry['tone']),
        true,
        reason: 'GeÃ§ersiz tone "${entry['tone']}": $id',
      );
      expect(
        validTypes.contains(type),
        true,
        reason: 'GeÃ§ersiz type "$type": $id',
      );

      // Uzunluk kontrolÃ¼
      final maxLen = type == 'message' ? maxMessageLength : maxAffirmationLength;
      expect(
        text.length <= maxLen,
        true,
        reason: 'text Ã§ok uzun (${text.length} > $maxLen): $id',
      );

      // YasaklÄ± kalÄ±plar
      final lowerText = text.toLowerCase();
      for (final pattern in forbiddenPatterns) {
        expect(
          lowerText.contains(pattern.toLowerCase()),
          false,
          reason: 'YasaklÄ± kalÄ±p "$pattern" bulundu: $id',
        );
      }
    }
  }

  group('Ä°Ã§erik Lint Testi â€” birim', () {
    test('GeÃ§erli mesaj kabul edilir', () {
      lintEntries([
        {
          'id': 'aries_soft_msg_01',
          'sign': 'aries',
          'tone': 'soft',
          'type': 'message',
          'text':
              'KoÃ§ enerjisi seni bugÃ¼n bir adÄ±m atmaya davet ediyor. KÃ¼Ã§Ã¼k de olsa, o adÄ±m sana ait.',
          'tags': ['cesaret'],
        },
      ]);
    });

    test('GeÃ§erli olumlama kabul edilir', () {
      lintEntries([
        {
          'id': 'aries_soft_aff_01',
          'sign': 'aries',
          'tone': 'soft',
          'type': 'affirmation',
          'text': 'Kendime karÅŸÄ± nazif olduÄŸumda en gÃ¼Ã§lÃ¼ adÄ±mlarÄ±mÄ± atarÄ±m.',
          'tags': <String>[],
        },
      ]);
    });

    test('YasaklÄ± kalÄ±p reddedilir', () {
      expect(
        () => lintEntries([
          {
            'id': 'bad_01',
            'sign': 'aries',
            'tone': 'soft',
            'type': 'message',
            'text': 'Bu kesinlikle gerÃ§ekleÅŸecek, endiÅŸelenme.',
            'tags': <String>[],
          },
        ]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('Ã‡ok uzun mesaj reddedilir', () {
      expect(
        () => lintEntries([
          {
            'id': 'long_01',
            'sign': 'aries',
            'tone': 'soft',
            'type': 'message',
            'text': 'A' * (maxMessageLength + 1),
            'tags': <String>[],
          },
        ]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('GeÃ§ersiz sign reddedilir', () {
      expect(
        () => lintEntries([
          {
            'id': 'bad_sign',
            'sign': 'dragon',
            'tone': 'soft',
            'type': 'message',
            'text': 'Normal mesaj.',
            'tags': <String>[],
          },
        ]),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('Ä°Ã§erik Lint Testi â€” gerÃ§ek JSON dosyasÄ±', () {
    test('daily_content.json lint geÃ§iyor', () {
      // Flutter test ortamÄ±nda rootBundle yok; dosyayÄ± doÄŸrudan oku
      final file = File('assets/content/daily_content.json');
      expect(file.existsSync(), true, reason: 'JSON dosyasÄ± bulunamadÄ±');

      final data =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final entries = (data['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(
        entries.length,
        greaterThanOrEqualTo(672),
        reason: '672+ entry bekleniyor, ${entries.length} bulundu',
      );

      lintEntries(entries);
    });

    test('12 burÃ§ Ã— 4 ton Ã— en az 7 mesaj ve 7 olumlama mevcut', () {
      final file = File('assets/content/daily_content.json');
      if (!file.existsSync()) return; // dosya yoksa atla

      final data =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final entries = (data['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      for (final sign in validSigns) {
        for (final tone in validTones) {
          final messages = entries
              .where((e) =>
                  e['sign'] == sign &&
                  e['tone'] == tone &&
                  e['type'] == 'message')
              .toList();
          final affirmations = entries
              .where((e) =>
                  e['sign'] == sign &&
                  e['tone'] == tone &&
                  e['type'] == 'affirmation')
              .toList();

          expect(
            messages.length,
            greaterThanOrEqualTo(7),
            reason: '$sign/$tone iÃ§in ${messages.length} mesaj var (â‰¥7 gerekiyor)',
          );
          expect(
            affirmations.length,
            greaterThanOrEqualTo(7),
            reason:
                '$sign/$tone iÃ§in ${affirmations.length} olumlama var (â‰¥7 gerekiyor)',
          );
        }
      }
    });
  });
}

