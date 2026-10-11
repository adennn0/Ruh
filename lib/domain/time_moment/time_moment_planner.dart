import '../astrology/astrology_engine.dart';
import '../../core/stable_hash.dart';
import 'quiet_hours.dart';
import 'special_times.dart';

class PlannedTimeMoment {
  const PlannedTimeMoment({
    required this.time,
    required this.localDate,
    required this.scheduledAt,
  });

  final SpecialTime time;
  final String localDate;
  final DateTime scheduledAt;
}

class TimeMomentPlannerInput {
  const TimeMomentPlannerInput({
    required this.localDay,
    required this.sign,
    required this.toneIndex,
    required this.personalSalt,
    required this.maxCount,
    required this.quietHours,
    this.birthHour,
    this.intentionTitles = const [],
    this.now,
  });

  final DateTime localDay;
  final ZodiacSign sign;
  final int toneIndex;
  final String personalSalt;
  final int maxCount;
  final QuietHours quietHours;
  final int? birthHour;
  final List<String> intentionTitles;

  /// Yalnızca "bugün" için geçmiş saatleri elemek üzere verilir.
  final DateTime? now;
}

/// Günün kişisel Saat Anı listesini üretir.
/// Aynı girdi → aynı saatler (deterministik).
class TimeMomentPlanner {
  const TimeMomentPlanner();

  List<PlannedTimeMoment> plan(TimeMomentPlannerInput input) {
    if (input.maxCount <= 0) return const [];

    final day = DateTime(
      input.localDay.year,
      input.localDay.month,
      input.localDay.day,
    );
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    final now = input.now;
    final isSameDay = now != null &&
        now.year == day.year &&
        now.month == day.month &&
        now.day == day.day;
    final nowMinutes = isSameDay ? now.hour * 60 + now.minute : null;

    final scored = <_Scored>[];
    for (final time in SpecialTimes.all) {
      if (input.quietHours.contains(time.minutesOfDay)) continue;
      if (nowMinutes != null && time.minutesOfDay <= nowMinutes) continue;

      var score = _stableScore(
        dateKey,
        time.label,
        input.sign.index,
        input.toneIndex,
        input.personalSalt,
      );

      score += _elementBias(input.sign.element, time.hour);
      if (input.birthHour != null && time.hour == input.birthHour) {
        score += 40;
      }
      if (input.intentionTitles.isNotEmpty) {
        score += stableHashParts(
              [time.label, input.intentionTitles.join('|')],
            ) %
            17;
      }
      scored.add(_Scored(time, score));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.time.minutesOfDay.compareTo(b.time.minutesOfDay);
    });

    final picked = scored.take(input.maxCount).map((s) => s.time).toList()
      ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));

    return [
      for (final time in picked)
        PlannedTimeMoment(
          time: time,
          localDate: dateKey,
          scheduledAt:
              DateTime(day.year, day.month, day.day, time.hour, time.minute),
        ),
    ];
  }

  int _stableScore(
    String dateKey,
    String timeLabel,
    int signIndex,
    int toneIndex,
    String salt,
  ) {
    return stableHashParts(
      [dateKey, timeLabel, signIndex, toneIndex, salt],
    );
  }

  /// Sembolik, iddiasız bir dağılım: ateş gündüz, su akşam, toprak sabah, hava öğleden sonra.
  int _elementBias(ZodiacElement element, int hour) {
    return switch (element) {
      ZodiacElement.fire => hour >= 10 && hour <= 16 ? 12 : 0,
      ZodiacElement.earth => hour >= 7 && hour <= 12 ? 12 : 0,
      ZodiacElement.air => hour >= 12 && hour <= 18 ? 12 : 0,
      ZodiacElement.water => hour >= 18 || hour <= 8 ? 12 : 0,
    };
  }
}

class _Scored {
  const _Scored(this.time, this.score);
  final SpecialTime time;
  final int score;
}
