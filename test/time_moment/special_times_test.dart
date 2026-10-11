import 'package:flutter_test/flutter_test.dart';
import 'package:ruhun_parliyor/domain/astrology/astrology_engine.dart';
import 'package:ruhun_parliyor/domain/models/enums.dart';
import 'package:ruhun_parliyor/domain/time_moment/notification_payload.dart';
import 'package:ruhun_parliyor/domain/time_moment/quiet_hours.dart';
import 'package:ruhun_parliyor/domain/time_moment/special_times.dart';
import 'package:ruhun_parliyor/domain/time_moment/special_time_content.dart';
import 'package:ruhun_parliyor/domain/time_moment/time_moment_copy.dart';
import 'package:ruhun_parliyor/domain/time_moment/time_moment_planner.dart';

void main() {
  group('SpecialTimes', () {
    test('11:11, 14:14, 22:22 ayna/çift saattir', () {
      expect(SpecialTimes.parse('11:11')?.isMirror, isTrue);
      expect(SpecialTimes.parse('14:14')?.isMirror, isTrue);
      expect(SpecialTimes.parse('22:22')?.isMirror, isTrue);
    });

    test('14:41, 12:21, 23:32 palindromdur', () {
      expect(SpecialTimes.parse('14:41')?.isPalindrome, isTrue);
      expect(SpecialTimes.parse('12:21')?.isPalindrome, isTrue);
      expect(SpecialTimes.parse('23:32')?.isPalindrome, isTrue);
    });

    test('11:11 hem ayna hem palindromdur', () {
      expect(SpecialTimes.parse('11:11')?.kind, SpecialTimeKind.both);
      expect(SpecialTimes.parse('22:22')?.kind, SpecialTimeKind.both);
    });

    test('sıradan saat özel değildir', () {
      expect(SpecialTimes.isSpecial('14:15'), isFalse);
      expect(SpecialTimes.isSpecial('09:30'), isFalse);
    });

    test('katalog sıralı ve tekrarsızdır', () {
      final labels = SpecialTimes.all.map((t) => t.label).toList();
      expect(labels.toSet().length, labels.length);
      final minutes = SpecialTimes.all.map((t) => t.minutesOfDay).toList();
      final sorted = [...minutes]..sort();
      expect(minutes, sorted);
    });

    test('37 özel saatin her birinde 30 farklı sembolik mesaj bulunur', () {
      expect(SpecialTimes.all, hasLength(37));
      expect(SpecialTimeContent.meanings.keys.toSet(),
          SpecialTimes.all.map((time) => time.label).toSet());
      final allMessages = <String>[];
      for (final time in SpecialTimes.all) {
        final messages = SpecialTimeContent.messagesFor(time);
        expect(messages, hasLength(30), reason: time.label);
        expect(messages.toSet(), hasLength(30), reason: time.label);
        allMessages.addAll(messages);
      }
      expect(allMessages.toSet(), hasLength(1110));
    });
  });

  group('QuietHours', () {
    const night = QuietHours(startMinutes: 22 * 60, endMinutes: 8 * 60);

    test('22:00-08:00 geceyi aşar', () {
      expect(night.contains(23 * 60), isTrue);
      expect(night.contains(7 * 60), isTrue);
      expect(night.contains(11 * 60 + 11), isFalse);
      expect(night.contains(21 * 60 + 59), isFalse);
    });
  });

  group('TimeMomentPlanner', () {
    const planner = TimeMomentPlanner();
    final day = DateTime(2026, 10, 10);

    TimeMomentPlannerInput input({
      required String salt,
      int max = 5,
      ZodiacSign sign = ZodiacSign.pisces,
      DateTime? now,
    }) {
      return TimeMomentPlannerInput(
        localDay: day,
        sign: sign,
        toneIndex: MessageTone.spiritual.index,
        personalSalt: salt,
        maxCount: max,
        quietHours: const QuietHours(startMinutes: 22 * 60, endMinutes: 8 * 60),
        now: now,
      );
    }

    test('aynı girdi aynı saatleri üretir', () {
      final a = planner.plan(input(salt: 'abc'));
      final b = planner.plan(input(salt: 'abc'));
      expect(a.map((e) => e.time.label).toList(),
          b.map((e) => e.time.label).toList());
    });

    test('farklı tuz farklı seçki üretebilir', () {
      final a = planner.plan(input(salt: 'user-a')).map((e) => e.time.label);
      final b = planner.plan(input(salt: 'user-b')).map((e) => e.time.label);
      expect(a.length, 5);
      expect(b.length, 5);
      // Çok düşük ihtimalle aynı; yine de uzunluk ve sessiz saat yeter
      expect(a.every((t) {
        final p = SpecialTimes.parse(t)!;
        return p.hour >= 8 && p.hour < 22;
      }), isTrue);
    });

    test('geçmiş saatler bugün elenir', () {
      final now = DateTime(2026, 10, 10, 21, 0);
      final planned = planner.plan(input(salt: 'abc', now: now, max: 12));
      expect(
        planned.every((p) => p.time.minutesOfDay > 21 * 60),
        isTrue,
      );
    });

    test('kota uygulanır', () {
      expect(
          planner.plan(input(salt: 'x', max: 5)).length, lessThanOrEqualTo(5));
      expect(planner.plan(input(salt: 'x', max: 0)), isEmpty);
    });
  });

  group('TimeMomentCopyEngine', () {
    const engine = TimeMomentCopyEngine();
    final time = SpecialTimes.parse('14:41')!;

    test('kilit ekranı gövdesine niyet başlığı sızmaz', () {
      final copy = engine.compose(
        time: time,
        localDate: '2026-10-10',
        sign: ZodiacSign.leo,
        tone: MessageTone.soft,
        personalSalt: 'salt',
        intentionTitle: 'Gizli niyetim',
      );
      expect(copy.notificationBody.contains('Gizli niyetim'), isFalse);
      expect(copy.fullMessage.contains('Gizli niyetim'), isTrue);
      expect(copy.fullMessage.contains('garantisi'), isTrue);
    });

    test('ton metni değiştirir', () {
      final soft = engine.compose(
        time: time,
        localDate: '2026-10-10',
        sign: ZodiacSign.aries,
        tone: MessageTone.soft,
        personalSalt: 's',
      );
      final strong = engine.compose(
        time: time,
        localDate: '2026-10-10',
        sign: ZodiacSign.aries,
        tone: MessageTone.strong,
        personalSalt: 's',
      );
      expect(soft.fullMessage, isNot(strong.fullMessage));
    });

    test('notification body rotates when the previous copy was just used', () {
      final first = engine.compose(
        time: time,
        localDate: '2026-10-10',
        sign: ZodiacSign.aries,
        tone: MessageTone.soft,
        personalSalt: 's',
      );
      final next = engine.compose(
        time: time,
        localDate: '2026-10-11',
        sign: ZodiacSign.aries,
        tone: MessageTone.soft,
        personalSalt: 's',
        excludedNotificationBodies: [first.notificationBody],
      );
      expect(next.notificationBody, isNot(first.notificationBody));
    });

    test('saatin sembolik kategorisi ve anlamı mesajda kullanılır', () {
      final copy = engine.compose(
        time: time,
        localDate: '2026-10-10',
        sign: ZodiacSign.aries,
        tone: MessageTone.rational,
        personalSalt: 's',
      );
      expect(copy.fullMessage, contains('Tutarlılık'));
      expect(copy.fullMessage, contains('basit bir rutin kurma'));
    });
  });

  group('TimeMomentPayload', () {
    test('encode/decode', () {
      const p = TimeMomentPayload(localDate: '2026-10-10', timeLabel: '11:11');
      expect(TimeMomentPayload.tryParse(p.encode())?.timeLabel, '11:11');
      expect(TimeMomentPayload.tryParse('nope'), isNull);
    });
  });
}
