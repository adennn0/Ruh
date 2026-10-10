import '../models/content_models.dart';
import '../models/enums.dart';
import '../astrology/astrology_engine.dart';

/// AI içerik servisi arayüzü (sağlayıcıdan bağımsız).
/// Üç implementasyon:
///   1. LocalContentService   — yerel JSON kütüphanesi (varsayılan)
///   2. MockAIService         — geliştirme modu (açıkça işaretli)
///   3. RemoteAIService       — backend proxy (Aşama 6)
abstract class AIContentService {
  /// Günlük mesaj + olumlama + yansıma sorusu üret
  Future<ServiceResult<DailyContentResult>> generateDailyMessage({
    required ZodiacSign sign,
    required MessageTone tone,
    required String localDate, // "YYYY-MM-DD"
    required List<String>
        recentContentKeys, // son N günde gösterilenlerin key'i
  });

  /// Tek olumlama üret
  Future<ServiceResult<String>> generateAffirmation({
    required ZodiacSign sign,
    required MessageTone tone,
  });

  /// Niyet önerisi üret (kullanıcı düzenleyebilir)
  Future<ServiceResult<String>> generateIntentionSuggestion({
    required ZodiacSign sign,
    required MessageTone tone,
    String? category,
  });

  /// Sohbet mesajı gönder (Rehber)
  Future<ServiceResult<String>> sendChatMessage({
    required List<({String role, String content})> history,
    required String userMessage,
    required AIRequestContext context,
  });

  /// Servisin aktif olup olmadığı (mock/local/remote)
  bool get isRealAI;

  /// Kullanıcıya gösterilecek kaynak etiketi
  ContentSource get contentSource;
}
