import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entitlement/entitlement.dart';
import '../db/app_database.dart';
import '../db/daos/intention_dao.dart';
import '../../domain/models/enums.dart';
import 'streak_repository.dart';

/// Niyet domain modeli (DB satırından dönüştürülmüş)
class IntentionModel {
  const IntentionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.description,
    this.actionStep,
    this.affirmation,
    this.linkedStoneId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final int id;
  final String title;
  final String? description;
  final IntentionCategory category;
  final IntentionStatus status;
  final String? actionStep;
  final String? affirmation;
  final String? linkedStoneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  factory IntentionModel.fromRow(IntentionTableData row) => IntentionModel(
        id: row.id,
        title: row.title,
        description: row.description,
        category: IntentionCategory.values.firstWhere(
          (c) => c.name == row.category,
          orElse: () => IntentionCategory.personalGrowth,
        ),
        status: IntentionStatus.values.firstWhere(
          (s) => s.name == row.status,
          orElse: () => IntentionStatus.active,
        ),
        actionStep: row.actionStep,
        affirmation: row.affirmation,
        linkedStoneId: row.linkedStoneId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        completedAt: row.completedAt,
      );
}

class IntentionRepository {
  IntentionRepository(this._dao, this._streak, this._entitlement);

  final IntentionDao _dao;
  final StreakRepository _streak;
  final EntitlementService _entitlement;

  Stream<List<IntentionModel>> watchActive() => _dao
      .watchActive()
      .map((rows) => rows.map(IntentionModel.fromRow).toList());

  Stream<List<IntentionModel>> watchCompleted() => _dao
      .watchCompleted()
      .map((rows) => rows.map(IntentionModel.fromRow).toList());

  Stream<List<IntentionModel>> watchArchived() => _dao
      .watchArchived()
      .map((rows) => rows.map(IntentionModel.fromRow).toList());

  Future<int> countActive() => _dao.countActive();

  /// Yeni niyet ekle — limit kontrolü dahil
  Future<({bool success, String? error})> add({
    required String title,
    String? description,
    required IntentionCategory category,
    String? actionStep,
    String? affirmation,
  }) async {
    final activeCount = await _dao.countActive();
    // AppFeature.activeIntentions: -1 = sınırsız (premium), >=0 = limit
    final limit = _entitlement.limitFor(AppFeature.activeIntentions);
    final unlimited = limit < 0; // -1 = sınırsız

    if (!unlimited && activeCount >= limit) {
      return (
        success: false,
        error: 'Ücretsiz planda en fazla $limit aktif niyet oluşturabilirsin. '
            'Arşivleyerek yer açabilir veya Premium\'a geçebilirsin.',
      );
    }

    await _dao.insertIntention(
      IntentionTableCompanion(
        title: Value(title.trim()),
        description: Value(description?.trim()),
        category: Value(category.name),
        actionStep: Value(actionStep?.trim()),
        affirmation: Value(affirmation?.trim()),
      ),
    );

    // Streak aktivitesi kaydet
    await _streak.recordActivity(StreakBit.createOrUpdateIntention);

    // İlk niyet rozeti
    if (!await _streak.hasBadge(BadgeId.firstIntention.name)) {
      await _streak.awardBadge(BadgeId.firstIntention.name);
    }

    return (success: true, error: null);
  }

  Future<bool> update({
    required int id,
    required String title,
    String? description,
    required IntentionCategory category,
    String? actionStep,
    String? affirmation,
  }) async {
    final ok = await _dao.updateIntention(
      IntentionTableCompanion(
        id: Value(id),
        title: Value(title.trim()),
        description: Value(description?.trim()),
        category: Value(category.name),
        actionStep: Value(actionStep?.trim()),
        affirmation: Value(affirmation?.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (ok) await _streak.recordActivity(StreakBit.createOrUpdateIntention);
    return ok;
  }

  Future<void> complete(int id) async {
    await _dao.setStatus(id, 'completed');
    await _streak.recordActivity(StreakBit.createOrUpdateIntention);
  }

  Future<void> archive(int id) => _dao.setStatus(id, 'archived');

  Future<void> reactivate(int id) => _dao.setStatus(id, 'active');

  Future<int> delete(int id) => _dao.deleteIntention(id);
}

// ── Providers ─────────────────────────────────────────────────────────────────

final intentionRepositoryProvider = Provider<IntentionRepository>((ref) {
  return IntentionRepository(
    ref.watch(intentionDaoProvider),
    ref.watch(streakRepositoryProvider),
    ref.watch(entitlementServiceProvider),
  );
});

final activeIntentionsProvider = StreamProvider<List<IntentionModel>>((ref) {
  return ref.watch(intentionRepositoryProvider).watchActive();
});

final completedIntentionsProvider = StreamProvider<List<IntentionModel>>((ref) {
  return ref.watch(intentionRepositoryProvider).watchCompleted();
});

final archivedIntentionsProvider = StreamProvider<List<IntentionModel>>((ref) {
  return ref.watch(intentionRepositoryProvider).watchArchived();
});
