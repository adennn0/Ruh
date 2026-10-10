import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/daos/journal_dao.dart';
import '../../domain/models/enums.dart';
import 'streak_repository.dart';

/// Günlük yazısı domain modeli
class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.entryDate,
    required this.type,
    this.title,
    required this.body,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String entryDate; // "YYYY-MM-DD"
  final JournalType type;
  final String? title;
  final String body;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory JournalEntryModel.fromRow(JournalEntryTableData row) =>
      JournalEntryModel(
        id: row.id,
        entryDate: row.entryDate,
        type: JournalType.values.firstWhere(
          (t) => t.name == row.type,
          orElse: () => JournalType.journal,
        ),
        title: row.title,
        body: row.body,
        mood: row.mood,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}

class JournalRepository {
  JournalRepository(this._dao, this._streak);
  final JournalDao _dao;
  final StreakRepository _streak;

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Stream<List<JournalEntryModel>> watchAll() =>
      _dao.watchAll().map((r) => r.map(JournalEntryModel.fromRow).toList());

  Stream<List<JournalEntryModel>> watchByType(JournalType type) => _dao
      .watchByType(type.name)
      .map((r) => r.map(JournalEntryModel.fromRow).toList());

  Future<List<JournalEntryModel>> forToday() async {
    final rows = await _dao.forDate(_todayStr());
    return rows.map(JournalEntryModel.fromRow).toList();
  }

  Future<void> save({
    required JournalType type,
    String? title,
    required String body,
    String? mood,
    String? date,
  }) async {
    await _dao.insertEntry(
      JournalEntryTableCompanion(
        entryDate: Value(date ?? _todayStr()),
        type: Value(type.name),
        title: Value(title?.trim()),
        body: Value(body.trim()),
        mood: Value(mood),
      ),
    );
    await _streak.recordActivity(StreakBit.saveJournal);

    // Rozet mantığı — tür bazlı
    if (type == JournalType.journal &&
        !await _streak.hasBadge(BadgeId.firstJournal.name)) {
      await _streak.awardBadge(BadgeId.firstJournal.name);
    }
    // Şükür ustası (10 şükür)
    if (type == JournalType.gratitude) {
      final count = await _dao.countByType('gratitude');
      if (count >= 10 &&
          !await _streak.hasBadge(BadgeId.gratitudeMaster.name)) {
        await _streak.awardBadge(BadgeId.gratitudeMaster.name);
      }
    }
    // Rüya gezgini (5 rüya)
    if (type == JournalType.dream) {
      final count = await _dao.countByType('dream');
      if (count >= 5 && !await _streak.hasBadge(BadgeId.dreamExplorer.name)) {
        await _streak.awardBadge(BadgeId.dreamExplorer.name);
      }
    }
  }

  Future<bool> update({
    required int id,
    String? title,
    required String body,
    String? mood,
  }) =>
      _dao.updateEntry(
        JournalEntryTableCompanion(
          id: Value(id),
          title: Value(title?.trim()),
          body: Value(body.trim()),
          mood: Value(mood),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> delete(int id) => _dao.deleteEntry(id);
}

// ── Providers ─────────────────────────────────────────────────────────────────

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(
    ref.watch(journalDaoProvider),
    ref.watch(streakRepositoryProvider),
  );
});

final allJournalEntriesProvider =
    StreamProvider<List<JournalEntryModel>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAll();
});
