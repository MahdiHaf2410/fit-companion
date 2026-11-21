import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';
import '../data/workout_repository.dart';

final workoutProgramsProvider = StreamProvider<List<WorkoutProgram>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchPrograms();
});

final activeWorkoutSessionProvider = StreamProvider<ActiveSessionWithSets?>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchActiveSession();
});

final workoutHistoryProvider = StreamProvider<List<WorkoutSession>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkoutHistory();
});

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');
final exerciseMuscleGroupFilterProvider = StateProvider<String>((ref) => 'all');

final exerciseSearchResultsProvider = StreamProvider<List<Exercise>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final group = ref.watch(exerciseMuscleGroupFilterProvider);
  return repo.searchExercisesStream(query: query, muscleGroup: group);
});

final personalRecordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getPersonalRecords();
});
