import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final programsAsync = ref.watch(workoutProgramsProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutsTitle),
        actions: [
          IconButton(
            tooltip: l10n.workoutsExerciseLibrary,
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => context.push('/workouts/exercises'),
          ),
          IconButton(
            tooltip: l10n.workoutsCreateProgram,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/workouts/programs/create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Workout Banner
            activeSessionAsync.when(
              data: (active) {
                if (active == null) return const SizedBox.shrink();
                final completedSets = active.sets.where((s) => s.isCompleted).length;
                return Column(
                  children: [
                    AppCard(
                      backgroundColor: theme.colorScheme.primary.withAlpha(25),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.workoutsActiveSession,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "${active.session.programName ?? 'Workout'} • $completedSets / ${active.sets.length} ${l10n.commonSets}",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/workouts/active'),
                            child: Text(l10n.dashboardResumeWorkout),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Workout Programs Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.workoutsPrograms,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.workoutsCreateProgram),
                  onPressed: () => context.push('/workouts/programs/create'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            programsAsync.when(
              data: (programs) {
                if (programs.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.fitness_center_rounded,
                    title: l10n.workoutsPrograms,
                    description: 'No programs created yet.',
                    actionLabel: l10n.workoutsCreateProgram,
                    onAction: () => context.push('/workouts/programs/create'),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: programs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final prog = programs[i];
                    return AppCard(
                      onTap: () => context.push('/workouts/program/${prog.id}'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.event_note_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prog.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.workoutsDays(prog.scheduledDays),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_circle_filled_rounded, size: 36),
                            color: theme.colorScheme.primary,
                            onPressed: () async {
                              final repo = ref.read(workoutRepositoryProvider);
                              final details = await repo.watchProgramDetails(prog.id).first;
                              await repo.startWorkoutSession(
                                programId: prog.id,
                                programName: prog.name,
                                exercises: details?.exercises,
                              );
                              if (context.mounted) {
                                context.push('/workouts/active');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
              error: (e, _) => Text('${l10n.commonError}: $e'),
            ),
            const SizedBox(height: 24),

            // Workout History
            Text(
              l10n.workoutsHistory,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          l10n.workoutsNoHistory,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final session = history[i];
                    final dateStr = DateFormat.yMMMd(currentLocale.languageCode).format(session.startTime);
                    final durationMins = session.endTime != null
                        ? session.endTime!.difference(session.startTime).inMinutes
                        : 0;

                    return AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.programName ?? 'Workout',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$dateStr • ${l10n.workoutsDuration(durationMins)}",
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  "${l10n.workoutsTotalVolume(session.totalVolumeKg.toInt().toString())} • ${l10n.workoutsTotalSets(session.totalCompletedSets)}",
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Colors.green),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('${l10n.commonError}: $e'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
