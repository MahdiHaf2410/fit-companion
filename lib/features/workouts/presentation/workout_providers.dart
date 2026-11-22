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

final trainingStatsProvider = StreamProvider<TrainingStats>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchTrainingStats();
});

final sessionDetailProvider = StreamProvider.autoDispose.family<SessionDetail?, String>((ref, sessionId) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchSessionDetail(sessionId);
});

/// Previous performance for each exercise of the active session (keyed by ids).
final lastPerformanceProvider =
    FutureProvider.autoDispose.family<Map<String, List<WorkoutSet>>, String>((ref, exerciseIdsCsv) {
  final repo = ref.watch(workoutRepositoryProvider);
  final ids = exerciseIdsCsv.split(',').where((e) => e.isNotEmpty);
  return repo.getLastPerformanceFor(ids);
});

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');
final exerciseMuscleGroupFilterProvider = StateProvider<String>((ref) => 'all');

final exerciseSearchResultsProvider = StreamProvider<List<Exercise>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final group = ref.watch(exerciseMuscleGroupFilterProvider);
  return repo.searchExercisesStream(query: query, muscleGroup: group);
});

/// Live personal records (updates as soon as a set is completed).
final personalRecordsProvider = StreamProvider<List<PersonalRecord>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchPersonalRecords();
});

/// Ready-made programs (templates) the user can copy into "my programs".
final workoutTemplatesProvider = StreamProvider<List<WorkoutProgram>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchTemplates();
});
