import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/data/repositories/streak_repository.dart';
import 'package:ruhun_parliyor/domain/models/enums.dart';
import 'package:ruhun_parliyor/core/limits.dart';
import 'package:ruhun_parliyor/domain/astrology/astrology_engine.dart';

void main() {
  group('StreakBit sabitleri', () {
    test('readMessage = 1', () => expect(StreakBit.readMessage, 1));
    test('createOrUpdateIntention = 2',
        () => expect(StreakBit.createOrUpdateIntention, 2));
    test('saveJournal = 4', () => expect(StreakBit.saveJournal, 4));
    test('completeBreath = 8', () => expect(StreakBit.completeBreath, 8));
    test('saveTimeMoment = 16', () => expect(StreakBit.saveTimeMoment, 16));
  });

  group('AppLimits degerleri', () {
    test('streakMilestones dogru liste',
        () => expect(AppLimits.streakMilestones, [3, 7, 14, 21, 49, 100, 365]));
    test('freeMaxActiveIntentions = 3',
        () => expect(AppLimits.freeMaxActiveIntentions, 3));
    test('freeMaxDailyMessages = 5',
        () => expect(AppLimits.freeMaxDailyMessages, 5));
    test('premiumMaxActiveIntentions = -1 (sinirsiz)',
        () => expect(AppLimits.premiumMaxActiveIntentions, -1));
    test('notificationWindowDays = 7',
        () => expect(AppLimits.notificationWindowDays, 7));
    test('freeMaxDailyNotifications = 5',
        () => expect(AppLimits.freeMaxDailyNotifications, 5));
    test('premiumMaxDailyNotifications = 12',
        () => expect(AppLimits.premiumMaxDailyNotifications, 12));
    test('minContentPerSignTone = 7',
        () => expect(AppLimits.minContentPerSignTone, 7));
    test('streakRestDaysPerWeek = 1',
        () => expect(AppLimits.streakRestDaysPerWeek, 1));
    test('contentNoRepeatDays = 7',
        () => expect(AppLimits.contentNoRepeatDays, 7));
    test('guideCounterKeyPrefix bos degil',
        () => expect(AppLimits.guideCounterKeyPrefix.isNotEmpty, true));
  });

  group('ContentSource enum', () {
    test('3 deger var', () => expect(ContentSource.values.length, 3));
    test('ai degeri var',
        () => expect(ContentSource.values.any((v) => v.name == 'ai'), true));
    test('local degeri var',
        () => expect(ContentSource.values.any((v) => v.name == 'local'), true));
    test('demo degeri var',
        () => expect(ContentSource.values.any((v) => v.name == 'demo'), true));
  });

  group('JournalType enum', () {
    test('3 deger var', () => expect(JournalType.values.length, 3));
    test('journal degeri var',
        () => expect(JournalType.values.any((v) => v.name == 'journal'), true));
    test('dream degeri var',
        () => expect(JournalType.values.any((v) => v.name == 'dream'), true));
    test('gratitude degeri var',
        () => expect(JournalType.values.any((v) => v.name == 'gratitude'), true));
  });

  group('IntentionStatus enum', () {
    test('3 deger var', () => expect(IntentionStatus.values.length, 3));
    test('active degeri var',
        () => expect(IntentionStatus.values.any((v) => v.name == 'active'), true));
    test('completed degeri var', () =>
        expect(IntentionStatus.values.any((v) => v.name == 'completed'), true));
    test('archived degeri var',
        () => expect(IntentionStatus.values.any((v) => v.name == 'archived'), true));
  });

  group('IntentionCategory enum', () {
    test('personalGrowth degeri var', () => expect(
        IntentionCategory.values.any((v) => v.name == 'personalGrowth'), true));
    test('en az 1 kategori var',
        () => expect(IntentionCategory.values.isNotEmpty, true));
    test('her kategorinin displayName var', () {
      for (final cat in IntentionCategory.values) {
        expect(cat.displayName.isNotEmpty, true,
            reason: '${cat.name} displayName bos');
      }
    });
  });

  group('MessageTone enum', () {
    test('4 ton var', () => expect(MessageTone.values.length, 4));
    test('soft ton var',
        () => expect(MessageTone.values.any((v) => v.name == 'soft'), true));
    test('strong ton var',
        () => expect(MessageTone.values.any((v) => v.name == 'strong'), true));
    test('spiritual ton var',
        () => expect(MessageTone.values.any((v) => v.name == 'spiritual'), true));
    test('rational ton var',
        () => expect(MessageTone.values.any((v) => v.name == 'rational'), true));
  });

  group('ZodiacSign enum', () {
    test('12 burc var', () => expect(ZodiacSign.values.length, 12));
    test('aries var',
        () => expect(ZodiacSign.values.any((ZodiacSign v) => v.name == 'aries'), true));
    test('pisces var',
        () => expect(ZodiacSign.values.any((ZodiacSign v) => v.name == 'pisces'), true));
  });

  group('BadgeId enum', () {
    test('firstIntention var',
        () => expect(BadgeId.values.any((v) => v.name == 'firstIntention'), true));
    test('firstJournal var',
        () => expect(BadgeId.values.any((v) => v.name == 'firstJournal'), true));
    test('gratitudeMaster var',
        () => expect(BadgeId.values.any((v) => v.name == 'gratitudeMaster'), true));
    test('dreamExplorer var',
        () => expect(BadgeId.values.any((v) => v.name == 'dreamExplorer'), true));
  });
}
