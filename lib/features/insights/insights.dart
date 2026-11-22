import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/services/health_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/insights.dart';
import '../../core/utils/strength_calculator.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../profile/presentation/profile_providers.dart';

/// Reads the data the offline analytics need.
class InsightsRepository {
  final AppDatabase db;
  InsightsRepository(this.db);

  static DateTime _day(String ymd) {
    final p = ymd.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  Future<TdeeResult?> tdee() async {
    final since = DateTime.now().subtract(const Duration(days: 35));
    final logs = await (db.select(db.foodLogs)..where((l) => l.isEaten.equals(true) & l.timestamp.isBiggerOrEqualValue(since))).get();
    final daily = <DateTime, double>{};
    for (final l in logs) {
      final d = _day(l.date);
      daily[d] = (daily[d] ?? 0) + l.calories;
    }
    final metrics = await (db.select(db.bodyMetrics)..where((m) => m.timestamp.isBiggerOrEqualValue(since))).get();
    return AdaptiveTdee.compute(dailyIntake: daily, weights: [for (final m in metrics) (m.timestamp, m.weightKg)]);
  }

  Stream<TdeeResult?> watchTdee() => db
      .customSelect('SELECT 1', readsFrom: {db.foodLogs, db.bodyMetrics})
      .watch()
      .asyncMap((_) => tdee());

  Future<FatigueReport> fatigue() async {
    final since = DateTime.now().subtract(const Duration(days: 56));
    final rows = await (db.select(db.workoutSets).join([
      innerJoin(db.workoutSessions, db.workoutSessions.id.equalsExp(db.workoutSets.sessionId)),
    ])
          ..where(db.workoutSets.isCompleted.equals(true) &
              db.workoutSets.setType.equals('warmup').not() &
              db.workoutSessions.status.equals('completed') &
              db.workoutSessions.startTime.isBiggerOrEqualValue(since)))
        .get();
    final best = <String, (String, DateTime, double, List<double>)>{};
    final dates = <DateTime>{};
    for (final r in rows) {
      final s = r.readTable(db.workoutSessions);
      final w = r.readTable(db.workoutSets);
      dates.add(s.startTime);
      final key = '${s.id}|${w.exerciseId}';
      final e1 = StrengthCalculator.estimateOneRepMax(w.weightKg, w.reps);
      final prev = best[key];
      final rpes = [...?prev?.$4, if (w.rpe != null) w.rpe!];
      best[key] = (w.exerciseId, s.startTime, prev == null || e1 > prev.$3 ? e1 : prev.$3, rpes);
    }
    final perfs = [
      for (final v in best.values)
        ExercisePerf(v.$1, v.$2, v.$3, v.$4.isEmpty ? null : v.$4.reduce((a, b) => a + b) / v.$4.length),
    ];
    return FatigueAnalyzer.analyze(perfs: perfs, sessionDates: dates.toList());
  }

  Stream<FatigueReport> watchFatigue() => db
      .customSelect('SELECT 1', readsFrom: {db.workoutSessions, db.workoutSets})
      .watch()
      .asyncMap((_) => fatigue());

  /// Applies a new calorie target and moves the difference into carbs
  /// (protein and fat targets stay as they are).
  Future<void> applyCalorieTarget(int kcal) async {
    final goal = await (db.select(db.goals)..limit(1)).getSingleOrNull();
    if (goal == null) return;
    final carbs = ((kcal - goal.targetProteinGrams * 4 - goal.targetFatGrams * 9) / 4).clamp(50, 900).toDouble();
    await (db.update(db.goals)..where((g) => g.id.equals(goal.id))).write(GoalsCompanion(
      targetCalories: Value(kcal),
      targetCarbsGrams: Value(double.parse(carbs.toStringAsFixed(0))),
      updatedAt: Value(DateTime.now()),
    ));
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) => InsightsRepository(ref.watch(databaseProvider)));
final tdeeProvider = StreamProvider<TdeeResult?>((ref) => ref.watch(insightsRepositoryProvider).watchTdee());
final fatigueProvider = StreamProvider<FatigueReport>((ref) => ref.watch(insightsRepositoryProvider).watchFatigue());

// =============================================================================
// Cards
// =============================================================================

/// Adaptive TDEE: real maintenance calories from what you ate and your weight trend.
class AdaptiveTdeeCard extends ConsumerWidget {
  const AdaptiveTdeeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = ref.watch(tdeeProvider).value;
    final goal = ref.watch(goalStreamProvider).value;

