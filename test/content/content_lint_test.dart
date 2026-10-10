import 'package:flutter_test/flutter_test.dart';

/// İçerik lint testi — yasaklı kalıplar ve uzunluk kontrolleri.
/// Aşama 3'te assets/content/daily_content.json tamamlandığında çalışır.
/// Bu test başarısız olursa içerik teslim edilmez.
void main() {
  const forbiddenPatterns = [
    'kesinlikle gerçekleşecek',
    'kesinlikle olacak',
    'iyileştirir',
    'hastalığa iyi gelir',
    'tedavi eder',
    'uğursuz',
    'uğur',
    'kötü şey olacak',
    'kötülük gelecek',
    'şifa verir',
    'şifa bulursun',
    'seni kurtarır',
    'garanti',
    'kaderinde var',
    'kaçınılmaz',
    'mutlaka gerçekleşir',
    'kesin olarak',
    'Allah', // dini referans yok
    'cennet',
    'cehennem',
  ];

  const maxMessageLength = 300;
  const maxAffirmationLength = 150;

  /// JSON içeriğini test et (gerçek asset olmadan da çalışır)
  void lintEntries(List<Map<String, dynamic>> entries) {
    for (final entry in entries) {
      final id = entry['id'] as String? ?? 'unknown';
      final message = entry['message'] as String? ?? '';
      final affirmation = entry['affirmation'] as String? ?? '';

      // Zorunlu alanlar
      expect(entry['id'], isNotNull, reason: 'id eksik: $entry');
      expect(entry['sign'], isNotNull, reason: 'sign eksik: $id');
      expect(entry['tone'], isNotNull, reason: 'tone eksik: $id');
      expect(message.isNotEmpty, true, reason: 'message boş: $id');
      expect(affirmation.isNotEmpty, true, reason: 'affirmation boş: $id');

      // Uzunluk kontrolü
      expect(
        message.length <= maxMessageLength,
        true,
        reason: 'message çok uzun (${message.length} > $maxMessageLength): $id',
      );
      expect(
        affirmation.length <= maxAffirmationLength,
        true,
        reason:
            'affirmation çok uzun (${affirmation.length} > $maxAffirmationLength): $id',
      );

      // Yasaklı kalıplar
      final allText = '${message.toLowerCase()} ${affirmation.toLowerCase()}';
      for (final pattern in forbiddenPatterns) {
        expect(
          allText.contains(pattern.toLowerCase()),
          false,
          reason: 'Yasaklı kalıp "$pattern" bulundu: $id',
        );
      }
    }
  }

  group('İçerik Lint Testi', () {
    test('Koç/yumuşak içerikleri geçerli', () {
      final entries = [
        {
          'id': 'aries_soft_001',
          'sign': 'aries',
          'tone': 'soft',
          'message':
              'Koç enerjisi seni bugün bir adım atmaya davet ediyor. Küçük de olsa, o adım sana ait.',
          'affirmation':
              'Kendime karşı nazif olduğumda en güçlü adımlarımı atarım.',
        },
        {
          'id': 'aries_soft_002',
          'sign': 'aries',
          'tone': 'soft',
          'message':
              'Ateş elementi sana enerji verir; bugün bu enerjiyi içinde tutmak da bir güç.',
          'affirmation': 'Dinlendiğimde de büyürüm.',
        },
      ];
      lintEntries(entries);
    });

    test('Yasaklı kalıp tespiti çalışıyor', () {
      final badEntry = {
        'id': 'test_bad',
        'sign': 'aries',
        'tone': 'soft',
        'message': 'Bu kesinlikle gerçekleşecek, endişelenme.',
        'affirmation': 'Her şey mükemmel.',
      };

      expect(
        () => lintEntries([badEntry]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('Çok uzun mesaj reddedilir', () {
      final longEntry = {
        'id': 'test_long',
        'sign': 'aries',
        'tone': 'soft',
        'message': 'A' * (maxMessageLength + 1),
        'affirmation': 'Kısa olumlama.',
      };

      expect(
        () => lintEntries([longEntry]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('id eksik entry reddedilir', () {
      final noId = {
        'sign': 'aries',
        'tone': 'soft',
        'message': 'Normal mesaj.',
        'affirmation': 'Normal olumlama.',
      };

      expect(
        () => lintEntries([noId]),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
