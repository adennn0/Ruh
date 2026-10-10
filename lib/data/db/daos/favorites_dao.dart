import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'favorites_dao.g.dart';

@DriftAccessor(tables: [FavoriteTable])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.db);

  Stream<List<FavoriteTableData>> watchAll() =>
      (select(favoriteTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<bool> isFavorite(String contentType, String contentId) async {
    final row = await (select(favoriteTable)
          ..where((t) =>
              t.contentType.equals(contentType) &
              t.contentId.equals(contentId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> toggle(
    String contentType,
    String contentId,
    String? cachedText,
  ) async {
    final existing = await (select(favoriteTable)
          ..where((t) =>
              t.contentType.equals(contentType) &
              t.contentId.equals(contentId)))
        .getSingleOrNull();
    if (existing != null) {
      await (delete(favoriteTable)
            ..where((t) =>
                t.contentType.equals(contentType) &
                t.contentId.equals(contentId)))
          .go();
    } else {
      await into(favoriteTable).insert(
        FavoriteTableCompanion(
          contentType: Value(contentType),
          contentId: Value(contentId),
          cachedText: Value(cachedText),
        ),
      );
    }
  }

  Future<void> remove(int id) =>
      (delete(favoriteTable)..where((t) => t.id.equals(id))).go();
}
