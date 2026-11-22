import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../workouts/presentation/workout_providers.dart';
import 'measurements_card.dart';
import 'progress_providers.dart';
import '../../../l10n/app_localizations.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final metricsAsync = ref.watch(bodyMetricsStreamProvider);
    final trendPoints = ref.watch(weightTrendSeriesProvider);
    final selectedDays = ref.watch(progressTimeRangeDaysProvider);
    final prsAsync = ref.watch(personalRecordsProvider);
    final profile = ref.watch(profileStreamProvider).value;
    final locale = ref.watch(localeProvider).languageCode;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        actions: [
          IconButton(
            tooltip: l10n.progressAddMetric,
            icon: const Icon(Icons.add_circle_rounded),
            color: primary,
            iconSize: 30,
            onPressed: () => context.push('/progress/add'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, kNavBarClearance),
        children: [
          // ---------------- Body summary ----------------
          metricsAsync.maybeWhen(
            data: (metrics) {
              if (metrics.isEmpty) return const SizedBox.shrink();
              final current = metrics.last.weightKg;
              final change = current - metrics.first.weightKg;
              final h = (profile?.heightCm ?? 0) / 100;
              final bmi = h > 0 ? current / (h * h) : null;
              final changeColor = change.abs() < 0.05 ? context.textSecondary : (change < 0 ? AppColors.cyan : AppColors.flame);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.monitor_weight_rounded,
                        color: primary,
                        value: current.toStringAsFixed(1),
                        label: '${l10n.progressCurrent} (${l10n.commonKg})',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        icon: change <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                        color: changeColor,
                        // LRM keeps the sign on the left of the number in Arabic (RTL)
                        value: '‎${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                        label: l10n.progressChange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        icon: Icons.accessibility_new_rounded,
                        color: AppColors.violet,
                        value: bmi == null ? '—' : bmi.toStringAsFixed(1),
                        label: l10n.progressBmi,
                      ),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),

          // ---------------- Range ----------------
          SegmentedButton<int?>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 30, label: Text(l10n.progressTimeRange1M)),
              ButtonSegment(value: 90, label: Text(l10n.progressTimeRange3M)),
              ButtonSegment(value: null, label: Text(l10n.progressTimeRangeAll)),
            ],
            selected: {selectedDays},
            onSelectionChanged: (set) => ref.read(progressTimeRangeDaysProvider.notifier).state = set.first,
          ),

          // ---------------- Chart ----------------
          SectionHeader(title: l10n.progressWeightHistory),
          metricsAsync.when(
            data: (metrics) {
              if (metrics.isEmpty) {
                return AppCard(
                  child: EmptyStateView(
                    icon: Icons.show_chart_rounded,
                    title: l10n.progressWeightHistory,
                    description: l10n.progressNoMetrics,
                    actionLabel: l10n.progressAddMetric,
                    onAction: () => context.push('/progress/add'),
                  ),
                );
              }

              double minW = metrics.first.weightKg, maxW = metrics.first.weightKg;
              for (final m in metrics) {
                if (m.weightKg < minW) minW = m.weightKg;
                if (m.weightKg > maxW) maxW = m.weightKg;
              }
              final rawSpots = <FlSpot>[];
              final avgSpots = <FlSpot>[];
              for (int i = 0; i < trendPoints.length; i++) {
                rawSpots.add(FlSpot(i.toDouble(), trendPoints[i].weightKg));
                if (trendPoints[i].movingAverageKg != null) {
                  avgSpots.add(FlSpot(i.toDouble(), trendPoints[i].movingAverageKg!));
                }
              }
              final latestAvg = trendPoints.isNotEmpty ? trendPoints.last.movingAverageKg?.toStringAsFixed(1) : null;

              return AppCard(
                padding: const EdgeInsets.fromLTRB(12, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (latestAvg != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6, bottom: 12),
                        child: Pill(label: l10n.progressWeeklyAverage(latestAvg), color: primary, icon: Icons.auto_graph_rounded),
                      ),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        LineChartData(
                          minY: (minW - 2).clamp(0.0, 400.0).floorToDouble(),
                          maxY: (maxW + 2).ceilToDouble(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(color: context.borderColor, strokeWidth: 1, dashArray: [4, 4]),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => context.cardHigh,
                              getTooltipItems: (spots) => spots
                                  .map((s) => LineTooltipItem(
                                        '${s.y.toStringAsFixed(1)} ${l10n.commonKg}',
                                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w800),
                                      ))
                                  .toList(),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: theme.textTheme.labelSmall),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: (trendPoints.length / 4).ceilToDouble().clamp(1.0, 50.0),
                                getTitlesWidget: (val, _) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= trendPoints.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(DateFormat.Md(locale).format(trendPoints[idx].date), style: theme.textTheme.labelSmall),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: rawSpots,
                              isCurved: true,
                              color: primary.withAlpha(110),
                              barWidth: 2,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                  radius: 3,
                                  color: primary,
                                  strokeWidth: 0,
                                ),
                              ),
                            ),
                            if (avgSpots.length > 1)
                              LineChartBarData(
                                spots: avgSpots,
                                isCurved: true,
                                color: primary,
                                barWidth: 3.5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
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
              );
            },
            loading: () => const AppCard(child: SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
          ),

          // ---------------- Body measurements ----------------
          ...metricsAsync.maybeWhen(
            data: (metrics) {
              final has = metrics.any((m) =>
                  m.waistCm != null || m.chestCm != null || m.armCm != null || m.thighCm != null || m.hipsCm != null || m.bodyFatPercent != null);
              if (!has) return const <Widget>[];
              return [SectionHeader(title: l10n.measureTitle), MeasurementsCard(metrics: metrics)];
            },
            orElse: () => const <Widget>[],
          ),

          // ---------------- PRs ----------------
          SectionHeader(title: l10n.progressExercisePRs),
          prsAsync.when(
            data: (prs) {
              if (prs.isEmpty) {
                return AppCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 36, color: AppColors.carbs),
                      const SizedBox(height: 8),
                      Text(l10n.progressNoPRs, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              final best = prs.first.estimatedOneRepMax;
              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  children: [
                    for (int i = 0; i < prs.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      InkWell(
                        onTap: () => context.push('/workouts/exercise/${prs[i].exerciseId}'),
                        child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            IconBadge(
                              icon: Icons.emoji_events_rounded,
                              color: i == 0 ? AppColors.carbs : (i < 3 ? AppColors.violet : context.textSecondary),
                              size: 38,
                              iconSize: 19,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prs[i].exerciseName,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: best == 0 ? 0 : prs[i].estimatedOneRepMax / best,
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.progressSetFormat(
                                    prs[i].weightKg.toStringAsFixed(prs[i].weightKg % 1 == 0 ? 0 : 1),
                                    prs[i].reps,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: primary),
                                ),
                                Text('${l10n.progressEst1RM} ${prs[i].estimatedOneRepMax.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l10n.commonError}: $e'),
          ),

          // ---------------- Recent logs ----------------
          SectionHeader(
            title: l10n.progressRecentLogs,
            actionLabel: l10n.progressAddMetric,
            onAction: () => context.push('/progress/add'),
          ),
          metricsAsync.maybeWhen(
            data: (metrics) {
              if (metrics.isEmpty) return const SizedBox.shrink();
              final reversed = metrics.reversed.take(10).toList();
              return Column(
                children: [
                  for (int i = 0; i < reversed.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(reversed[i].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: AppColors.error.withAlpha(40), borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        ),
                        // Delete first, then let the row animate out (avoids 'dismissed Dismissible still in tree').
                confirmDismiss: (_) async {
                  await ref.read(progressRepositoryProvider).deleteMetric(reversed[i].id);
                  return true;
                },
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat.yMMMd(locale).format(reversed[i].timestamp),
                                        style: theme.textTheme.titleSmall),
                                    if (reversed[i].notes?.isNotEmpty ?? false)
                                      Text(reversed[i].notes!, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              if (reversed[i].waistCm != null) ...[
                                Pill(label: '${reversed[i].waistCm!.toStringAsFixed(0)} ${l10n.commonCm}', color: AppColors.violet),
                                const SizedBox(width: 8),
                              ],
                              Text('${reversed[i].weightKg.toStringAsFixed(1)} ${l10n.commonKg}',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              if (i + 1 < reversed.length) ...[
                                const SizedBox(width: 6),
                                _Delta(delta: reversed[i].weightKg - reversed[i + 1].weightKg),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  final double delta;
  const _Delta({required this.delta});

  @override
  Widget build(BuildContext context) {
    if (delta.abs() < 0.05) return Icon(Icons.remove_rounded, size: 16, color: context.textSecondary);
    final down = delta < 0;
    return Icon(
      down ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
      size: 16,
      color: down ? AppColors.cyan : AppColors.flame,
    );
  }
}
