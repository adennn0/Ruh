import 'package:equatable/equatable.dart';

/// Mesajın kaynağını belirtir — şeffaflık için zorunlu
enum ContentSource { ai, local, demo }

/// Kullanıcının seçebileceği iletişim tonu
enum MessageTone {
  soft, // Yumuşak — Nazik ve kucaklayıcı
  strong, // Net & Güçlü — Kısa ve özgüvenli
  spiritual, // Spiritüel — Derin ve sezgisel
  rational; // Mantıklı — Analitik ve rasyonel

  String get displayName => switch (this) {
        MessageTone.soft => 'Yumuşak',
        MessageTone.strong => 'Net & Güçlü',
        MessageTone.spiritual => 'Spiritüel',
        MessageTone.rational => 'Mantıklı',
      };

  String get subtitle => switch (this) {
        MessageTone.soft => 'Nazik ve kucaklayıcı',
        MessageTone.strong => 'Kısa ve özgüvenli',
        MessageTone.spiritual => 'Derin ve sezgisel',
        MessageTone.rational => 'Analitik ve rasyonel',
      };

  String get example => switch (this) {
        MessageTone.soft =>
          'Bugün kendine nazik olmayı seç; küçük adımlar büyük dönüşümlerin başlangıcıdır.',
        MessageTone.strong => 'Hedefine odaklan. Bugün tek bir somut adım at.',
        MessageTone.spiritual =>
          'Evrenin sana sunduğu bu anda, içindeki ışığı keşfetmeye hazır mısın?',
        MessageTone.rational =>
          'Duygularını gözlemle; onlar sana neyin önemli olduğunu gösterir.',
      };
}

/// Niyet kategorileri
enum IntentionCategory {
  personalGrowth,
  relationships,
  career,
  peace,
  healthHabits,
  abundance;

  String get displayName => switch (this) {
        IntentionCategory.personalGrowth => 'Kişisel Gelişim',
        IntentionCategory.relationships => 'İlişkiler',
        IntentionCategory.career => 'Kariyer',
        IntentionCategory.peace => 'Huzur',
        IntentionCategory.healthHabits => 'Sağlık Alışkanlıkları',
        IntentionCategory.abundance => 'Bolluk & Üretkenlik',
      };
}

/// Niyet durumu
enum IntentionStatus { active, completed, archived }

/// Günlük yazı türü
enum JournalType { journal, dream, gratitude }

extension JournalTypeExt on JournalType {
  String get displayName => switch (this) {
        JournalType.journal => 'Günlük',
        JournalType.dream => 'Rüya',
        JournalType.gratitude => 'Şükür',
      };
}

/// Favori içerik türü
enum FavoriteContentType { message, affirmation, intention, ritual }

/// Rozet tanımları
enum BadgeId {
  firstIntention,
  firstJournal,
  firstTimeMoment,
  firstBreath,
  streak7,
  streak21,
  gratitudeMaster,
  dreamExplorer,
  stoneSelected,
  spiritAnimalDiscovered,
  compatibilityExplorer,
  firstThemeChange;

  String get displayName => switch (this) {
        BadgeId.firstIntention => 'İlk Niyet',
        BadgeId.firstJournal => 'İlk Yazı',
        BadgeId.firstTimeMoment => 'İlk Saat Anı',
        BadgeId.firstBreath => 'İlk Nefes',
        BadgeId.streak7 => '7 Gün Işık',
        BadgeId.streak21 => '21 Gün Işık',
        BadgeId.gratitudeMaster => 'Şükür Ustası',
        BadgeId.dreamExplorer => 'Rüya Gezgini',
        BadgeId.stoneSelected => 'Taş Seçildi',
        BadgeId.spiritAnimalDiscovered => 'Ruh Hayvanı Keşfedildi',
        BadgeId.compatibilityExplorer => 'Uyumluluk Kaşifi',
        BadgeId.firstThemeChange => 'Tema Değiştirici',
      };

  String get description => switch (this) {
        BadgeId.firstIntention => 'İlk niyetini oluşturdu',
        BadgeId.firstJournal => 'İlk günlük yazısını yazdı',
        BadgeId.firstTimeMoment => 'İlk saat anı ritüelini tamamladı',
        BadgeId.firstBreath => 'İlk nefes molasını tamamladı',
        BadgeId.streak7 => '7 gün kesintisiz ışık yaktı',
        BadgeId.streak21 => '21 gün kesintisiz ışık yaktı',
        BadgeId.gratitudeMaster => '10 şükür kaydı oluşturdu',
        BadgeId.dreamExplorer => '5 rüya kaydı oluşturdu',
        BadgeId.stoneSelected => 'Doğal taşını keşfetti',
        BadgeId.spiritAnimalDiscovered => 'Ruh hayvanını keşfetti',
        BadgeId.compatibilityExplorer => 'Uyumluluk özelliğini kullandı',
        BadgeId.firstThemeChange => 'İlk tema değişimini yaptı',
      };
}

/// Işık Serisi etkinlik maskesi
class StreakActivity extends Equatable {
  const StreakActivity({
    this.readDailyMessage = false,
    this.createdIntention = false,
    this.savedJournal = false,
    this.completedBreath = false,
    this.savedTimeMoment = false,
  });

  final bool readDailyMessage;
  final bool createdIntention;
  final bool savedJournal;
  final bool completedBreath;
  final bool savedTimeMoment;

  bool get hasAnyActivity =>
      readDailyMessage ||
      createdIntention ||
      savedJournal ||
      completedBreath ||
      savedTimeMoment;

  int get mask =>
      (readDailyMessage ? 1 : 0) |
      (createdIntention ? 2 : 0) |
      (savedJournal ? 4 : 0) |
      (completedBreath ? 8 : 0) |
      (savedTimeMoment ? 16 : 0);

  factory StreakActivity.fromMask(int mask) => StreakActivity(
        readDailyMessage: (mask & 1) != 0,
        createdIntention: (mask & 2) != 0,
        savedJournal: (mask & 4) != 0,
        completedBreath: (mask & 8) != 0,
        savedTimeMoment: (mask & 16) != 0,
      );

  StreakActivity copyWithActivity(StreakActivity other) => StreakActivity(
        readDailyMessage: readDailyMessage || other.readDailyMessage,
        createdIntention: createdIntention || other.createdIntention,
        savedJournal: savedJournal || other.savedJournal,
        completedBreath: completedBreath || other.completedBreath,
        savedTimeMoment: savedTimeMoment || other.savedTimeMoment,
      );

  @override
  List<Object?> get props => [mask];
}
