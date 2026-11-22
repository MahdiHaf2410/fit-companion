import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// Daily water intake stored in the generic key/value `AppPreferences` table
/// (key = `water_YYYY-MM-DD`, value = millilitres). No schema migration needed.
class WaterRepository {
  final AppDatabase _db;

  WaterRepository(this._db);

  static String keyFor(String date) => 'water_$date';
  static const goalKey = 'water_goal_ml';

  Stream<int> watchWater(String date) {
    return (_db.select(_db.appPreferences)..where((p) => p.key.equals(keyFor(date))))
        .watchSingleOrNull()
        .map((row) => int.tryParse(row?.value ?? '') ?? 0);
  }

  Stream<int?> watchGoal() {
    return (_db.select(_db.appPreferences)..where((p) => p.key.equals(goalKey)))
        .watchSingleOrNull()
        .map((row) => int.tryParse(row?.value ?? ''));
  }

  Future<int> getWater(String date) async {
    final row = await (_db.select(_db.appPreferences)..where((p) => p.key.equals(keyFor(date)))).getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 0;
  }

  Future<void> addWater(String date, int ml) async {
    final current = await getWater(date);
    final next = (current + ml).clamp(0, 20000);
    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion.insert(key: keyFor(date), value: next.toString()),
        );
  }

  Future<void> setGoal(int ml) async {
    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion(key: const Value(goalKey), value: Value(ml.toString())),
        );
  }

  /// Default recommendation: ~35 ml per kg of body weight, rounded to 250 ml.
  static int recommendedGoal(double? weightKg) {
    if (weightKg == null || weightKg <= 0) return 2500;
    final raw = weightKg * 35;
    return ((raw / 250).round() * 250).clamp(1500, 5000);
  }
}
