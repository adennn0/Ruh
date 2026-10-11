class TimeMomentPayload {
  const TimeMomentPayload({
    required this.localDate,
    required this.timeLabel,
  });

  final String localDate;
  final String timeLabel;

  static const prefix = 'tm';

  String encode() => '$prefix|$localDate|$timeLabel';

  static TimeMomentPayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length != 3 || parts[0] != prefix) return null;
    if (parts[1].isEmpty || parts[2].isEmpty) return null;
    return TimeMomentPayload(localDate: parts[1], timeLabel: parts[2]);
  }
}
