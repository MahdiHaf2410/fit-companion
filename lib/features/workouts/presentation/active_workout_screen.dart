import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/strength_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../data/workout_repository.dart';
import '../../../core/utils/insights.dart';
import '../../insights/insights.dart' show coachNoteText;
import 'exercise_detail_screen.dart' show exerciseHistoryProvider;
import 'exercise_picker.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

String _fmtClock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String _fmtKg(double w) => w.toStringAsFixed(w % 1 == 0 ? 0 : 1);

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _ticker;
  DateTime? _restEndsAt;
  int _restTotal = 90;

  @override
  void initState() {
    super.initState();
    // Ask once for notification permission (rest timer on lock screen / watch).
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(notificationServiceProvider).requestPermission());
    // One ticker drives both the elapsed clock and the rest countdown.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_restEndsAt != null && DateTime.now().isAfter(_restEndsAt!)) {
        _restEndsAt = null;
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.workoutsRestDone)));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    setState(() {
      _restTotal = seconds;
      _restEndsAt = DateTime.now().add(Duration(seconds: seconds));
    });
    _syncRestNotification();
  }

  void _adjustRest(int delta) {
    if (_restEndsAt == null) return;
    setState(() {
      _restEndsAt = _restEndsAt!.add(Duration(seconds: delta));
      _restTotal = (_restTotal + delta).clamp(1, 3600);
      if (_restEndsAt!.isBefore(DateTime.now())) _restEndsAt = null;
    });
    _syncRestNotification();
  }

  void _skipRest() {
    setState(() => _restEndsAt = null);
    _syncRestNotification();
  }

  /// Live countdown notification: visible on the lock screen and mirrored to
  /// paired smartwatches; a second notification alerts when the rest ends.
  void _syncRestNotification() {
    final service = ref.read(notificationServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    if (_restEndsAt == null) {
      service.cancelRestTimer();
    } else {
      service.showRestTimer(
        endsAt: _restEndsAt!,
        title: l10n.workoutsRest,
        endTitle: l10n.workoutsRestDone,
        endBody: ref.read(activeWorkoutSessionProvider).value?.session.programName ?? '',
      );
    }
  }

  Future<void> _confirmDiscard(ActiveSessionWithSets active, AppLocalizations l10n) async {
    final repo = ref.read(workoutRepositoryProvider);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutsDiscardWorkout),
        content: Text(l10n.workoutsConfirmDiscard),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onSecondary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.workoutsDiscardWorkout),
          ),
        ],
      ),
    );
    if (discard == true) {
      await ref.read(notificationServiceProvider).cancelRestTimer();
      await repo.discardWorkoutSession(active.session.id);
      if (mounted) context.go('/workouts');
    }
  }

  Future<void> _confirmFinish(ActiveSessionWithSets active, AppLocalizations l10n) async {
    final repo = ref.read(workoutRepositoryProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutsFinishWorkout),
        content: Text(l10n.workoutsConfirmFinish),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonConfirm)),
        ],
      ),
    );
    if (confirm == true) {
      final id = active.session.id;
      await ref.read(notificationServiceProvider).cancelRestTimer();
      await repo.finishWorkoutSession(sessionId: id);
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dashboardWorkoutCompleted)));
        // Replace the active screen with the summary of the workout just finished.
        context.pushReplacement('/workouts/session/$id');
      }
    }
  }

  Future<void> _addExercise(ActiveSessionWithSets active) async {
    final exercise = await showExercisePicker(context);
    if (exercise != null) {
      await ref.read(workoutRepositoryProvider).addExerciseToSession(
            sessionId: active.session.id,
            exercise: exercise,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final locale = ref.watch(localeProvider).languageCode;

    return activeSessionAsync.when(
      data: (active) {
        if (active == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.workoutsActiveSession)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center_rounded, size: 48, color: context.textSecondary),
                  const SizedBox(height: 12),
                  Text(l10n.workoutsNoActive),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => context.go('/workouts'), child: Text(l10n.commonBack)),
                ],
              ),
            ),
          );
        }

        // Group sets by exercise, preserving insertion order
        final groups = <String, List<WorkoutSet>>{};
        for (final s in active.sets) {
          groups.putIfAbsent(s.exerciseId, () => []).add(s);
        }
        final done = active.sets.where((s) => s.isCompleted).length;
        final total = active.sets.length;
        final volume = active.sets.where((s) => s.isCompleted).fold<double>(0, (a, s) => a + s.weightKg * s.reps);
        final elapsed = DateTime.now().difference(active.session.startTime);
        final lastPerf = ref.watch(lastPerformanceProvider(groups.keys.join(','))).value ?? const {};
        final restLeft = _restEndsAt?.difference(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(active.session.programName ?? l10n.workoutsActiveSession,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleLarge),
                Text(_fmtClock(elapsed),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
              ],
            ),
            actions: [
              IconButton(
                tooltip: l10n.workoutsRestTimer,
                icon: const Icon(Icons.timer_outlined),
                onPressed: () => _startRest(90),
              ),
              IconButton(
                tooltip: l10n.workoutsDiscardWorkout,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () => _confirmDiscard(active, l10n),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => SizeTransition(sizeFactor: a, child: FadeTransition(opacity: a, child: c)),
                    child: restLeft == null
                        ? const SizedBox.shrink()
                        : _RestPanel(
                            key: const ValueKey('rest'),
                            remaining: restLeft,
                            total: _restTotal,
                            onAdjust: _adjustRest,
                            onSkip: _skipRest,
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flag_rounded),
                      label: Text(l10n.workoutsFinishWorkout),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () => _confirmFinish(active, l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // ---------------- Session summary ----------------
              AppCard(
                gradient: context.heroGradient,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ProgressRing(
                      progress: total == 0 ? 0 : done / total,
                      size: 62,
                      strokeWidth: 7,
                      color: theme.colorScheme.primary,
                      child: Text('$done/$total', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _SummaryStat(label: l10n.workoutsElapsed, value: _fmtClock(elapsed))),
                    Expanded(
                      child: _SummaryStat(
                        label: l10n.statsVolume,
                        value: '${NumberFormat.compact(locale: locale).format(volume)} ${l10n.commonKg}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (groups.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.playlist_add_rounded, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(l10n.workoutsEmptySession, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),

              // ---------------- Exercises ----------------
              for (int gi = 0; gi < groups.length; gi++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ExerciseCard(
                    sets: groups.values.elementAt(gi),
                    previous: lastPerf[groups.keys.elementAt(gi)],
                    restSeconds: active.restFor(groups.keys.elementAt(gi)),
                    onStartRest: _startRest,
                    sessionId: active.session.id,
                    targetReps: active.targetRepsByExercise[groups.keys.elementAt(gi)],
                    isCompound: active.exerciseTypes[groups.keys.elementAt(gi)] != 'isolation',
                    notes: active.notesByExercise[groups.keys.elementAt(gi)],
                    nextExerciseId: gi + 1 < groups.length ? groups.keys.elementAt(gi + 1) : null,
                    // Rest only after the LAST exercise of a superset
                    isLastInSuperset: () {
                      final g = groups.values.elementAt(gi).first.supersetGroup;
                      if (g == null) return true;
                      return gi + 1 >= groups.length || groups.values.elementAt(gi + 1).first.supersetGroup != g;
                    }(),
                  ),
                ),

              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.workoutsAddExercise),
                onPressed: () => _addExercise(active),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('${AppLocalizations.of(context)!.commonError}: $e'))),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ),
      ],
    );
  }
}

