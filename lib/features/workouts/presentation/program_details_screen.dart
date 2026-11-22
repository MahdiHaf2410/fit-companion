import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../data/workout_repository.dart';
import 'exercise_picker.dart';
import 'muscle_heatmap.dart' show muscleName;
import 'workout_providers.dart';
import 'workouts_screen.dart' show startWorkoutAndOpen;

final _programDetailsProvider = StreamProvider.autoDispose.family<ProgramWithExercises?, String>((ref, id) {
  return ref.watch(workoutRepositoryProvider).watchProgramDetails(id);
});

class ProgramDetailsScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final async = ref.watch(_programDetailsProvider(programId));
    final hasActive = ref.watch(activeWorkoutSessionProvider).value != null;

    return async.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('$e'))),
      data: (details) {
        if (details == null) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.commonError)));
        }
        final prog = details.program;
        final isTemplate = prog.isTemplate;
        final totalSets = details.exercises.fold<int>(0, (a, e) => a + e.programExercise.targetSets);
        final muscles = details.exercises.map((e) => e.exercise.muscleGroup).toSet();

        return Scaffold(
          appBar: AppBar(
            title: Text(prog.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              if (!isTemplate) ...[
                IconButton(
                  tooltip: l10n.programEdit,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => context.push('/workouts/program/${prog.id}/edit'),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.commonDelete),
                        content: Text(l10n.programDeleteConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref.read(workoutRepositoryProvider).deleteProgram(prog.id);
                      if (context.mounted) context.pop();
                    }
                  },
                ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: isTemplate
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.library_add_rounded),
                      label: Text(l10n.templateUse),
                      onPressed: () async {
                        final id = await ref.read(workoutRepositoryProvider).copyTemplate(prog.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.templateCopied)));
                          context.pushReplacement('/workouts/program/$id/edit');
                        }
                      },
                    )
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(hasActive ? l10n.dashboardResumeWorkout : l10n.dashboardStartWorkout),
                      onPressed: () => hasActive ? context.push('/workouts/active') : startWorkoutAndOpen(context, ref, program: prog),
                    ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            children: [
              AppCard(
                gradient: context.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTemplate) ...[
                      Pill(label: l10n.templateBadge, color: AppColors.violet, icon: Icons.auto_awesome_rounded),
                      const SizedBox(height: 8),
                    ],
                    if (prog.description?.isNotEmpty ?? false) ...[
                      Text(prog.description!, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 10),
                    ],
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill(label: l10n.workoutsExercisesCount(details.exercises.length), color: theme.colorScheme.primary),
                        Pill(label: '$totalSets ${l10n.commonSets}', color: AppColors.violet),
                        for (final m in muscles) Pill(label: muscleName(l10n, m), color: AppColors.cyan),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (details.exercises.isEmpty)
                AppCard(child: Text(l10n.programEmptyHint, style: theme.textTheme.bodyMedium)),
              for (int i = 0; i < details.exercises.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    onTap: () => context.push('/workouts/exercise/${details.exercises[i].exercise.id}'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary.withAlpha(40),
                          child: Text('${i + 1}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exerciseDisplayName(details.exercises[i].exercise, locale),
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              Text(
                                '${details.exercises[i].programExercise.targetSets} × ${details.exercises[i].programExercise.targetReps} • '
                                '${l10n.workoutsRest} ${details.exercises[i].programExercise.targetRestSeconds}s',
                                style: theme.textTheme.bodySmall,
                              ),
                              if (details.exercises[i].programExercise.notes?.isNotEmpty ?? false)
                                Text(details.exercises[i].programExercise.notes!,
                                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        Icon(context.forwardChevron, color: context.textSecondary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
