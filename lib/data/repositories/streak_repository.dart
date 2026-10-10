import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/limits.dart';
import '../db/app_database.dart';
import '../db/daos/streak_dao.dart';

/// Streak hesaplama sonucu
class StreakResult {
  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
    required this.earnedBadges,
  });
  final int currentStreak;
  final int longestStreak;
  final int totalDays;
  final List<String> earnedBadges; // yeni kazanılan badge ID'leri
}

/// Aktivite bit sabitleri — StreakDay.activityMask için
/// enums.dart'taki StreakActivity.mask() metoduyla uyumlu
class StreakBit {
  static const int readMessage = 1 << 0; // 1
  static const int createOrUpdateIntention = 1 << 1; // 2
  static const int saveJournal = 1 << 2; // 4
  static const int completeBreath = 1 << 3; // 8
  static const int saveTimeMoment = 1 << 4; // 16
}

class StreakRepository {
  StreakRepository(this._dao);
  final StreakDao _dao;

  String _localDateStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Haftanın pazartesi tarihini döner
  String _weekStart(DateTime dt) {
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    return _localDateStr(monday);
  }

  /// Aktivite kaydet ve streak güncelle
  Future<void> recordActivity(int activityBit) async {
    final today = _localDateStr(DateTime.now());
    await _dao.markActivity(today, activityBit);
  }

  /// Mevcut streak, en uzun streak, toplam gün hesapla
  Future<StreakResult> computeStreak() async {
    final days = await _dao.allDays();
    if (days.isEmpty) {
      return const StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalDays: 0,
        earnedBadges: [],
      );
    }

    // Aktif günleri sırala (eskiden yeniye — streak hesabı için)
    final activeDates = days
        .where((d) => d.activityMask > 0)
        .map((d) => d.localDate)
        .toList()
      ..sort();

    if (activeDates.isEmpty) {
      return const StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        totalDays: 0,
        earnedBadges: [],
      );
    }

    final todayStr = _localDateStr(DateTime.now());
    final yesterdayStr =
        _localDateStr(DateTime.now().subtract(const Duration(days: 1)));

    // Aktif mi yoksa dün aktif miydi?
    final lastActive = activeDates.last;
    final streakActive = lastActive == todayStr || lastActive == yesterdayStr;

    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final dateStr in activeDates) {
      final date = DateTime.parse(dateStr);
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff == 0) {
          // Aynı gün — atla
        } else if (diff == 2) {
          // Boşluk — dinlenme günü var mı?
          final weekStart = _weekStart(prevDate.add(const Duration(days: 1)));
          final restUsed = await _dao.restDayForWeek(weekStart);
          if (restUsed != null) {
            tempStreak++;
          } else {
            if (tempStreak > longestStreak) longestStreak = tempStreak;
            tempStreak = 1;
          }
        } else {
          if (tempStreak > longestStreak) longestStreak = tempStreak;
          tempStreak = 1;
        }
      }
      prevDate = date;
      if (tempStreak > longestStreak) longestStreak = tempStreak;
    }

    final currentStreak = streakActive ? tempStreak : 0;
    final totalDays = activeDates.length;

    // Yeni rozet kontrol
    final newBadges = await _checkAndAwardBadges(currentStreak, totalDays);

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalDays: totalDays,
      earnedBadges: newBadges,
    );
  }

  /// Milestone rozetleri kontrol et ve ver
  Future<List<String>> _checkAndAwardBadges(int streak, int totalDays) async {
    final newBadges = <String>[];
    for (final milestone in AppLimits.streakMilestones) {
      if (streak >= milestone) {
        final badgeId = 'streak_$milestone';
        if (!await _dao.hasBadge(badgeId)) {
          await _dao.awardBadge(badgeId);
          newBadges.add(badgeId);
        }
      }
    }
    return newBadges;
  }

  Future<void> awardBadge(String badgeId) => _dao.awardBadge(badgeId);
  Future<bool> hasBadge(String badgeId) => _dao.hasBadge(badgeId);
  Stream<List<BadgeTableData>> watchBadges() => _dao.watchBadges();
}

// ── Providers ─────────────────────────────────────────────────────────────────

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(streakDaoProvider));
});

final streakResultProvider = FutureProvider<StreakResult>((ref) {
  return ref.watch(streakRepositoryProvider).computeStreak();
});
