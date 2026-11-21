import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../data/workout_repository.dart';
import '../../../l10n/app_localizations.dart';

class ProgramDetailsScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final repo = ref.watch(workoutRepositoryProvider);
    final programDetailsStream = repo.watchProgramDetails(programId);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    return StreamBuilder<ProgramWithExercises?>(
      stream: programDetailsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final details = snapshot.data;
        if (details == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.commonError)),
          );
        }

        final prog = details.program;

        return Scaffold(
          appBar: AppBar(
            title: Text(prog.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.commonDelete),
                      content: const Text('Are you sure you want to delete this workout program?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await repo.deleteProgram(programId);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prog.description != null && prog.description!.isNotEmpty) ...[
                  Text(prog.description!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(l10n.workoutsDays(prog.scheduledDays), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.workoutsExercises,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = details.exercises[i];
                    final exName = (isAr && item.exercise.nameAr != null && item.exercise.nameAr!.isNotEmpty)
                        ? item.exercise.nameAr!
                        : item.exercise.name;

                    return AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.primary,
                            radius: 16,
                            child: Text('${item.programExercise.sortOrder}'),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item.programExercise.targetSets} sets × ${item.programExercise.targetReps} reps • ${item.programExercise.targetRestSeconds}s rest",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.dashboardStartWorkout),
                    onPressed: () async {
                      await repo.startWorkoutSession(
                        programId: prog.id,
                        programName: prog.name,
                        exercises: details.exercises,
                      );
                      if (context.mounted) {
                        context.push('/workouts/active');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
