import '../../../core/utils/exercise_video.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../data/workout_repository.dart';

final exerciseHistoryProvider = StreamProvider.autoDispose.family<List<ExerciseSessionStat>, String>((ref, id) {
  return ref.watch(workoutRepositoryProvider).watchExerciseHistory(id);
});

final exerciseInfoProvider = FutureProvider.autoDispose.family<Exercise?, String>((ref, id) {
  return ref.watch(workoutRepositoryProvider).getExercise(id);
});

/// Progress of a single exercise: e1RM chart, bests and session history.
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  int _metric = 0; // 0 = e1RM, 1 = top weight, 2 = volume

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final exercise = ref.watch(exerciseInfoProvider(widget.exerciseId)).value;
    final historyAsync = ref.watch(exerciseHistoryProvider(widget.exerciseId));
    final name = exercise == null
        ? ''
        : (locale == 'ar' && (exercise.nameAr?.isNotEmpty ?? false) ? exercise.nameAr! : exercise.name);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (exercise != null)
            IconButton(
              tooltip: l10n.exerciseWatchHow,
              icon: const Icon(Icons.play_circle_fill_rounded),
              onPressed: () => openExerciseVideo(context, exercise.name),
            ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart_rounded, size: 48, color: context.textSecondary),
                    const SizedBox(height: 12),
                    Text(l10n.exerciseNoHistory, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    if (exercise != null) ...[
                      const SizedBox(height: 14),
                      ExerciseVideoButton(englishName: exercise.name),
                    ],
                    if (exercise?.instructions != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        locale == 'ar' && exercise!.instructionsAr != null ? exercise.instructionsAr! : exercise!.instructions!,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          final bestE1rm = history.map((h) => h.bestE1rm).reduce((a, b) => a > b ? a : b);
          final topWeight = history.map((h) => h.topWeightKg).reduce((a, b) => a > b ? a : b);
          final totalSets = history.fold<int>(0, (a, h) => a + h.sets);
          double value(ExerciseSessionStat h) => switch (_metric) { 1 => h.topWeightKg, 2 => h.volumeKg, _ => h.bestE1rm };
          final spots = [for (int i = 0; i < history.length; i++) FlSpot(i.toDouble(), value(history[i]))];
          final values = spots.map((s) => s.y);
          final minY = values.reduce((a, b) => a < b ? a : b);
          final maxY = values.reduce((a, b) => a > b ? a : b);
          final pad = ((maxY - minY) * 0.15).clamp(2.0, double.infinity);
          final first = value(history.first);
          final last = value(history.last);
          final change = first == 0 ? 0.0 : (last - first) / first * 100;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            children: [
              Row(
                children: [
                  Expanded(child: StatTile(icon: Icons.emoji_events_rounded, color: AppColors.carbs, value: bestE1rm.toStringAsFixed(1), label: l10n.progressEst1RM)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(icon: Icons.fitness_center_rounded, color: AppColors.violet, value: topWeight.toStringAsFixed(1), label: l10n.exerciseTopWeight)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(icon: Icons.layers_rounded, color: AppColors.cyan, value: '$totalSets', label: l10n.commonSets)),
                ],
              ),
              const SizedBox(height: 14),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 0, label: Text(l10n.progressEst1RM)),
                  ButtonSegment(value: 1, label: Text(l10n.exerciseTopWeight)),
                  ButtonSegment(value: 2, label: Text(l10n.statsVolume)),
                ],
                selected: {_metric},
                onSelectionChanged: (s) => setState(() => _metric = s.first),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.fromLTRB(10, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (history.length > 1)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6, bottom: 10),
                        child: Pill(
                          label: '‎${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                          color: change >= 0 ? primary : AppColors.flame,
                          icon: change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        ),
                      ),
                    SizedBox(
                      height: 210,
                      child: LineChart(
                        LineChartData(
                          minY: (minY - pad).clamp(0, double.infinity).floorToDouble(),
                          maxY: (maxY + pad).ceilToDouble(),
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(color: context.borderColor, strokeWidth: 1, dashArray: [4, 4]),
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => context.cardHigh,
                              getTooltipItems: (ts) => ts
                                  .map((t) => LineTooltipItem(
                                        '${t.y.toStringAsFixed(1)} ${l10n.commonKg}\n${history[t.x.toInt()].bestSet}',
                                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800),
                                      ))
                                  .toList(),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Text(NumberFormat.compact(locale: locale).format(v), style: theme.textTheme.labelSmall),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: (history.length / 4).ceilToDouble().clamp(1, 100),
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= history.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(DateFormat.Md(locale).format(history[i].date), style: theme.textTheme.labelSmall),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: primary,
                              barWidth: 3.5,
                              dotData: FlDotData(
                                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3.5, color: primary, strokeWidth: 0),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [primary.withAlpha(70), primary.withAlpha(0)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SectionHeader(title: l10n.workoutsHistory),
              for (final h in history.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    onTap: () => context.push('/workouts/session/${h.sessionId}'),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat.yMMMd(locale).format(h.date), style: theme.textTheme.titleSmall),
                              Text('${h.sets} ${l10n.commonSets} • ${NumberFormat.compact(locale: locale).format(h.volumeKg)} ${l10n.commonKg}',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(h.bestSet, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: primary)),
                            Text('${l10n.progressEst1RM} ${h.bestE1rm.toStringAsFixed(0)}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
