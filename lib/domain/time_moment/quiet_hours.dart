class QuietHours {
  const QuietHours({required this.startMinutes, required this.endMinutes});

  final int startMinutes;
  final int endMinutes;

  /// Geceyi aşan aralık (ör. 22:00–08:00) desteklenir.
  bool contains(int minutesOfDay) {
    if (startMinutes == endMinutes) return false;
    if (startMinutes < endMinutes) {
      return minutesOfDay >= startMinutes && minutesOfDay < endMinutes;
    }
    return minutesOfDay >= startMinutes || minutesOfDay < endMinutes;
  }
}
