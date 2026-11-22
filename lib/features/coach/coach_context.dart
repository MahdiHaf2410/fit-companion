import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../workouts/data/workout_repository.dart';

/// Builds a SHORT text summary of the user's data for the AI coach.
/// Only aggregates are sent (no raw logs, no name/email) to limit what leaves the phone.
class CoachContextBuilder {
  final AppDatabase db;
  CoachContextBuilder(this.db);

  String _d(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<String> build() async {
    final lines = <String>[];
    final profile = await (db.select(db.profiles)..limit(1)).getSingleOrNull();
    final goal = await (db.select(db.goals)..limit(1)).getSingleOrNull();
    if (profile != null) {
      lines.add('Profile: ${profile.sex}, ${profile.age} y, ${profile.heightCm.toStringAsFixed(0)} cm, '
          '${profile.currentWeightKg.toStringAsFixed(1)} kg, activity ${profile.activityLevel}, trains ${profile.trainingFrequency ?? '?'}x/week.');
    }
    if (goal != null) {
      lines.add('Goal: ${goal.goalType}. Targets: ${goal.targetCalories} kcal, P ${goal.targetProteinGrams.toStringAsFixed(0)} g, '
          'C ${goal.targetCarbsGrams.toStringAsFixed(0)} g, F ${goal.targetFatGrams.toStringAsFixed(0)} g. TDEE ${goal.calculatedTdee.toStringAsFixed(0)}.');
    }

    // Nutrition: average of logged days in the last 7 days
    final now = DateTime.now();
    final from = _d(now.subtract(const Duration(days: 6)));
    final logs = await (db.select(db.foodLogs)..where((l) => l.date.isBiggerOrEqualValue(from))).get();
    final byDay = <String, (double, double)>{};
    for (final l in logs) {
      final v = byDay[l.date] ?? (0, 0);
      byDay[l.date] = (v.$1 + l.calories, v.$2 + l.protein);
    }
    if (byDay.isNotEmpty) {
      final kcal = byDay.values.fold<double>(0, (a, v) => a + v.$1) / byDay.length;
      final prot = byDay.values.fold<double>(0, (a, v) => a + v.$2) / byDay.length;
      lines.add('Nutrition last 7 days: logged ${byDay.length}/7 days, avg ${kcal.toStringAsFixed(0)} kcal and ${prot.toStringAsFixed(0)} g protein per logged day.');
    } else {
      lines.add('Nutrition: no food logged in the last 7 days.');
    }

    // Weight trend (30 days)
    final metrics = await (db.select(db.bodyMetrics)
          ..where((m) => m.timestamp.isBiggerOrEqualValue(now.subtract(const Duration(days: 30))))
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
        .get();
    if (metrics.length >= 2) {
      final change = metrics.last.weightKg - metrics.first.weightKg;
      lines.add('Weight 30 days: ${metrics.first.weightKg.toStringAsFixed(1)} → ${metrics.last.weightKg.toStringAsFixed(1)} kg '
          '(${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg, ${metrics.length} weigh-ins).');
    }
    final bf = metrics.where((m) => m.bodyFatPercent != null).toList();
    if (bf.isNotEmpty) lines.add('Body fat: ${bf.last.bodyFatPercent!.toStringAsFixed(1)} %.');

    // Training
    final repo = WorkoutRepository(db);
    final history = await repo.watchWorkoutHistory().first;
    final recent = history.where((s) => s.startTime.isAfter(now.subtract(const Duration(days: 14)))).toList();
    final stats = WorkoutRepository.computeStats(history, now);
    lines.add('Training: ${history.length} workouts total, ${recent.length} in the last 14 days, streak ${stats.currentStreakDays} days. '
        'Recent: ${recent.take(5).map((s) => s.programName ?? 'workout').join(', ')}.');
    final muscles = await repo.watchMuscleSets().first;
    if (muscles.isNotEmpty) {
      lines.add('Working sets last 7 days per muscle: ${muscles.entries.map((e) => '${e.key} ${e.value}').join(', ')}.');
    }
    final prs = await repo.watchPersonalRecords().first;
    if (prs.isNotEmpty) {
      lines.add('Best lifts (est. 1RM): ${prs.take(5).map((p) => '${p.exerciseName} ${p.weightKg}x${p.reps} (~${p.estimatedOneRepMax.toStringAsFixed(0)})').join('; ')}.');
    }
    return lines.join('\n');
  }
}
