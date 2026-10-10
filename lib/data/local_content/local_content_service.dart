import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/models/content_models.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/ai_content_service.dart';

/// LocalContentService: JSON asset'inden içerik okur.
/// Deterministik tohumlama: aynı gün + burç + ton → aynı içerik.
/// Son N günde gösterilen içerik tekrarlanmaz.
class LocalContentService implements AIContentService {
  LocalContentService();

  Map<String, dynamic>? _contentCache;

  @override
  bool get isRealAI => false;

  @override
  ContentSource get contentSource => ContentSource.local;

  Future<Map<String, dynamic>> _loadContent() async {
    if (_contentCache != null) return _contentCache!;
    try {
      final raw =
          await rootBundle.loadString('assets/content/daily_content.json');
      _contentCache = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Kütüphane henüz yok (Aşama 3'te tamamlanacak), fallback kullan
      _contentCache = _fallbackContent;
    }
    return _contentCache!;
  }

  @override
  Future<ServiceResult<DailyContentResult>> generateDailyMessage({
    required ZodiacSign sign,
    required MessageTone tone,
    required String localDate,
    required List<String> recentContentKeys,
  }) async {
    final content = await _loadContent();
    final signKey = sign.name;
    final toneKey = tone.name;

    final List<dynamic> entries = (content['messages']
            as Map<String, dynamic>?)?[signKey]?[toneKey] as List<dynamic>? ??
        [];

    if (entries.isEmpty) {
      return ServiceSuccess(_fallbackDailyContent(sign, tone));
    }

    // Deterministik tohumlama: localDate seed'i
    final seed = localDate.hashCode ^ signKey.hashCode ^ toneKey.hashCode;
    final rng = Random(seed);

    // Son N günde gösterilenleri filtrele
    final available = entries
        .cast<Map<String, dynamic>>()
        .where((e) => !recentContentKeys.contains(e['id'] as String?))
        .toList();

    final pool =
        available.isNotEmpty ? available : entries.cast<Map<String, dynamic>>();
    final picked = pool[rng.nextInt(pool.length)];

    return ServiceSuccess(DailyContentResult(
      message: picked['message'] as String? ?? '',
      affirmation: picked['affirmation'] as String? ?? '',
      reflectionPrompt: picked['reflectionPrompt'] as String?,
      source: ContentSource.local,
      contentKey: picked['id'] as String?,
    ));
  }

  @override
  Future<ServiceResult<String>> generateAffirmation({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    final content = await _loadContent();
    final List<dynamic> entries =
        (content['affirmations'] as Map<String, dynamic>?)?[sign.name]
                ?[tone.name] as List<dynamic>? ??
            [];

    if (entries.isEmpty) {
      return ServiceSuccess(_fallbackAffirmation(sign, tone));
    }

    final rng = Random(DateTime.now().day + sign.index);
    return ServiceSuccess(entries[rng.nextInt(entries.length)] as String);
  }

  @override
  Future<ServiceResult<String>> generateIntentionSuggestion({
    required ZodiacSign sign,
    required MessageTone tone,
    String? category,
  }) async {
    return ServiceSuccess(
      'Bugün ${sign.displayName} enerjisiyle, ${tone.displayName.toLowerCase()} bir adım atmak için ne yapabilirsin?',
    );
  }

  @override
  Future<ServiceResult<String>> sendChatMessage({
    required List<({String role, String content})> history,
    required String userMessage,
    required AIRequestContext context,
  }) async {
    // Aşama 3'te mock yanıt; Aşama 6'da gerçek proxy
    return ServiceSuccess(
      'Bu bir geliştirme modu yanıtıdır. Gerçek AI entegrasyonu Aşama 6\'da aktif olacak.',
    );
  }

  // ─── Fallback içerikler ──────────────────────────────────────────────────
  DailyContentResult _fallbackDailyContent(ZodiacSign sign, MessageTone tone) {
    return DailyContentResult(
      message:
          '${sign.displayName} enerjisiyle bugün, içindeki ışığı fark etmek için küçük bir adım atabilirsin.',
      affirmation: 'İstediğim yönde küçük, tutarlı adımlar atmaya hazırım.',
      reflectionPrompt: 'Bugün sana iyi gelen küçük bir şey ne olabilir?',
      source: ContentSource.local,
      contentKey: null,
    );
  }

  String _fallbackAffirmation(ZodiacSign sign, MessageTone tone) {
    return 'Her yeni gün, yeni bir başlangıç fırsatıdır.';
  }

  static const _fallbackContent = <String, dynamic>{};
}

// ─── MockAIService ────────────────────────────────────────────────────────────
/// Açıkça "Geliştirme modu" olarak işaretlenmiş; gerçek AI gibi sunulmaz.
class MockAIService implements AIContentService {
  @override
  bool get isRealAI => false;

  @override
  ContentSource get contentSource => ContentSource.demo;

  @override
  Future<ServiceResult<DailyContentResult>> generateDailyMessage({
    required ZodiacSign sign,
    required MessageTone tone,
    required String localDate,
    required List<String> recentContentKeys,
  }) async {
    await Future<void>.delayed(
        const Duration(milliseconds: 800)); // simüle gecikme
    return ServiceSuccess(DailyContentResult(
      message:
          '[DEMO] ${sign.displayName} için ${tone.displayName} ton ile oluşturulan örnek mesaj. '
          'Bu içerik gerçek bir AI tarafından üretilmemiştir.',
      affirmation: '[DEMO] Bu bir örnek olumlamadır.',
      reflectionPrompt: '[DEMO] Bugün sana en çok ne iyi geldi?',
      source: ContentSource.demo,
      contentKey: 'demo_${sign.name}_${tone.name}',
    ));
  }

  @override
  Future<ServiceResult<String>> generateAffirmation({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return ServiceSuccess('[DEMO] ${sign.displayName} için örnek olumlama.');
  }

  @override
  Future<ServiceResult<String>> generateIntentionSuggestion({
    required ZodiacSign sign,
    required MessageTone tone,
    String? category,
  }) async {
    return ServiceSuccess('[DEMO] Örnek niyet önerisi.');
  }

  @override
  Future<ServiceResult<String>> sendChatMessage({
    required List<({String role, String content})> history,
    required String userMessage,
    required AIRequestContext context,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return ServiceSuccess(
      '[GELİŞTİRME MODU] Gönderdiğin: "$userMessage" — '
      'Gerçek AI yanıtı Aşama 6\'da aktif olacak.',
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final aiContentServiceProvider = Provider<AIContentService>((ref) {
  // Aşama 6'da RemoteAIService ile değiştirilecek
  return LocalContentService();
});
