import 'package:equatable/equatable.dart';
import 'enums.dart';

/// AI içerik servisi için giriş/çıkış modelleri

/// Günlük içerik yanıtı
class DailyContentResult extends Equatable {
  const DailyContentResult({
    required this.message,
    required this.affirmation,
    this.reflectionPrompt,
    required this.source,
    this.contentKey,
  });

  final String message;
  final String affirmation;
  final String? reflectionPrompt;
  final ContentSource source;
  final String? contentKey;

  @override
  List<Object?> get props =>
      [message, affirmation, reflectionPrompt, source, contentKey];
}

/// Sohbet mesajı
class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String conversationId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, conversationId, role, content, createdAt];
}

enum ChatRole { user, assistant, system }

/// AI isteği bağlamı (mahremiyet: minimum veri)
class AIRequestContext extends Equatable {
  const AIRequestContext({
    this.zodiacSign,
    required this.tone,
    this.intentionTitle, // Yalnızca aiKnowIntentions açıksa
  });

  final String? zodiacSign; // Yalnızca aiUseBirthData açıksa
  final MessageTone tone;
  final String? intentionTitle;

  @override
  List<Object?> get props => [zodiacSign, tone, intentionTitle];
}

/// Servis sonuç sarmalayıcı
sealed class ServiceResult<T> {}

class ServiceSuccess<T> extends ServiceResult<T> {
  ServiceSuccess(this.data);
  final T data;
}

class ServiceError<T> extends ServiceResult<T> {
  ServiceError(this.message, {this.isNetworkError = false});
  final String message;
  final bool isNetworkError;
}
