import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'muscle_heatmap.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Starts [program] (or a quick empty workout) and opens the active screen.
/// If a session is already running, the repository returns it instead.
Future<void> startWorkoutAndOpen(BuildContext context, WidgetRef ref, {WorkoutProgram? program}) async {
  HapticFeedback.mediumImpact();
  final repo = ref.read(workoutRepositoryProvider);
  final l10n = AppLocalizations.of(context)!;
  final details = program == null ? null : await repo.watchProgramDetails(program.id).first;
  await repo.startWorkoutSession(
    programId: program?.id,
    programName: program?.name ?? l10n.workoutsQuickStart,
    exercises: details?.exercises,
  );
  if (context.mounted) context.push('/workouts/active');
}

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final programsAsync = ref.watch(workoutProgramsProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final stats = ref.watch(trainingStatsProvider).value;
    final locale = ref.watch(localeProvider).languageCode;
    final hasActive = activeSessionAsync.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutsTitle),
        actions: [
          IconButton(
            tooltip: l10n.toolsTitle,
            icon: const Icon(Icons.construction_rounded),
            onPressed: () => context.push('/tools'),
          ),
          IconButton(
            tooltip: l10n.workoutsExerciseLibrary,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/workouts/exercises'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, kNavBarClearance),
        children: [
          // ---------------- Active banner ----------------
          if (hasActive) ...[
            FadeSlideIn(
              child: AppCard(
                onTap: () => context.push('/workouts/active'),
                gradient: AppColors.violetGradient,
                border: Border.all(color: Colors.transparent),
                child: Row(
                  children: [
                    const _PulseDot(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.workoutsActiveSession,
                              style: TextStyle(color: AppColors.onSecondary.withValues(alpha: 0.75), fontWeight: FontWeight.w700, fontSize: 12)),
                          Text(
                            '${activeSessionAsync.value!.session.programName ?? ''} • '
                            '${activeSessionAsync.value!.sets.where((s) => s.isCompleted).length}/${activeSessionAsync.value!.sets.length} ${l10n.commonSets}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.onSecondary, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.onSecondary,
                        foregroundColor: AppColors.violet,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => context.push('/workouts/active'),
                      child: Text(l10n.dashboardResumeWorkout),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ---------------- Stats ----------------
          FadeSlideIn(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.flame,
                    value: '${stats?.currentStreakDays ?? 0}',
                    label: l10n.statsStreak,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.violet,
                    value: '${stats?.workoutsThisWeek ?? 0}',
                    label: l10n.statsThisWeek,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    icon: Icons.stacked_bar_chart_rounded,
                    color: AppColors.cyan,
                    value: NumberFormat.compact(locale: locale).format(stats?.volumeThisWeekKg ?? 0),
                    label: '${l10n.statsVolume} (${l10n.commonKg})',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Quick start ----------------
          if (!hasActive)
            FadeSlideIn(
              index: 2,
              child: AppCard(
                onTap: () => startWorkoutAndOpen(context, ref),
                gradient: context.heroGradient,
                child: Row(
                  children: [
                    IconBadge(
                      icon: Icons.bolt_rounded,
                      color: AppColors.lime,
                      gradient: AppColors.limeGradient,
                      size: 50,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.workoutsQuickStart, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(l10n.workoutsQuickStartDesc, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 30),
                  ],
                ),
              ),
            ),

          // ---------------- Muscles this week ----------------
          SectionHeader(title: l10n.heatmapTitle),
          const MuscleHeatmapCard(),

          // ---------------- Programs ----------------
          SectionHeader(
            title: l10n.workoutsPrograms,
            actionLabel: l10n.workoutsCreateProgram,
            onAction: () => context.push('/workouts/programs/create'),
          ),
          programsAsync.when(
            data: (programs) {
              if (programs.isEmpty) {
                return AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 44, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(l10n.programsEmptyTitle, textAlign: TextAlign.center, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(l10n.programsEmptyBody, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.workoutsCreateProgram),
                          onPressed: () => context.push('/workouts/programs/create'),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final palette = [AppColors.lime, AppColors.violet, AppColors.cyan, AppColors.flame, AppColors.fat];
              return Column(
                children: [
                  for (int i = 0; i < programs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FadeSlideIn(
                        index: i + 3,
                        child: _ProgramCard(
                          program: programs[i],
                          color: palette[i % palette.length],
                          canStart: !hasActive,
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (e, _) => Text('${l10n.commonError}: $e'),
          ),

          // ---------------- Ready-made templates ----------------
          const SizedBox(height: 4),
          AppCard(
            onTap: () => context.push('/workouts/templates'),
            child: Row(
              children: [
                IconBadge(icon: Icons.auto_awesome_rounded, color: AppColors.violet, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.templatesTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      Text(l10n.templatesSubtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(context.forwardChevron, color: context.textSecondary),
              ],
            ),
          ),

          // ---------------- History ----------------
          SectionHeader(title: l10n.workoutsHistory),
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 34, color: context.textSecondary),
                      const SizedBox(height: 8),
                      Text(l10n.workoutsNoHistory, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final session in history.take(30))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HistoryTile(session: session, locale: locale),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l10n.commonError}: $e'),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends ConsumerWidget {
  final WorkoutProgram program;
  final Color color;
  final bool canStart;

  const _ProgramCard({required this.program, required this.color, required this.canStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = context.isDark ? color : Color.lerp(color, Colors.black, 0.3)!;

    return AppCard(
      onTap: () => context.push('/workouts/program/${program.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 54,
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(program.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                if (program.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(program.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canStart)
            Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => startWorkoutAndOpen(context, ref, program: program),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.play_arrow_rounded, color: theme.colorScheme.onPrimary, semanticLabel: l10n.workoutsStart),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WorkoutSession session;
  final String locale;

  const _HistoryTile({required this.session, required this.locale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mins = session.endTime?.difference(session.startTime).inMinutes ?? 0;

    return AppCard(
      onTap: () => context.push('/workouts/session/${session.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(context.isDark ? 30 : 24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(DateFormat.d(locale).format(session.startTime),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, height: 1)),
                Text(DateFormat.MMM(locale).format(session.startTime), style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.programName ?? l10n.workoutsQuickStart,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: [
                    _Meta(icon: Icons.timer_outlined, text: l10n.sessionMinutes(mins)),
                    _Meta(icon: Icons.layers_outlined, text: '${session.totalCompletedSets} ${l10n.commonSets}'),
                    _Meta(
                      icon: Icons.fitness_center_rounded,
                      text: '${NumberFormat.compact(locale: locale).format(session.totalVolumeKg)} ${l10n.commonKg}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            context.forwardChevron,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.textSecondary),
        const SizedBox(width: 3),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.lime,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.lime.withAlpha(140), blurRadius: 10)],
        ),
      ),
    );
  }
}
