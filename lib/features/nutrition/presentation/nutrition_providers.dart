import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meal_tools_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/daily_nutrition_summary.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final selectedDateFormattedProvider = Provider<String>((ref) {
  final date = ref.watch(selectedDateProvider);
  return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
});

final dailyLogsProvider = StreamProvider<List<FoodLog>>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  final dateStr = ref.watch(selectedDateFormattedProvider);
  return repo.watchDailyLogs(dateStr);
});

String formatDateKey(DateTime date) =>
    "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

Stream<DailyNutritionSummary> _summaryFor(Ref ref, String dateStr) {
  final repo = ref.watch(nutritionRepositoryProvider);
  final goal = ref.watch(goalStreamProvider).value;
  return repo.watchDailySummary(
    dateStr,
    targetCalories: goal?.targetCalories ?? 2000,
    targetProtein: goal?.targetProteinGrams ?? 150.0,
    targetCarbs: goal?.targetCarbsGrams ?? 200.0,
    targetFat: goal?.targetFatGrams ?? 65.0,
  );
}

/// Summary for the date selected in the Nutrition tab.
final dailyNutritionSummaryProvider = StreamProvider<DailyNutritionSummary>((ref) {
  return _summaryFor(ref, ref.watch(selectedDateFormattedProvider));
});

/// Summary for TODAY (used by the dashboard so it never shows another day).
final todayNutritionSummaryProvider = StreamProvider<DailyNutritionSummary>((ref) {
  return _summaryFor(ref, formatDateKey(DateTime.now()));
});

final foodSearchQueryProvider = StateProvider<String>((ref) => '');
final foodCategoryFilterProvider = StateProvider<String>((ref) => 'all');

final foodSearchResultsProvider = StreamProvider<List<Food>>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  final query = ref.watch(foodSearchQueryProvider);
  final category = ref.watch(foodCategoryFilterProvider);
  return repo.searchFoodsStream(query: query, category: category);
});

final recipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  return repo.watchRecipes();
});

final mealToolsRepositoryProvider = Provider<MealToolsRepository>((ref) {
  return MealToolsRepository(ref.watch(databaseProvider));
});

final mealTemplatesProvider = StreamProvider<List<MealTemplateWithItems>>((ref) {
  return ref.watch(mealToolsRepositoryProvider).watchTemplates();
});
