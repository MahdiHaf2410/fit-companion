import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';

void main() {
  late AppDatabase db;
  late NutritionRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NutritionRepository(db);
    await db.seedInitialData();
  });

  tearDown(() async {
    await db.close();
  });

  group('NutritionRepository Unit Tests', () {
    test('Logs food and computes accurate nutritional snapshot', () async {
      final oats = await repo.getFoodById('staple_oats');
      expect(oats, isNotNull);

      final date = '2026-10-23';
      final now = DateTime.parse('${date}T08:30:00Z');

      // Log 80g of oats
      await repo.logFood(
        food: oats!,
        quantityGrams: 80.0,
        mealType: 'breakfast',
        timestamp: now,
      );

      final logs = await repo.getDailyLogs(date);
      expect(logs.length, equals(1));
      // 80g of oats (379 kcal per 100g) = 303.2 kcal
      expect(logs.first.calories, equals(303.2));
      // protein: 13.2 * 0.8 = 10.6g
      expect(logs.first.protein, equals(10.6));
    });

    test('Recipe creation aggregates nutrition and creates food item', () async {
      final chicken = await repo.getFoodById('protein_chicken_breast_cooked');
      final rice = await repo.getFoodById('staple_white_rice_cooked');
      expect(chicken, isNotNull);
      expect(rice, isNotNull);

      // Create a chicken & rice recipe with 2 servings
      await repo.saveRecipe(
        name: 'Meal Prep Chicken & Rice',
        nameAr: 'وجبة دجاج وأرز صحية',
        servings: 2,
        totalCookedYieldG: 600.0,
        ingredients: [
          {
            'foodId': chicken!.id,
            'foodName': chicken.name,
            'quantityG': 300.0,
            'calories': 495.0,
            'protein': 93.0,
            'carbs': 0.0,
            'fat': 10.8,
          },
          {
            'foodId': rice!.id,
            'foodName': rice.name,
            'quantityG': 300.0,
            'calories': 390.0,
            'protein': 8.1,
            'carbs': 84.6,
            'fat': 0.9,
          },
        ],
      );

      final recipes = await repo.watchRecipes().first;
      expect(recipes.length, equals(1));
      expect(recipes.first.totalCalories, equals(885.0));
      expect(recipes.first.servings, equals(2));

      // Check that a composite food was created in the foods table
      final compositeFood = await repo.getFoodById('recipe_food_${recipes.first.id}');
      expect(compositeFood, isNotNull);
      expect(compositeFood!.name, contains('Meal Prep Chicken & Rice'));
    });

    test('Deleting food log updates daily logs list', () async {
      final oats = await repo.getFoodById('staple_oats');
      final date = '2026-10-23';
      final now = DateTime.parse('${date}T08:30:00Z');

      await repo.logFood(
        food: oats!,
        quantityGrams: 80.0,
        mealType: 'breakfast',
        timestamp: now,
      );

      var logs = await repo.getDailyLogs(date);
      expect(logs.length, equals(1));

      await repo.deleteFoodLog(logs.first.id);

      logs = await repo.getDailyLogs(date);
      expect(logs, isEmpty);
    });
  });
}
