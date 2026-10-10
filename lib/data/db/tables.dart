import 'package:drift/drift.dart';

// ─── Tablolar ────────────────────────────────────────────────────────────────

class UserProfileTable extends Table {
  @override
  String get tableName => 'user_profile';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().nullable().withLength(max: 50)();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get birthTime => text().nullable()(); // "HH:mm" veya null
  BoolColumn get birthTimeUnknown =>
      boolean().withDefault(const Constant(false))();
  TextColumn get birthPlaceName => text().nullable()();
  RealColumn get birthPlaceLat => real().nullable()();
  RealColumn get birthPlaceLon => real().nullable()();
  TextColumn get birthPlaceTimezone => text().nullable()();
  TextColumn get preferredTone =>
      text().withDefault(const Constant('spiritual'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyContentTable extends Table {
  @override
  String get tableName => 'daily_content';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get localDate => text()(); // "YYYY-MM-DD" — benzersiz anahtar
  TextColumn get message => text()();
  TextColumn get affirmation => text()();
  TextColumn get reflectionPrompt => text().nullable()();
  TextColumn get source =>
      text().withDefault(const Constant('local'))(); // ai | local | demo
  TextColumn get contentKey => text().nullable()();
  IntColumn get regenCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class IntentionTable extends Table {
  @override
  String get tableName => 'intentions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 120)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('personal'))();
  TextColumn get status => text()
      .withDefault(const Constant('active'))(); // active | completed | archived
  TextColumn get actionStep => text().nullable()();
  TextColumn get affirmation => text().nullable()();
  TextColumn get linkedStoneId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class JournalEntryTable extends Table {
  @override
  String get tableName => 'journal_entries';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get entryDate => text()(); // "YYYY-MM-DD"
  TextColumn get type => text()
      .withDefault(const Constant('journal'))(); // journal | dream | gratitude
  TextColumn get title => text().nullable()();
  TextColumn get body => text()();
  TextColumn get mood => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TimeMomentTable extends Table {
  @override
  String get tableName => 'time_moments';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // "YYYY-MM-DD"
  TextColumn get timeLabel => text()(); // "11:11", "16:16", vb.
  TextColumn get intentionText => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class FavoriteTable extends Table {
  @override
  String get tableName => 'favorites';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentType =>
      text()(); // message | affirmation | intention | ritual
  TextColumn get contentId => text()();
  TextColumn get cachedText =>
      text().nullable()(); // Kaynak silinirse görüntüleme için
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SavedPersonTable extends Table {
  @override
  String get tableName => 'saved_persons';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text().withLength(max: 50)();
  DateTimeColumn get birthDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ReminderSettingTable extends Table {
  @override
  String get tableName => 'reminder_settings';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get type =>
      text()(); // daily_intention | time_moment | evening_reflection | daily_message
  TextColumn get time => text()(); // "HH:mm"
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  TextColumn get label => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class StreakDayTable extends Table {
  @override
  String get tableName => 'streak_days';

  TextColumn get localDate => text()(); // PK: "YYYY-MM-DD"
  IntColumn get activityMask => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {localDate};
}

class RestDayUseTable extends Table {
  @override
  String get tableName => 'rest_day_uses';

  TextColumn get weekStartDate => text()(); // PK: haftanın pazartesi tarihi
  TextColumn get usedOn => text()(); // hangi günde kullanıldı

  @override
  Set<Column> get primaryKey => {weekStartDate};
}

class BadgeTable extends Table {
  @override
  String get tableName => 'badges';

  TextColumn get badgeId => text()(); // PK
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {badgeId};
}

class CatProfileTable extends Table {
  @override
  String get tableName => 'cat_profile';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('Kedi'))();
  TextColumn get furColor => text().withDefault(const Constant('obsidian'))();
  TextColumn get eyeColor => text().withDefault(const Constant('amethyst'))();
  TextColumn get equippedItems =>
      text().withDefault(const Constant('{}'))(); // JSON: slot→itemId
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CatItemUnlockTable extends Table {
  @override
  String get tableName => 'cat_item_unlocks';

  TextColumn get itemId => text()(); // PK
  TextColumn get source => text()(); // milestone | badge | premium
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {itemId};
}

class ChatMessageTable extends Table {
  @override
  String get tableName => 'chat_messages';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text()();
  TextColumn get role => text()(); // user | assistant | system
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().autoIncrement()();
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get consentAcceptedAt => dateTime().nullable()();
  TextColumn get themeId =>
      text().withDefault(const Constant('amethystAurora'))();
  BoolColumn get reduceMotion => boolean().withDefault(const Constant(false))();
  BoolColumn get haptics => boolean().withDefault(const Constant(true))();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get showStreak => boolean().withDefault(const Constant(true))();
  BoolColumn get aiUseBirthData =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get aiKnowIntentions =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get widgetPrivacyMode =>
      boolean().withDefault(const Constant(false))();
  TextColumn get quietHoursStart =>
      text().withDefault(const Constant('22:00'))();
  TextColumn get quietHoursEnd => text().withDefault(const Constant('08:00'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class EntitlementCacheTable extends Table {
  @override
  String get tableName => 'entitlement_cache';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tier =>
      text().withDefault(const Constant('free'))(); // free | premium
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get source =>
      text().nullable()(); // revenuecat | in_app_purchase | debug
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
