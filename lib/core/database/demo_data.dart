import 'package:drift/drift.dart';

import '../../features/hydration/data/water_repository.dart';
import '../../features/nutrition/data/nutrition_repository.dart';
import '../../features/progress/data/progress_repository.dart';
import '../../features/workouts/data/workout_repository.dart';
import 'app_database.dart';

/// Fills a SEPARATE demo database with a realistic profile and ~3 weeks of data.
/// Enabled with `--dart-define=DEMO=true` (see main.dart). Never touches the real DB.
class DemoData {
  DemoData._();

  static Future<void> seedIfEmpty(AppDatabase db) async {
    final existing = await (db.select(db.profiles)..limit(1)).getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now();
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: 'demo_profile',
          displayName: const Value('Mahdi'),
          age: 24,
          sex: 'male',
          heightCm: 178,
          currentWeightKg: 79.4,
          activityLevel: 'moderate',
          trainingFrequency: const Value(4),
          isOnboarded: const Value(true),
          updatedAt: now,
        ));
    await db.into(db.goals).insert(GoalsCompanion.insert(
          id: 'demo_goal',
          profileId: 'demo_profile',
          goalType: 'muscleGain',
          targetCalories: 2850,
          targetProteinGrams: 165,
          targetCarbsGrams: 340,
          targetFatGrams: 85,
          calculatedBmr: 1800,
          calculatedTdee: 2600,
          updatedAt: now,
        ));

    // Body weight trend
    final progress = ProgressRepository(db);
    for (int d = 24; d >= 0; d -= 2) {
      await progress.logMetric(
        weightKg: 81.2 - (24 - d) * 0.075 + (d % 4 == 0 ? 0.2 : -0.1),
        waistCm: d % 6 == 0 ? 84 - (24 - d) * 0.08 : null,
        date: now.subtract(Duration(days: d, hours: 2)),
      );
    }

    // Food today
    final nutrition = NutritionRepository(db);
    final foods = await (db.select(db.foods)..limit(6)).get();
    final meals = ['breakfast', 'lunch', 'lunch', 'dinner', 'snack'];
    for (int i = 0; i < meals.length && i < foods.length; i++) {
      await nutrition.logFood(food: foods[i], quantityGrams: 180 + i * 40.0, mealType: meals[i], timestamp: now);
    }

    // Water today
    final date = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await WaterRepository(db).addWater(date, 1500);

    // Workout history (completed sessions with progressive weights)
    final workouts = WorkoutRepository(db);
    for (final daysAgo in [13, 11, 8, 6, 4, 2, 1]) {
      final prog = await workouts.watchProgramDetails(
        daysAgo.isEven ? 'prog_push_hypertrophy' : 'prog_pull_hypertrophy',
      ).first;
      if (prog == null) continue;
      final id = await workouts.startWorkoutSession(
        programId: prog.program.id,
        programName: prog.program.name,
        exercises: prog.exercises,
      );
      final active = await workouts.watchActiveSession().first;
      for (final s in active!.sets) {
        await workouts.updateSet(setId: s.id, weightKg: 40 + (14 - daysAgo) * 1.5, reps: 10, isCompleted: true);
      }
      final day = now.subtract(Duration(days: daysAgo));
      final start = DateTime(day.year, day.month, day.day, 18);
      await workouts.finishWorkoutSession(sessionId: id);
      await (db.update(db.workoutSessions)..where((s) => s.id.equals(id))).write(
        WorkoutSessionsCompanion(startTime: Value(start), endTime: Value(start.add(const Duration(minutes: 62)))),
      );
    }
  }
}
