import '../db/app_database.dart';

/// Deletes a profile and its private moments atomically. This explicit cleanup
/// also works with SQLite connections where foreign-key enforcement is off.
Future<void> deleteBondProfile(AppDatabase database, int bondId) {
  return database.transaction(() async {
    await (database.delete(database.bondMomentTable)
          ..where((row) => row.bondId.equals(bondId)))
        .go();
    await (database.delete(database.bondProfileTable)
          ..where((row) => row.id.equals(bondId)))
        .go();
  });
}