class _RestPanel extends StatelessWidget {
  final Duration remaining;
  final int total;
  final ValueChanged<int> onAdjust;
  final VoidCallback onSkip;

  const _RestPanel({super.key, required this.remaining, required this.total, required this.onAdjust, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final secs = remaining.inSeconds.clamp(0, 3600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        gradient: AppColors.violetGradient,
        border: Border.all(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ProgressRing(
              progress: total == 0 ? 0 : secs / total,
              size: 50,
              strokeWidth: 5,
              color: AppColors.onSecondary,
              trackColor: AppColors.onSecondary.withValues(alpha: 0.25),
              duration: const Duration(milliseconds: 950),
              child: Icon(Icons.timer_rounded, color: AppColors.onSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.workoutsRest, style: TextStyle(color: AppColors.onSecondary.withValues(alpha: 0.75), fontWeight: FontWeight.w700, fontSize: 12)),
                  Text(
                    _fmtClock(Duration(seconds: secs)),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSecondary,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            _RestBtn(label: '-15', onTap: () => onAdjust(-15)),
            const SizedBox(width: 6),
            _RestBtn(label: '+15', onTap: () => onAdjust(15)),
            const SizedBox(width: 6),
            _RestBtn(label: l10n.workoutsSkip, onTap: onSkip, strong: true),
          ],
        ),
      ),
    );
  }
}

class _RestBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool strong;
  const _RestBtn({required this.label, required this.onTap, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: strong ? AppColors.onSecondary : AppColors.onSecondary.withAlpha(40),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(label,
              style: TextStyle(
                color: strong ? AppColors.violet : AppColors.onSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              )),
        ),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  final List<WorkoutSet> sets;
  final List<WorkoutSet>? previous;
  final int restSeconds;
  final ValueChanged<int> onStartRest;
  final String sessionId;
  final int? targetReps;
  final bool isCompound;
  final String? notes;
  final String? nextExerciseId;
  final bool isLastInSuperset;

  const _ExerciseCard({
    required this.sets,
    required this.previous,
    required this.restSeconds,
    required this.onStartRest,
    required this.sessionId,
    this.targetReps,
    this.isCompound = true,
    this.notes,
    this.nextExerciseId,
    this.isLastInSuperset = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final repo = ref.read(workoutRepositoryProvider);
    final first = sets.first;
    final allDone = sets.every((s) => s.isCompleted);
    final hasPr = sets.any((s) => s.isPersonalRecord);
    final superset = first.supersetGroup;
    // Live coach notes (offline rules)
    final history = ref.watch(exerciseHistoryProvider(first.exerciseId)).value ?? const [];
    final prWeight = history.isEmpty ? null : history.map((h) => h.topWeightKg).reduce((a, b) => a > b ? a : b);
    final working = sets.where((s) => s.setType != 'warmup').toList();
    final coachNotes = WorkoutCoach.notes(
      setsDone: [for (final s in working) s.isCompleted],
      recentTopWeights: [for (final h in history.length > 3 ? history.sublist(history.length - 3) : history) h.topWeightKg],
      lastReps: [for (final s in previous ?? const <WorkoutSet>[]) if (s.setType != 'warmup') s.reps],
      targetReps: targetReps,
      currentTop: working.isEmpty ? null : working.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b),
      prWeight: prWeight,
    );
    final suggestion = previous == null
        ? null
        : StrengthCalculator.suggestNextWeight(
            lastSets: previous!,
            targetReps: targetReps ?? previous!.first.reps,
            isCompound: isCompound,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: allDone
              ? theme.colorScheme.primary.withAlpha(160)
              : (superset != null ? AppColors.violet.withAlpha(150) : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push('/workouts/exercise/${first.exerciseId}'),
                    child: Text(first.exerciseName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                ),
                if (hasPr) const Pill(label: 'PR', color: AppColors.carbs, icon: Icons.emoji_events_rounded, solid: true),
                const SizedBox(width: 4),
                Pill(label: '${restSeconds}s', color: AppColors.violet, icon: Icons.timer_outlined),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: context.textSecondary),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (v) async {
                    if (v == 'link') {
                      await repo.setSuperset(sessionId: sessionId, exerciseId: first.exerciseId, nextExerciseId: nextExerciseId);
                    } else if (v == 'unlink') {
                      await repo.setSuperset(sessionId: sessionId, exerciseId: first.exerciseId);
                    } else if (v == 'chart') {
                      if (context.mounted) context.push('/workouts/exercise/${first.exerciseId}');
                    }
                  },
                  itemBuilder: (_) => [
                    if (superset == null && nextExerciseId != null)
                      PopupMenuItem(value: 'link', child: ListTile(leading: const Icon(Icons.link_rounded), title: Text(l10n.setsSupersetWithNext))),
                    if (superset != null)
                      PopupMenuItem(value: 'unlink', child: ListTile(leading: const Icon(Icons.link_off_rounded), title: Text(l10n.setsRemoveSuperset))),
                    PopupMenuItem(value: 'chart', child: ListTile(leading: const Icon(Icons.show_chart_rounded), title: Text(l10n.exerciseProgress))),
                  ],
                ),
              ],
            ),
            if (superset != null || suggestion != null || notes != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (superset != null)
                    Pill(label: '${l10n.setsSuperset} ${String.fromCharCode(64 + superset)}', color: AppColors.violet, icon: Icons.link_rounded),
                  if (suggestion != null && suggestion.change == OverloadChange.increase)
                    Pill(
                      label: l10n.overloadIncrease('+${_fmtKg(suggestion.deltaKg)}'),
                      color: theme.colorScheme.primary,
                      icon: Icons.trending_up_rounded,
                    ),
                  if (suggestion != null && suggestion.change == OverloadChange.keep)
                    Pill(label: l10n.overloadKeep, color: AppColors.cyan, icon: Icons.drag_handle_rounded),
                  if (suggestion != null && suggestion.change == OverloadChange.decrease)
                    Pill(label: l10n.overloadDeload(_fmtKg(suggestion.weightKg)), color: AppColors.flame, icon: Icons.trending_down_rounded),
                ],
              ),
              if (notes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(notes!, style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ),
            ],
            if (previous != null && previous!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.workoutsPrevious}: ${previous!.map((s) => '${_fmtKg(s.weightKg)}×${s.reps}').join('  ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
            for (final n in coachNotes)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: (n.type == CoachNoteType.closeToPr ? AppColors.carbs : AppColors.cyan).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(n.type == CoachNoteType.closeToPr ? Icons.emoji_events_rounded : Icons.tips_and_updates_rounded,
                        size: 16, color: n.type == CoachNoteType.closeToPr ? AppColors.carbs : AppColors.cyan),
                    const SizedBox(width: 8),
                    Expanded(child: Text(coachNoteText(l10n, n), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 34, child: Text(l10n.workoutsSetHeader, style: theme.textTheme.labelSmall)),
                Expanded(child: Text(l10n.workoutsPrevious, textAlign: TextAlign.center, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Expanded(child: Text(l10n.workoutsWeightHeader, textAlign: TextAlign.center, style: theme.textTheme.labelSmall, maxLines: 1)),
                Expanded(child: Text(l10n.workoutsRepsHeader, textAlign: TextAlign.center, style: theme.textTheme.labelSmall, maxLines: 1)),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 4),
            for (int i = 0; i < sets.length; i++)
              Dismissible(
                key: ValueKey(sets[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.error.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                ),
                // Delete first, then let the row animate out (avoids 'dismissed Dismissible still in tree').
                confirmDismiss: (_) async {
                  await repo.deleteSet(sets[i].id);
                  return true;
                },
                child: _SetRow(
                  set: sets[i],
                  displayNumber: sets.take(i + 1).where((x) => x.setType != 'warmup').length,
                  onEditMeta: () => _editSetMeta(context, ref, sets[i]),
                  previous: (previous != null && i < previous!.length) ? previous![i] : null,
                  onSave: (weight, reps, completed) async {
                    final becamePr = await repo.updateSet(
                      setId: sets[i].id,
                      weightKg: weight,
                      reps: reps,
                      isCompleted: completed,
                    );
                    if (completed && !sets[i].isCompleted) {
                      HapticFeedback.mediumImpact();
                      if (isLastInSuperset) onStartRest(restSeconds);
                    }
                    if (becamePr && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.workoutsNewPR)));
                    }
                  },
                ),
              ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.workoutsAddSet),
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  final last = sets.last;
                  await repo.addSetToSession(
                    sessionId: sessionId,
                    exerciseId: last.exerciseId,
                    exerciseName: last.exerciseName,
                    setNumber: last.setNumber + 1,
                    weightKg: last.weightKg,
                    reps: last.reps,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _editSetMeta(BuildContext context, WidgetRef ref, WorkoutSet set) async {
  final l10n = AppLocalizations.of(context)!;
  String type = set.setType;
  double? rpe = set.rpe;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final theme = Theme.of(ctx);
        final types = {
          'normal': (l10n.setTypeNormal, Icons.fitness_center_rounded),
          'warmup': (l10n.setTypeWarmup, Icons.local_fire_department_outlined),
          'drop': (l10n.setTypeDrop, Icons.south_rounded),
          'failure': (l10n.setTypeFailure, Icons.bolt_rounded),
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.setTypeTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in types.entries)
                    ChoiceChip(
                      avatar: Icon(e.value.$2, size: 16),
                      label: Text(e.value.$1),
                      selected: type == e.key,
                      onSelected: (_) => setState(() => type = e.key),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text('RPE', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Text(rpe == null ? '—' : rpe!.toStringAsFixed(rpe! % 1 == 0 ? 0 : 1),
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                  const Spacer(),
                  if (rpe != null) TextButton(onPressed: () => setState(() => rpe = null), child: Text(l10n.commonClear)),
                ],
              ),
              Slider(
                value: rpe ?? 8,
                min: 6,
                max: 10,
                divisions: 8,
                label: (rpe ?? 8).toString(),
                onChanged: (v) => setState(() => rpe = v),
              ),
              Text(l10n.rpeHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
              ),
            ],
          ),
        );
      },
    ),
  );
  if (saved == true) {
    await ref.read(workoutRepositoryProvider).updateSetMeta(setId: set.id, setType: type, rpe: rpe);
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final int displayNumber;
  final VoidCallback? onEditMeta;
  final WorkoutSet? previous;
  final Future<void> Function(double weight, int reps, bool completed) onSave;

  const _SetRow({required this.set, required this.displayNumber, required this.previous, required this.onSave, this.onEditMeta});

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weight;
  late final TextEditingController _reps;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(text: widget.set.weightKg > 0 ? _fmtKg(widget.set.weightKg) : '');
    _reps = TextEditingController(text: widget.set.reps > 0 ? '${widget.set.reps}' : '');
  }

  @override
  void didUpdateWidget(covariant _SetRow old) {
    super.didUpdateWidget(old);
    // Keep fields in sync with external changes (not while the user is typing).
    if (_debounce?.isActive != true) {
      final w = widget.set.weightKg > 0 ? _fmtKg(widget.set.weightKg) : '';
      if (_weight.text != w && double.tryParse(_weight.text) != widget.set.weightKg) _weight.text = w;
      final r = widget.set.reps > 0 ? '${widget.set.reps}' : '';
      if (_reps.text != r) _reps.text = r;
    }
  }

  @override
  void dispose() {
    // Flush a pending edit so values typed just before leaving are not lost.
    if (_debounce?.isActive == true) {
      _debounce!.cancel();
      widget.onSave(_w, _r, widget.set.isCompleted);
    }
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  double get _w => double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
  int get _r => int.tryParse(_reps.text) ?? 0;

  /// Persist typed values after a short pause instead of on every keystroke.
  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => widget.onSave(_w, _r, widget.set.isCompleted));
  }

  void _toggle() {
    _debounce?.cancel();
    var w = _w;
    var r = _r;
    // Completing an empty row reuses last time's numbers.
    if (!widget.set.isCompleted && w == 0 && r == 0 && widget.previous != null) {
      w = widget.previous!.weightKg;
      r = widget.previous!.reps;
      _weight.text = _fmtKg(w);
      _reps.text = '$r';
    }
    widget.onSave(w, r, !widget.set.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = widget.set.isCompleted;
    final primary = theme.colorScheme.primary;

    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: done ? primary.withAlpha(context.isDark ? 25 : 18) : context.cardHigh,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: done ? primary.withAlpha(context.isDark ? 18 : 14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Tap / long-press the set number to change its type (warm-up, drop, failure) and RPE
          GestureDetector(
            onTap: widget.onEditMeta,
            onLongPress: widget.onEditMeta,
            child: SizedBox(
              width: 34,
              height: 40,
              child: Center(child: _SetBadge(set: widget.set, number: widget.displayNumber)),
            ),
          ),
          Expanded(
            child: Text(
              widget.previous == null ? '—' : '${_fmtKg(widget.previous!.weightKg)}×${widget.previous!.reps}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                decoration: deco(widget.previous != null ? _fmtKg(widget.previous!.weightKg) : '0'),
                onChanged: (_) => _scheduleSave(),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TextField(
                controller: _reps,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                decoration: deco(widget.previous != null ? '${widget.previous!.reps}' : '0'),
                onChanged: (_) => _scheduleSave(),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: done ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: done ? primary : context.borderColor, width: 2),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: done
                        ? Icon(Icons.check_rounded, key: const ValueKey(1), size: 22, color: theme.colorScheme.onPrimary)
                        : const SizedBox(key: ValueKey(0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Set number, or a letter for special set types (W = warm-up, D = drop, F = failure), plus RPE.
class _SetBadge extends StatelessWidget {
  final WorkoutSet set;
  final int number;

  const _SetBadge({required this.set, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (set.isPersonalRecord) return const Icon(Icons.emoji_events_rounded, color: AppColors.carbs, size: 20);
    final (label, color) = switch (set.setType) {
      'warmup' => ('W', AppColors.carbs),
      'drop' => ('D', AppColors.violet),
      'failure' => ('F', AppColors.error),
      _ => ('$number', theme.colorScheme.onSurface),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: color)),
        if (set.rpe != null)
          Text('@${set.rpe!.toStringAsFixed(set.rpe! % 1 == 0 ? 0 : 1)}',
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: context.textSecondary)),
      ],
    );
  }
}
