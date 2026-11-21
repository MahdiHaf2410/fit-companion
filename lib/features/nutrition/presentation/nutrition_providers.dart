import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final dailyNutritionSummaryProvider = StreamProvider<DailyNutritionSummary>((ref) {
  final repo = ref.watch(nutritionRepositoryProvider);
  final dateStr = ref.watch(selectedDateFormattedProvider);
  final goalAsync = ref.watch(goalStreamProvider);

  final goal = goalAsync.value;
  final targetCalories = goal?.targetCalories ?? 2000;
  final targetProtein = goal?.targetProteinGrams ?? 150.0;
  final targetCarbs = goal?.targetCarbsGrams ?? 200.0;
  final targetFat = goal?.targetFatGrams ?? 65.0;

  return repo.watchDailySummary(
    dateStr,
    targetCalories: targetCalories,
    targetProtein: targetProtein,
    targetCarbs: targetCarbs,
    targetFat: targetFat,
  );
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
