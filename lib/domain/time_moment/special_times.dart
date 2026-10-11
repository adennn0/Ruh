/// Çift (ayna) ve palindromik saat kataloğu.
///
/// Ayna / çift saat: saat ve dakika aynıdır (11:11, 14:14, 22:22).
/// Palindrom: HHMM dört hanesi palindromdur (14:41, 12:21, 23:32).
/// Kesişimler (11:11, 22:22) tek kayıtta `both` olarak işaretlenir.
library special_times;

enum SpecialTimeKind { mirror, palindrome, both }

class SpecialTime {
  const SpecialTime({
    required this.hour,
    required this.minute,
    required this.kind,
  });

  final int hour;
  final int minute;
  final SpecialTimeKind kind;

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get minutesOfDay => hour * 60 + minute;

  bool get isMirror =>
      kind == SpecialTimeKind.mirror || kind == SpecialTimeKind.both;

  bool get isPalindrome =>
      kind == SpecialTimeKind.palindrome || kind == SpecialTimeKind.both;

  @override
  bool operator ==(Object other) =>
      other is SpecialTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

class SpecialTimes {
  SpecialTimes._();

  static final List<SpecialTime> all = List.unmodifiable(_build());

  static SpecialTime? parse(String label) {
    final parts = label.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    for (final t in all) {
      if (t.hour == h && t.minute == m) return t;
    }
    return null;
  }

  static bool isSpecial(String label) => parse(label) != null;

  static List<SpecialTime> _build() {
    final byKey = <int, SpecialTime>{};

    void add(int h, int m, SpecialTimeKind kind) {
      final key = h * 60 + m;
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = SpecialTime(hour: h, minute: m, kind: kind);
        return;
      }
      if (existing.kind != kind) {
        byKey[key] = SpecialTime(
          hour: h,
          minute: m,
          kind: SpecialTimeKind.both,
        );
      }
    }

    for (var h = 0; h <= 23; h++) {
      add(h, h, SpecialTimeKind.mirror);
    }

    for (var h = 0; h <= 23; h++) {
      for (var m = 0; m <= 59; m++) {
        final a = h ~/ 10;
        final b = h % 10;
        final c = m ~/ 10;
        final d = m % 10;
        if (a == d && b == c) {
          add(h, m, SpecialTimeKind.palindrome);
        }
      }
    }

    final list = byKey.values.toList()
      ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    return list;
  }
}
