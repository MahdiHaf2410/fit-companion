import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/strength_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Summary of a completed workout: totals + every set per exercise.
class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final detailAsync = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.sessionDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.sessionDelete),
                  content: Text(l10n.sessionDeleteConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.commonDelete),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(workoutRepositoryProvider).deleteSession(sessionId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          if (detail == null) return Center(child: Text(l10n.workoutsNoHistory));
          final s = detail.session;
          final mins = s.endTime?.difference(s.startTime).inMinutes ?? 0;
          final groups = <String, List<WorkoutSet>>{};
          for (final set in detail.sets.where((x) => x.isCompleted)) {
            groups.putIfAbsent(set.exerciseId, () => []).add(set);
          }
          final prCount = detail.sets.where((x) => x.isPersonalRecord).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            children: [
              AppCard(
                gradient: context.heroGradient,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat.yMMMMEEEEd(locale).format(s.startTime), style: theme.textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(s.programName ?? l10n.workoutsQuickStart, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _Kpi(icon: Icons.timer_outlined, color: AppColors.violet, value: l10n.sessionMinutes(mins), label: l10n.workoutsElapsed)),
                        Expanded(child: _Kpi(icon: Icons.layers_rounded, color: AppColors.cyan, value: '${s.totalCompletedSets}', label: l10n.commonSets)),
                        Expanded(
                          child: _Kpi(
                            icon: Icons.fitness_center_rounded,
                            color: theme.colorScheme.primary,
                            value: NumberFormat.compact(locale: locale).format(s.totalVolumeKg),
                            label: '${l10n.statsVolume} (${l10n.commonKg})',
                          ),
                        ),
                        if (prCount > 0)
                          Expanded(child: _Kpi(icon: Icons.emoji_events_rounded, color: AppColors.carbs, value: '$prCount', label: 'PR')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final entry in groups.entries) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.push('/workouts/exercise/${entry.key}'),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.value.first.exerciseName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                            Icon(Icons.show_chart_rounded, size: 18, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < entry.value.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 28, child: Text('${i + 1}', style: theme.textTheme.labelLarge)),
                              Expanded(
                                child: Text(
                                  l10n.progressSetFormat(
                                    entry.value[i].weightKg.toStringAsFixed(entry.value[i].weightKg % 1 == 0 ? 0 : 1),
                                    entry.value[i].reps,
                                  ),
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${l10n.progressEst1RM} ${StrengthCalculator.estimateOneRepMax(entry.value[i].weightKg, entry.value[i].reps).toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              if (entry.value[i].isPersonalRecord) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.carbs),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _Kpi({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
