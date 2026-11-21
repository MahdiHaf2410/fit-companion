import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  Stream<Profile?> watchProfile() {
    return (_db.select(_db.profiles)..limit(1)).watchSingleOrNull();
  }

  Future<Profile?> getProfile() async {
    return (_db.select(_db.profiles)..limit(1)).getSingleOrNull();
  }

  Stream<Goal?> watchGoal() {
    return (_db.select(_db.goals)..limit(1)).watchSingleOrNull();
  }

  Future<Goal?> getGoal() async {
    return (_db.select(_db.goals)..limit(1)).getSingleOrNull();
  }

  Future<void> saveProfileAndGoal({
    required ProfilesCompanion profile,
    required GoalsCompanion goal,
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.profiles).insertOnConflictUpdate(profile);
      await _db.into(_db.goals).insertOnConflictUpdate(goal);
    });
  }

  Future<void> updatePreferences({
    String? language,
    String? theme,
    String? units,
  }) async {
    final current = await getProfile();
    if (current != null) {
      await (_db.update(_db.profiles)..where((p) => p.id.equals(current.id))).write(
        ProfilesCompanion(
          preferredLanguage: language != null ? Value(language) : const Value.absent(),
          preferredTheme: theme != null ? Value(theme) : const Value.absent(),
          preferredUnits: units != null ? Value(units) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> clearAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.workoutSets).go();
      await _db.delete(_db.workoutSessions).go();
      await _db.delete(_db.foodLogs).go();
      await _db.delete(_db.recipeIngredients).go();
      await _db.delete(_db.recipes).go();
      await _db.delete(_db.bodyMetrics).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.profiles).go();
      // Re-seed starter foods and exercises
      await _db.seedInitialData();
    });
  }
}
