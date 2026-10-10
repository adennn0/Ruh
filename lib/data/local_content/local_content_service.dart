import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/models/content_models.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/ai_content_service.dart';

/// LocalContentService: JSON asset'inden içerik okur.
/// JSON şeması: { version, lint_rules, entries: [{id, sign, tone, type, text, tags}] }
/// Deterministik tohumlama: aynı gün + burç + ton → aynı içerik.
/// Son N günde gösterilen içerik tekrarlanmaz.
class LocalContentService implements AIContentService {
  LocalContentService();

  List<Map<String, dynamic>>? _messagesCache;
  List<Map<String, dynamic>>? _affirmationsCache;

  @override
  bool get isRealAI => false;

  @override
  ContentSource get contentSource => ContentSource.local;

  Future<void> _ensureLoaded() async {
    if (_messagesCache != null) return;
    try {
      final raw =
          await rootBundle.loadString('assets/content/daily_content.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      final entries =
          (data['entries'] as List<dynamic>).cast<Map<String, dynamic>>();

      _messagesCache = entries.where((e) => e['type'] == 'message').toList();
      _affirmationsCache =
          entries.where((e) => e['type'] == 'affirmation').toList();
    } catch (_) {
      _messagesCache = [];
      _affirmationsCache = [];
    }
  }

  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> pool,
    String sign,
    String tone,
  ) {
    return pool.where((e) => e['sign'] == sign && e['tone'] == tone).toList();
  }

  @override
  Future<ServiceResult<DailyContentResult>> generateDailyMessage({
    required ZodiacSign sign,
    required MessageTone tone,
    required String localDate,
    required List<String> recentContentKeys,
  }) async {
    await _ensureLoaded();

    final pool = _filter(_messagesCache!, sign.name, tone.name);

    if (pool.isEmpty) {
      return ServiceSuccess(_fallbackDailyContent(sign, tone));
    }

    // Deterministik tohumlama
    final seed = localDate.hashCode ^ sign.index ^ tone.index;
    final rng = Random(seed);

    // Son N günde gösterilenleri filtrele
    final available = pool
        .where((e) => !recentContentKeys.contains(e['id'] as String?))
        .toList();
    final candidates = available.isNotEmpty ? available : pool;
    final picked = candidates[rng.nextInt(candidates.length)];

    // Aynı burç+ton için bir olumlama da seç
    final affPool = _filter(_affirmationsCache!, sign.name, tone.name);
    final affirmation = affPool.isNotEmpty
        ? affPool[rng.nextInt(affPool.length)]['text'] as String? ?? ''
        : _fallbackAffirmation(sign, tone);

    return ServiceSuccess(DailyContentResult(
      message: picked['text'] as String? ?? '',
      affirmation: affirmation,
      source: ContentSource.local,
      contentKey: picked['id'] as String?,
    ));
  }

  @override
  Future<ServiceResult<String>> generateAffirmation({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    await _ensureLoaded();

    final pool = _filter(_affirmationsCache!, sign.name, tone.name);
    if (pool.isEmpty) return ServiceSuccess(_fallbackAffirmation(sign, tone));

    final rng = Random(DateTime.now().day + sign.index);
    return ServiceSuccess(
        pool[rng.nextInt(pool.length)]['text'] as String? ?? '');
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

  /// getDailyContent: sign+tone ile bugünün içeriğini döner (HomeScreen kullanır)
  Future<ServiceResult<DailyContentResult>> getDailyContent({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    final now = DateTime.now();
    final localDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return generateDailyMessage(
      sign: sign,
      tone: tone,
      localDate: localDate,
      recentContentKeys: [],
    );
  }

  // ── Fallback ─────────────────────────────────────────────────────────────────

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
    return '${sign.displayName} gücüyle bugün adım atıyorum.';
  }
}

/// MockAIService — geliştirme modunda kullanılır; gerçek AI gibi sunulmaz
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return ServiceSuccess(DailyContentResult(
      message: '[Mock] ${sign.displayName} için ${tone.displayName} mesaj: '
          'Bu örnek bir yanıttır. Gerçek AI Aşama 6\'da devreye girecek.',
      affirmation: '[Mock] Ben yeterliyim.',
      source: ContentSource.demo,
      contentKey: 'mock_01',
    ));
  }

  @override
  Future<ServiceResult<String>> generateAffirmation({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    return ServiceSuccess('[Mock] Olumlama: Bugün harika bir gün.');
  }

  @override
  Future<ServiceResult<String>> generateIntentionSuggestion({
    required ZodiacSign sign,
    required MessageTone tone,
    String? category,
  }) async {
    return ServiceSuccess('[Mock] Niyet önerisi: Bugün küçük bir adım at.');
  }

  @override
  Future<ServiceResult<String>> sendChatMessage({
    required List<({String role, String content})> history,
    required String userMessage,
    required AIRequestContext context,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return ServiceSuccess(
      '[Mock] Bu bir geliştirme modu yanıtıdır. Gerçek AI Aşama 6\'da aktif.',
    );
  }

  Future<ServiceResult<DailyContentResult>> getDailyContent({
    required ZodiacSign sign,
    required MessageTone tone,
  }) async {
    return generateDailyMessage(
      sign: sign,
      tone: tone,
      localDate: DateTime.now().toString().substring(0, 10),
      recentContentKeys: [],
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Aktif içerik servisi (yapılandırmadan seçilir)
/// Aşama 3: LocalContentService varsayılan
final aiContentServiceProvider = Provider<AIContentService>((ref) {
  return LocalContentService();
});
