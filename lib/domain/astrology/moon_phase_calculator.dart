import 'dart:math' as math;

import 'astrology_engine.dart';

/// Meeus, Astronomical Algorithms, Chapter 49 primary-phase approximation.
/// Returns offline, deterministic phase dates for the Gregorian calendar.
class MoonPhaseEvent {
  const MoonPhaseEvent({required this.phase, required this.localTime});

  final MoonPhase phase;
  final DateTime localTime;
}

class MoonPhaseCalculator {
  const MoonPhaseCalculator();

  MoonPhase phaseAt(DateTime date) {
    final instant = date.toUtc();
    final jd = _julianDay(instant);
    final k = _lunation(instant);
    final events = <(double, int)>[];
    for (var cycle = k - 2; cycle <= k + 1; cycle++) {
      for (var type = 0; type < 4; type++) {
        final jde = _phaseJde(cycle + type * 0.25, type);
        final utcJd = jde - _deltaTSeconds(instant.year) / 86400;
        events.add((utcJd, type));
      }
    }
    events.sort((a, b) => a.$1.compareTo(b.$1));
    final latestIndex = events.lastIndexWhere((event) => event.$1 <= jd);
    if (latestIndex < 0 || latestIndex + 1 >= events.length) {
      return MoonPhase.newMoon;
    }
    final latest = events[latestIndex];
    final next = events[latestIndex + 1];
    final progress = (jd - latest.$1) / (next.$1 - latest.$1);
    final firstHalf = progress < 0.5;
    return switch (latest.$2) {
      0 => firstHalf ? MoonPhase.newMoon : MoonPhase.waxingCrescent,
      1 => firstHalf ? MoonPhase.firstQuarter : MoonPhase.waxingGibbous,
      2 => firstHalf ? MoonPhase.fullMoon : MoonPhase.waningGibbous,
      3 => firstHalf ? MoonPhase.lastQuarter : MoonPhase.waningCrescent,
      _ => MoonPhase.newMoon,
    };
  }

  List<MoonPhaseEvent> eventsBetween(DateTime start, DateTime end) {
    if (!end.isAfter(start)) return const [];
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    final firstK = _lunation(startUtc) - 1;
    final lastK = _lunation(endUtc) + 1;
    final result = <MoonPhaseEvent>[];
    for (var cycle = firstK; cycle <= lastK; cycle++) {
      for (var type = 0; type < 4; type++) {
        final jde = _phaseJde(cycle + type * 0.25, type);
        final utcJd = jde - _deltaTSeconds(2000 + cycle / 12.3685) / 86400;
        final utc = _dateFromJulianDay(utcJd);
        if (!utc.isBefore(startUtc) && utc.isBefore(endUtc)) {
          result.add(MoonPhaseEvent(
            phase: switch (type) {
              0 => MoonPhase.newMoon,
              1 => MoonPhase.firstQuarter,
              2 => MoonPhase.fullMoon,
              _ => MoonPhase.lastQuarter,
            },
            localTime: utc.toLocal(),
          ));
        }
      }
    }
    result.sort((a, b) => a.localTime.compareTo(b.localTime));
    return result;
  }

  int _lunation(DateTime utc) =>
      ((utc.year + (utc.month - 0.5) / 12 - 2000) * 12.3685).floor();

  double _phaseJde(double k, int phaseType) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;
    final e = 1 - 0.002516 * t - 0.0000074 * t2;
    final m = _rad(2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3);
    final mp = _rad(201.5643 +
        385.81693528 * k +
        0.0107582 * t2 +
        0.00001238 * t3 -
        0.000000058 * t4);
    final f = _rad(160.7108 +
        390.67050284 * k -
        0.0016118 * t2 -
        0.00000227 * t3 +
        0.000000011 * t4);
    final omega =
        _rad(124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3);

    var correction = 0.0;
    if (phaseType == 0 || phaseType == 2) {
      final full = phaseType == 2;
      correction = (full ? -0.40614 : -0.40720) * _sin(mp) +
          (full ? 0.17302 : 0.17241) * e * _sin(m) +
          (full ? 0.01614 : 0.01608) * _sin(2 * mp) +
          0.01043 * _sin(2 * f) +
          0.00734 * e * _sin(mp - m) -
          0.00515 * e * _sin(mp + m) +
          0.00209 * e * e * _sin(2 * m) -
          0.00111 * _sin(mp - 2 * f) -
          0.00057 * _sin(mp + 2 * f) +
          0.00056 * e * _sin(2 * mp + m) -
          0.00042 * _sin(3 * mp) +
          0.00042 * e * _sin(m + 2 * f) +
          0.00038 * e * _sin(m - 2 * f) -
          0.00024 * e * _sin(2 * mp - m) -
          0.00017 * _sin(omega) -
          0.00007 * _sin(mp + 2 * m) +
          0.00004 * _sin(2 * mp - 2 * f) +
          0.00004 * _sin(3 * m) +
          0.00003 * _sin(mp + m - 2 * f) +
          0.00003 * _sin(2 * mp + 2 * f) -
          0.00003 * _sin(mp + m + 2 * f) +
          0.00003 * _sin(mp - m + 2 * f) -
          0.00002 * _sin(mp - m - 2 * f) -
          0.00002 * _sin(3 * mp + m) +
          0.00002 * _sin(4 * mp);
    } else {
      correction = -0.62801 * _sin(mp) +
          0.17172 * e * _sin(m) -
          0.01183 * e * _sin(mp + m) +
          0.00862 * _sin(2 * mp) +
          0.00804 * _sin(2 * f) +
          0.00454 * e * _sin(mp - m) +
          0.00204 * e * e * _sin(2 * m) -
          0.00180 * _sin(mp - 2 * f) -
          0.00070 * _sin(mp + 2 * f) -
          0.00040 * _sin(3 * mp) -
          0.00034 * e * _sin(2 * mp - m) +
          0.00032 * e * _sin(m + 2 * f) +
          0.00032 * e * _sin(m - 2 * f) -
          0.00028 * e * _sin(2 * mp + m) +
          0.00027 * e * _sin(2 * mp - 2 * f) -
          0.00017 * _sin(omega);
      final w = 0.00306 -
          0.00038 * e * _cos(m) +
          0.00026 * _cos(mp) -
          0.00002 * _cos(mp - m) +
          0.00002 * _cos(mp + m) +
          0.00002 * _cos(2 * f);
      correction += phaseType == 1 ? w : -w;
    }

    return 2451550.09766 +
        29.530588861 * k +
        0.00015437 * t2 -
        0.000000150 * t3 +
        0.00000000073 * t4 +
        correction;
  }

  double _rad(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double radians) => math.sin(radians);
  double _cos(double radians) => math.cos(radians);

  double _julianDay(DateTime date) {
    final y0 = date.year;
    final m0 = date.month;
    final day =
        date.day + (date.hour + (date.minute + date.second / 60) / 60) / 24;
    final a = ((14 - m0) / 12).floor();
    final y = y0 + 4800 - a;
    final m = m0 + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045 -
        0.5;
  }

  DateTime _dateFromJulianDay(double jd) =>
      DateTime.fromMillisecondsSinceEpoch(((jd - 2440587.5) * 86400000).round(),
          isUtc: true);

  double _deltaTSeconds(num year) {
    final t = year - 2000;
    return 62.92 + 0.32217 * t + 0.005589 * t * t;
  }
}
