import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/database_provider.dart';
import '../../nutrition/presentation/nutrition_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/water_repository.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepository(ref.watch(databaseProvider));
});

/// Water (ml) for the currently selected nutrition date.
final dailyWaterProvider = StreamProvider<int>((ref) {
  final date = ref.watch(selectedDateFormattedProvider);
  return ref.watch(waterRepositoryProvider).watchWater(date);
});

/// Water (ml) for TODAY, independent of the date selected in the nutrition tab.
final todayWaterProvider = StreamProvider<int>((ref) {
  final now = DateTime.now();
  final date = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  return ref.watch(waterRepositoryProvider).watchWater(date);
});

final waterGoalProvider = StreamProvider<int>((ref) {
  final weight = ref.watch(profileStreamProvider).value?.currentWeightKg;
  return ref
      .watch(waterRepositoryProvider)
      .watchGoal()
      .map((g) => g ?? WaterRepository.recommendedGoal(weight));
});
