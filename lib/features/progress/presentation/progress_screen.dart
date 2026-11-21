import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../workouts/presentation/workout_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        actions: [
          IconButton(
            tooltip: l10n.progressAddMetric,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/progress/add'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Toggle
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<int?>(
                    segments: [
                      ButtonSegment(value: 30, label: Text(l10n.progressTimeRange1M, style: const TextStyle(fontSize: 12))),
                      ButtonSegment(value: 90, label: Text(l10n.progressTimeRange3M, style: const TextStyle(fontSize: 12))),
                      ButtonSegment(value: null, label: Text(l10n.progressTimeRangeAll, style: const TextStyle(fontSize: 12))),
                    ],
                    selected: {selectedDays},
                    onSelectionChanged: (set) {
                      ref.read(progressTimeRangeDaysProvider.notifier).state = set.first;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weight Chart Card
            Text(
              l10n.progressWeightHistory,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            metricsAsync.when(
              data: (metrics) {
                if (metrics.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.show_chart_rounded,
                    title: l10n.progressWeightHistory,
                    description: l10n.progressNoMetrics,
                    actionLabel: l10n.progressAddMetric,
                    onAction: () => context.push('/progress/add'),
                  );
                }

                // Calculate min and max for chart bounds
                double minWeight = metrics.first.weightKg;
                double maxWeight = metrics.first.weightKg;
                for (final m in metrics) {
                  if (m.weightKg < minWeight) minWeight = m.weightKg;
                  if (m.weightKg > maxWeight) maxWeight = m.weightKg;
                }

                final minY = (minWeight - 2).clamp(0.0, 300.0);
                final maxY = maxWeight + 2;

                final rawSpots = <FlSpot>[];
                final avgSpots = <FlSpot>[];

                for (int i = 0; i < trendPoints.length; i++) {
                  final p = trendPoints[i];
                  rawSpots.add(FlSpot(i.toDouble(), p.weightKg));
                  if (p.movingAverageKg != null) {
                    avgSpots.add(FlSpot(i.toDouble(), p.movingAverageKg!));
                  }
                }

                final latestAvg = trendPoints.isNotEmpty && trendPoints.last.movingAverageKg != null
                    ? trendPoints.last.movingAverageKg!.toStringAsFixed(1)
                    : null;

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (latestAvg != null) ...[
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.progressWeeklyAverage(latestAvg),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minY: minY,
                            maxY: maxY,
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  getTitlesWidget: (val, _) => Text(
                                    val.toInt().toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  interval: (trendPoints.length / 4).ceilToDouble().clamp(1.0, 20.0),
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx >= 0 && idx < trendPoints.length) {
                                      final d = trendPoints[idx].date;
                                      return Text(
                                        "${d.month}/${d.day}",
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              // Raw logs line
                              LineChartBarData(
                                spots: rawSpots,
                                isCurved: true,
                                color: theme.colorScheme.primary.withAlpha(120),
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                              ),
                              // 7-day moving average line
                              if (avgSpots.length > 1)
                                LineChartBarData(
                                  spots: avgSpots,
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const AppCard(child: Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))),
              error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
            ),
            const SizedBox(height: 24),

            // Exercise Personal Records
            Text(
              l10n.progressExercisePRs,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            prsAsync.when(
              data: (prs) {
                if (prs.isEmpty) {
                  return AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Complete workout sets to establish your personal strength records!',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final pr = prs[i];
                    return AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                pr['exerciseName'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Text(
                            "${pr['maxWeightKg']} kg × ${pr['reps']} reps",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('${l10n.commonError}: $e'),
            ),
            const SizedBox(height: 24),

            // Recent Logs Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Logs',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l10n.progressAddMetric),
                  onPressed: () => context.push('/progress/add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            metricsAsync.when(
              data: (metrics) {
                if (metrics.isEmpty) return const SizedBox.shrink();
                final reversed = metrics.reversed.toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reversed.length.clamp(0, 10),
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final m = reversed[i];
                    return AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.date, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (m.notes != null && m.notes!.isNotEmpty)
                                Text(m.notes!, style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${m.weightKg.toStringAsFixed(1)} kg",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (m.waistCm != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  "${m.waistCm!.toInt()} cm",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
