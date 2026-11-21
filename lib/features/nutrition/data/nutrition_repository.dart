import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/energy_calculator.dart';
import '../domain/daily_nutrition_summary.dart';

class NutritionRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  NutritionRepository(this._db);

  Stream<List<FoodLog>> watchDailyLogs(String date) {
    return (_db.select(_db.foodLogs)
          ..where((tbl) => tbl.date.equals(date))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .watch();
  }

  Future<List<FoodLog>> getDailyLogs(String date) {
    return (_db.select(_db.foodLogs)
          ..where((tbl) => tbl.date.equals(date))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
        .get();
  }

  Stream<DailyNutritionSummary> watchDailySummary(String date, {int targetCalories = 2000, double targetProtein = 150, double targetCarbs = 200, double targetFat = 65}) {
    return watchDailyLogs(date).map((logs) {
      double cals = 0;
      double p = 0;
      double c = 0;
      double f = 0;

      for (final log in logs) {
        cals += log.calories;
        p += log.protein;
        c += log.carbs;
        f += log.fat;
      }

      return DailyNutritionSummary(
        caloriesConsumed: double.parse(cals.toStringAsFixed(1)),
        proteinConsumed: double.parse(p.toStringAsFixed(1)),
        carbsConsumed: double.parse(c.toStringAsFixed(1)),
        fatConsumed: double.parse(f.toStringAsFixed(1)),
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
      );
    });
  }

  Future<void> logFood({
    required Food food,
    required double quantityGrams,
    required String mealType,
    required DateTime timestamp,
  }) async {
    final date = "${timestamp.year.toString().padLeft(4, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";
    final calories = EnergyCalculator.calculateNutrient(nutrientPer100g: food.caloriesPer100g, quantityGrams: quantityGrams);
    final protein = EnergyCalculator.calculateNutrient(nutrientPer100g: food.proteinPer100g, quantityGrams: quantityGrams);
    final carbs = EnergyCalculator.calculateNutrient(nutrientPer100g: food.carbsPer100g, quantityGrams: quantityGrams);
    final fat = EnergyCalculator.calculateNutrient(nutrientPer100g: food.fatPer100g, quantityGrams: quantityGrams);

    await _db.into(_db.foodLogs).insert(
      FoodLogsCompanion.insert(
        id: _uuid.v4(),
        foodId: Value(food.id),
        date: date,
        timestamp: timestamp,
        mealType: mealType,
        quantityG: quantityGrams,
        foodName: food.name,
        foodNameAr: Value(food.nameAr),
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      ),
    );
  }

  Future<void> deleteFoodLog(String logId) async {
    await (_db.delete(_db.foodLogs)..where((l) => l.id.equals(logId))).go();
  }

  Stream<List<Food>> searchFoodsStream({
    String query = '',
    String category = 'all',
  }) {
    return (_db.select(_db.foods)
          ..where((f) {
            final matchesQuery = query.isEmpty
                ? const Constant(true)
                : (f.name.lower().contains(query.toLowerCase()) |
                   f.nameAr.lower().contains(query.toLowerCase()));
            final matchesCategory = category == 'all'
                ? const Constant(true)
                : f.category.equals(category);
            return matchesQuery & matchesCategory;
          })
          ..orderBy([(f) => OrderingTerm.desc(f.isFavorite), (f) => OrderingTerm.asc(f.name)]))
        .watch();
  }

  Future<Food?> getFoodById(String foodId) async {
    return (_db.select(_db.foods)..where((f) => f.id.equals(foodId))).getSingleOrNull();
  }

  Future<void> toggleFavorite(String foodId, bool currentFavorite) async {
    await (_db.update(_db.foods)..where((f) => f.id.equals(foodId))).write(
      FoodsCompanion(
        isFavorite: Value(!currentFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveCustomFood({
    required String name,
    String? nameAr,
    required String category,
    required double servingWeightG,
    required String servingDescription,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double? fiberPer100g,
    required String prepState,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.foods).insert(
      FoodsCompanion.insert(
        id: _uuid.v4(),
        name: name,
        nameAr: Value(nameAr),
        category: category,
        source: 'user',
        servingDescription: servingDescription,
        servingWeightG: servingWeightG,
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        fiberPer100g: Value(fiberPer100g),
        prepState: Value(prepState),
        isFavorite: const Value(false),
        isCustom: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Stream<List<Recipe>> watchRecipes() {
    return (_db.select(_db.recipes)..orderBy([(r) => OrderingTerm.desc(r.updatedAt)])).watch();
  }

  Future<void> saveRecipe({
    required String name,
    String? nameAr,
    required int servings,
    double? totalCookedYieldG,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final now = DateTime.now();
    final recipeId = _uuid.v4();

    double totalCals = 0;
    double totalP = 0;
    double totalC = 0;
    double totalF = 0;

    for (final ing in ingredients) {
      totalCals += (ing['calories'] as num).toDouble();
      totalP += (ing['protein'] as num).toDouble();
      totalC += (ing['carbs'] as num).toDouble();
      totalF += (ing['fat'] as num).toDouble();
    }

    await _db.transaction(() async {
      await _db.into(_db.recipes).insert(
        RecipesCompanion.insert(
          id: recipeId,
          name: name,
          nameAr: Value(nameAr),
          servings: Value(servings),
          totalCookedYieldG: Value(totalCookedYieldG),
          totalCalories: totalCals,
          totalProtein: totalP,
          totalCarbs: totalC,
          totalFat: totalF,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (final ing in ingredients) {
        await _db.into(_db.recipeIngredients).insert(
          RecipeIngredientsCompanion.insert(
            id: _uuid.v4(),
            recipeId: recipeId,
            foodId: ing['foodId'] as String,
            foodName: ing['foodName'] as String,
            quantityG: (ing['quantityG'] as num).toDouble(),
            calories: (ing['calories'] as num).toDouble(),
            protein: (ing['protein'] as num).toDouble(),
            carbs: (ing['carbs'] as num).toDouble(),
            fat: (ing['fat'] as num).toDouble(),
          ),
        );
      }

      // Also create a composite food entry for easy logging from the food library
      await _db.into(_db.foods).insert(
        FoodsCompanion.insert(
          id: 'recipe_food_$recipeId',
          name: 'Recipe: $name',
          nameAr: nameAr != null ? Value('وصفة: $nameAr') : const Value.absent(),
          category: 'custom',
          source: 'user',
          servingDescription: '1 serving (1 of $servings)',
          servingWeightG: (totalCookedYieldG != null && totalCookedYieldG > 0)
              ? (totalCookedYieldG / servings)
              : 250.0,
          caloriesPer100g: totalCookedYieldG != null && totalCookedYieldG > 0
              ? (totalCals / totalCookedYieldG) * 100
              : (totalCals / servings) / 2.5,
          proteinPer100g: totalCookedYieldG != null && totalCookedYieldG > 0
              ? (totalP / totalCookedYieldG) * 100
              : (totalP / servings) / 2.5,
          carbsPer100g: totalCookedYieldG != null && totalCookedYieldG > 0
              ? (totalC / totalCookedYieldG) * 100
              : (totalC / servings) / 2.5,
          fatPer100g: totalCookedYieldG != null && totalCookedYieldG > 0
              ? (totalF / totalCookedYieldG) * 100
              : (totalF / servings) / 2.5,
          prepState: const Value('cooked'),
          isCustom: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }
}