    if (r == null) {
      return AppCard(
        child: Row(
          children: [
            IconBadge(icon: Icons.insights_rounded, color: AppColors.cyan, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.tdeeTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(l10n.tdeeNeedData, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final target = AdaptiveTdee.targetFor(goal?.goalType ?? 'maintenance', r.tdee);
    final current = goal?.targetCalories;
    final diff = current == null ? 0 : target - current;
    return AppCard(
      gradient: context.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.insights_rounded, color: AppColors.cyan, size: 42),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.tdeeTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
              Pill(
                label: switch (r.confidence) { 'high' => l10n.myFoodConfHigh, 'low' => l10n.myFoodConfLow, _ => l10n.myFoodConfMedium },
                color: switch (r.confidence) { 'high' => AppColors.success, 'low' => AppColors.flame, _ => AppColors.carbs },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(TextSpan(children: [
            TextSpan(text: '${r.tdee.round()} ', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            TextSpan(text: l10n.tdeePerDay, style: theme.textTheme.bodyMedium),
          ])),
          const SizedBox(height: 4),
          Text(
            l10n.tdeeExplain(r.avgIntake.round(), '${r.weeklyChangeKg >= 0 ? '+' : ''}${r.weeklyChangeKg.toStringAsFixed(2)}', r.daysLogged),
            style: theme.textTheme.bodySmall,
          ),
          if (current != null && diff.abs() >= 50) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(l10n.tdeeSuggest(target, current), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await ref.read(insightsRepositoryProvider).applyCalorieTarget(target);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tdeeApplied)));
                  },
                  child: Text(l10n.tdeeApply),
                ),
              ],
            ),
          ] else if (current != null) ...[
            const SizedBox(height: 8),
            Text('✓ ${l10n.tdeeOnTrack}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

/// Recovery / deload recommendation.
class FatigueCard extends ConsumerWidget {
  const FatigueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = ref.watch(fatigueProvider).value;
    if (r == null) return const SizedBox.shrink();
    final (color, icon, title, body) = switch (r.level) {
      FatigueLevel.fresh => (AppColors.success, Icons.battery_full_rounded, l10n.fatigueFresh, l10n.fatigueFreshBody),
      FatigueLevel.watch => (AppColors.carbs, Icons.battery_5_bar_rounded, l10n.fatigueWatch, l10n.fatigueWatchBody),
      FatigueLevel.deload => (AppColors.flame, Icons.battery_2_bar_rounded, l10n.fatigueDeload, l10n.fatigueDeloadBody),
    };
    final reasons = [
      for (final c in r.reasons)
        if (c.startsWith('declining:'))
          l10n.fatigueReasonDeclining(int.parse(c.split(':')[1]))
        else if (c == 'high_rpe')
          l10n.fatigueReasonRpe
        else if (c.startsWith('long_block:'))
          l10n.fatigueReasonWeeks(int.parse(c.split(':')[1])),
    ];
    return AppCard(
      border: Border.all(color: color.withValues(alpha: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    Text(body, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final s in reasons)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('• $s', style: theme.textTheme.bodySmall),
              ),
          ],
        ],
      ),
    );
  }
}

String coachNoteText(AppLocalizations l10n, CoachNote n) => switch (n.type) {
      CoachNoteType.skippedSet => l10n.noteSkipped,
      CoachNoteType.weightDropping => l10n.noteWeightDropping,
      CoachNoteType.missedReps => l10n.noteMissedReps,
      CoachNoteType.closeToPr => l10n.noteCloseToPr((n.value ?? 0).toStringAsFixed(n.value! % 1 == 0 ? 0 : 1)),
    };

// =============================================================================
// Sleep (Health Connect) vs training performance
// =============================================================================

final sleepReportProvider = FutureProvider.autoDispose<(HealthAvailability, SleepReport?)>((ref) async {
  final health = ref.watch(healthServiceProvider);
  final avail = await health.availability();
  if (avail != HealthAvailability.available) return (avail, null);
  final sleep = await health.sleepByNight(45);
  final db = ref.watch(databaseProvider);
  final since = DateTime.now().subtract(const Duration(days: 45));
  final sessions = await (db.select(db.workoutSessions)
        ..where((s) => s.status.equals('completed') & s.startTime.isBiggerOrEqualValue(since)))
      .get();
  return (avail, SleepAnalyzer.analyze(sleep: sleep, sessions: [for (final s in sessions) (s.startTime, s.totalVolumeKg)]));
});

class SleepCard extends ConsumerWidget {
  const SleepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final v = ref.watch(sleepReportProvider).value;
    if (v == null || v.$1 == HealthAvailability.unavailable) return const SizedBox.shrink();
    final r = v.$2;
    final header = Row(children: [
      IconBadge(icon: Icons.bedtime_rounded, color: AppColors.violet, size: 42),
      const SizedBox(width: 12),
      Expanded(child: Text(l10n.sleepTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
      if (r != null && r.nights > 0)
        Pill(
          label: '${r.avgHours.toStringAsFixed(1)} h',
          color: r.avgHours >= SleepAnalyzer.goodNight ? AppColors.success : AppColors.flame,
        ),
    ]);
    if (r == null) {
      return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          header,
          const SizedBox(height: 8),
          Text(l10n.sleepConnect, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final h = ref.read(healthServiceProvider);
              if (v.$1 == HealthAvailability.needsInstall) {
                await h.install();
              } else {
                await h.requestAccess();
              }
              ref.invalidate(sleepReportProvider);
            },
            icon: const Icon(Icons.link_rounded),
            label: Text(l10n.sleepConnectButton),
          ),
        ]),
      );
    }
    final diff = r.performanceDiffPct;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header,
        const SizedBox(height: 8),
        Text(l10n.sleepAvg(r.avgHours.toStringAsFixed(1), r.nights), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          diff == null
              ? l10n.sleepNeedMore
              : (diff >= 0 ? l10n.sleepBetter(diff.toStringAsFixed(0)) : l10n.sleepNoEffect),
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (r.avgHours < SleepAnalyzer.goodNight && r.nights > 0) ...[
          const SizedBox(height: 4),
          Text('💤 ${l10n.sleepTip}', style: theme.textTheme.bodySmall),
        ],
      ]),
    );
  }
}
