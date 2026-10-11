String greetingFor(DateTime localTime, String? name) {
  final hour = localTime.hour;
  final prefix = hour >= 5 && hour < 12
      ? 'Günaydın'
      : hour >= 12 && hour < 18
          ? 'İyi günler'
          : hour >= 18 && hour < 22
              ? 'İyi akşamlar'
              : 'İyi geceler';
  final displayName = name?.trim();
  return displayName == null || displayName.isEmpty
      ? '$prefix ✨'
      : '$prefix, $displayName ✨';
}
