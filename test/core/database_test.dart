import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory SQLite database for fast isolated unit testing
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase persistence & seeding tests', () {
    test('Initial seeding creates Algerian foods, staples and exercises', () async {
      await db.seedInitialData();

      final allFoods = await db.select(db.foods).get();
      expect(allFoods, isNotEmpty);
      expect(allFoods.any((f) => f.nameAr?.contains('كسكسي') ?? false), isTrue);
      expect(allFoods.any((f) => f.id == 'staple_oats'), isTrue);

      final allExercises = await db.select(db.exercises).get();
      expect(allExercises, isNotEmpty);
      expect(allExercises.any((e) => e.id == 'ex_bench_press'), isTrue);

      final allPrograms = await db.select(db.workoutPrograms).get();
      expect(allPrograms.length, equals(3));
    });

    test('Seeding is idempotent (does not duplicate records)', () async {
      await db.seedInitialData();
      final initialCount = (await db.select(db.foods).get()).length;

      // Seed again
      await db.seedInitialData();
      final newCount = (await db.select(db.foods).get()).length;

      expect(newCount, equals(initialCount));
    });

    test('Food logging preserves nutritional snapshots', () async {
      await db.seedInitialData();

      final chicken = await (db.select(db.foods)..where((f) => f.id.equals('protein_chicken_breast_cooked'))).getSingle();

      // Log 200g of chicken breast
      final logDate = '2026-10-23';
      await db.into(db.foodLogs).insert(
        FoodLogsCompanion.insert(
          id: 'test_log_1',
          foodId: Value(chicken.id),
          date: logDate,
          timestamp: DateTime.now(),
          mealType: 'lunch',
          quantityG: 200.0,
          foodName: chicken.name,
          foodNameAr: Value(chicken.nameAr),
          calories: (chicken.caloriesPer100g * 200.0) / 100.0,
          protein: (chicken.proteinPer100g * 200.0) / 100.0,
          carbs: (chicken.carbsPer100g * 200.0) / 100.0,
          fat: (chicken.fatPer100g * 200.0) / 100.0,
        ),
      );

      final logs = await (db.select(db.foodLogs)..where((l) => l.date.equals(logDate))).get();
      expect(logs.length, equals(1));
      expect(logs.first.calories, equals(330.0)); // 165 * 2
      expect(logs.first.protein, equals(62.0));   // 31 * 2

      // Now suppose the food in the library is deleted
      await (db.delete(db.foods)..where((f) => f.id.equals(chicken.id))).go();

      // The log still retains its snapshot values!
      final preservedLog = await (db.select(db.foodLogs)..where((l) => l.id.equals('test_log_1'))).getSingle();
      expect(preservedLog.calories, equals(330.0));
      expect(preservedLog.foodName, equals(chicken.name));
    });

    test('Body metric logging and querying', () async {
      await db.into(db.bodyMetrics).insert(
        BodyMetricsCompanion.insert(
          id: 'metric_1',
          date: '2026-10-23',
          timestamp: DateTime.now(),
          weightKg: 82.5,
          waistCm: const Value(85.0),
        ),
      );

      final metrics = await db.select(db.bodyMetrics).get();
      expect(metrics.length, equals(1));
      expect(metrics.first.weightKg, equals(82.5));
      expect(metrics.first.waistCm, equals(85.0));
    });
  });
}
