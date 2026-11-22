import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';

/// Raw numbers achievements are computed from.
class AchievementStats {
  final int workouts;
  final int longestStreak;
  final int prs;
  final int foodDays;
  final int waterGoalDays;
  final int weighIns;
  final double totalVolumeKg;

  const AchievementStats({
    this.workouts = 0,
    this.longestStreak = 0,
    this.prs = 0,
    this.foodDays = 0,
    this.waterGoalDays = 0,
    this.weighIns = 0,
    this.totalVolumeKg = 0,
  });
}

class AchievementDef {
  final String id;
  final IconData icon;
  final Color color;
  final double target;
  final double Function(AchievementStats s) value;

  const AchievementDef(this.id, this.icon, this.color, this.target, this.value);
}

class Achievement {
  final AchievementDef def;
  final double current;

  Achievement(this.def, this.current);

  bool get unlocked => current >= def.target;
  double get progress => (current / def.target).clamp(0.0, 1.0);
}

final achievementDefs = <AchievementDef>[
  AchievementDef('first_workout', Icons.flag_rounded, AppColors.lime, 1, (s) => s.workouts.toDouble()),
  AchievementDef('workouts_10', Icons.fitness_center_rounded, AppColors.lime, 10, (s) => s.workouts.toDouble()),
  AchievementDef('workouts_50', Icons.fitness_center_rounded, AppColors.violet, 50, (s) => s.workouts.toDouble()),
  AchievementDef('workouts_100', Icons.military_tech_rounded, AppColors.carbs, 100, (s) => s.workouts.toDouble()),
  AchievementDef('streak_3', Icons.local_fire_department_rounded, AppColors.flame, 3, (s) => s.longestStreak.toDouble()),
  AchievementDef('streak_7', Icons.local_fire_department_rounded, AppColors.flame, 7, (s) => s.longestStreak.toDouble()),
  AchievementDef('streak_30', Icons.whatshot_rounded, AppColors.error, 30, (s) => s.longestStreak.toDouble()),
  AchievementDef('first_pr', Icons.emoji_events_rounded, AppColors.carbs, 1, (s) => s.prs.toDouble()),
  AchievementDef('prs_25', Icons.emoji_events_rounded, AppColors.violet, 25, (s) => s.prs.toDouble()),
  AchievementDef('food_7', Icons.restaurant_rounded, AppColors.protein, 7, (s) => s.foodDays.toDouble()),
  AchievementDef('food_30', Icons.restaurant_menu_rounded, AppColors.protein, 30, (s) => s.foodDays.toDouble()),
  AchievementDef('water_7', Icons.water_drop_rounded, AppColors.water, 7, (s) => s.waterGoalDays.toDouble()),
  AchievementDef('weigh_10', Icons.monitor_weight_rounded, AppColors.cyan, 10, (s) => s.weighIns.toDouble()),
  AchievementDef('volume_10t', Icons.stacked_bar_chart_rounded, AppColors.lime, 10000, (s) => s.totalVolumeKg),
  AchievementDef('volume_100t', Icons.landscape_rounded, AppColors.carbs, 100000, (s) => s.totalVolumeKg),
];

(String, String) achievementText(AppLocalizations l10n, String id) => switch (id) {
      'first_workout' => (l10n.achFirstWorkout, l10n.achFirstWorkoutDesc),
      'workouts_10' => (l10n.achWorkouts10, l10n.achWorkoutsDesc(10)),
      'workouts_50' => (l10n.achWorkouts50, l10n.achWorkoutsDesc(50)),
      'workouts_100' => (l10n.achWorkouts100, l10n.achWorkoutsDesc(100)),
      'streak_3' => (l10n.achStreak3, l10n.achStreakDesc(3)),
      'streak_7' => (l10n.achStreak7, l10n.achStreakDesc(7)),
      'streak_30' => (l10n.achStreak30, l10n.achStreakDesc(30)),
      'first_pr' => (l10n.achFirstPr, l10n.achFirstPrDesc),
      'prs_25' => (l10n.achPrs25, l10n.achPrsDesc(25)),
      'food_7' => (l10n.achFood7, l10n.achFoodDesc(7)),
      'food_30' => (l10n.achFood30, l10n.achFoodDesc(30)),
      'water_7' => (l10n.achWater7, l10n.achWaterDesc(7)),
      'weigh_10' => (l10n.achWeigh10, l10n.achWeighDesc(10)),
      'volume_10t' => (l10n.achVolume10t, l10n.achVolumeDesc('10')),
      'volume_100t' => (l10n.achVolume100t, l10n.achVolumeDesc('100')),
      _ => (id, ''),
    };

class AchievementsRepository {
  final AppDatabase _db;
  static const seenKey = 'achievements_seen';

  AchievementsRepository(this._db);

  Stream<AchievementStats> watchStats() {
    return _db
        .customSelect('SELECT 1', readsFrom: {
          _db.workoutSessions,
          _db.workoutSets,
          _db.foodLogs,
          _db.bodyMetrics,
          _db.appPreferences,
        })
        .watch()
        .asyncMap((_) => computeStats());
  }

  Future<AchievementStats> computeStats() async {
    final sessions = await (_db.select(_db.workoutSessions)..where((s) => s.status.equals('completed'))).get();
    final days = sessions.map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day)).toSet().toList()..sort();
    int longest = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > longest) longest = run;
      prev = d;
    }
    final prs = await (_db.selectOnly(_db.workoutSets)
          ..addColumns([_db.workoutSets.id.count()])
          ..where(_db.workoutSets.isPersonalRecord.equals(true)))
        .map((r) => r.read(_db.workoutSets.id.count()) ?? 0)
        .getSingle();
    final foodDays = await (_db.selectOnly(_db.foodLogs, distinct: true)..addColumns([_db.foodLogs.date]))
        .map((r) => r.read(_db.foodLogs.date))
        .get();
    final weighIns = await (_db.selectOnly(_db.bodyMetrics)..addColumns([_db.bodyMetrics.id.count()]))
        .map((r) => r.read(_db.bodyMetrics.id.count()) ?? 0)
        .getSingle();
    final prefs = await (_db.select(_db.appPreferences)..where((p) => p.key.like('water_%'))).get();
    final goal = int.tryParse(prefs.where((p) => p.key == 'water_goal_ml').firstOrNull?.value ?? '') ?? 2500;
    final waterDays = prefs
        .where((p) => p.key != 'water_goal_ml' && (int.tryParse(p.value) ?? 0) >= goal)
        .length;
    final volume = sessions.fold<double>(0, (a, s) => a + s.totalVolumeKg);

    return AchievementStats(
      workouts: sessions.length,
      longestStreak: longest,
      prs: prs,
      foodDays: foodDays.length,
      waterGoalDays: waterDays,
      weighIns: weighIns,
      totalVolumeKg: volume,
    );
  }

  Future<Set<String>> getSeen() async {
    final row = await (_db.select(_db.appPreferences)..where((p) => p.key.equals(seenKey))).getSingleOrNull();
    return (row?.value ?? '').split(',').where((e) => e.isNotEmpty).toSet();
  }

  Future<void> markSeen(Set<String> ids) async {
    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion(key: const Value(seenKey), value: Value(ids.join(','))),
        );
  }
}

final achievementsRepositoryProvider = Provider<AchievementsRepository>((ref) {
  return AchievementsRepository(ref.watch(databaseProvider));
});

final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  return ref.watch(achievementsRepositoryProvider).watchStats().map(
        (stats) => achievementDefs.map((d) => Achievement(d, d.value(stats))).toList(),
      );
});
