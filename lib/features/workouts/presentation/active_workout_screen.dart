import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestTimerRunning = false;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isRestTimerRunning = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 1) {
        setState(() => _restSecondsRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _restSecondsRemaining = 0;
          _isRestTimerRunning = false;
        });
      }
    });
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = 0;
      _isRestTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final repo = ref.watch(workoutRepositoryProvider);

    return activeSessionAsync.when(
      data: (active) {
        if (active == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.workoutsActiveSession)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No active workout session.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/workouts'),
                    child: Text(l10n.commonBack),
                  ),
                ],
              ),
            ),
          );
        }

        // Group sets by exercise
        final exerciseGroups = <String, List<WorkoutSet>>{};
        for (final s in active.sets) {
          exerciseGroups.putIfAbsent(s.exerciseId, () => []).add(s);
        }

        final completedCount = active.sets.where((s) => s.isCompleted).length;

        return Scaffold(
          appBar: AppBar(
            title: Text(active.session.programName ?? l10n.workoutsActiveSession),
            actions: [
              IconButton(
                tooltip: l10n.workoutsDiscardWorkout,
                icon: const Icon(Icons.close_rounded, color: Colors.red),
                onPressed: () async {
                  final discard = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.workoutsDiscardWorkout),
                      content: Text(l10n.workoutsConfirmDiscard),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.workoutsDiscardWorkout),
                        ),
                      ],
                    ),
                  );

                  if (discard == true) {
                    await repo.discardWorkoutSession(active.session.id);
                    ref.invalidate(activeWorkoutSessionProvider);
                    if (context.mounted) context.go('/workouts');
                  }
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.workoutsFinishWorkout),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.workoutsFinishWorkout),
                      content: Text(l10n.workoutsConfirmFinish),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.commonConfirm),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await repo.finishWorkoutSession(sessionId: active.session.id);
                    ref.invalidate(activeWorkoutSessionProvider);
                    ref.invalidate(workoutHistoryProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.dashboardWorkoutCompleted)),
                      );
                      context.go('/workouts');
                    }
                  }
                },
              ),
            ),
          ),
          body: Column(
            children: [
              // Rest Timer Banner (if active)
              if (_isRestTimerRunning)
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.workoutsRestTimeRemaining(_restSecondsRemaining),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _cancelRestTimer,
                        child: Text(
                          l10n.commonClose,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // Progress bar of completed sets
              LinearProgressIndicator(
                value: active.sets.isNotEmpty ? completedCount / active.sets.length : 0.0,
                backgroundColor: theme.colorScheme.outline.withAlpha(30),
              ),

              // List of Exercise Groups & Sets
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exerciseGroups.length,
                  itemBuilder: (context, i) {
                    final exerciseId = exerciseGroups.keys.elementAt(i);
                    final sets = exerciseGroups[exerciseId]!;
                    final exerciseName = sets.first.exerciseName;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    exerciseName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.timer_outlined, size: 20),
                                  tooltip: l10n.workoutsRestTimer,
                                  onPressed: () => _startRestTimer(90),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Sets Header Row
                            Row(
                              children: [
                                SizedBox(width: 36, child: Text(l10n.workoutsSetHeader, style: theme.textTheme.bodySmall)),
                                Expanded(child: Text(l10n.workoutsWeightHeader, textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
                                Expanded(child: Text(l10n.workoutsRepsHeader, textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
                                SizedBox(width: 48, child: Text(l10n.workoutsCompletedHeader, textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Sets Rows
                            ...sets.map((s) => _SetRow(
                              set: s,
                              onUpdate: (weight, reps, completed) async {
                                await repo.updateSet(
                                  setId: s.id,
                                  weightKg: weight,
                                  reps: reps,
                                  isCompleted: completed,
                                );
                                if (completed) {
                                  _startRestTimer(90);
                                }
                              },
                            )),

                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(l10n.workoutsAddSet),
                                onPressed: () async {
                                  final lastWeight = sets.isNotEmpty ? sets.last.weightKg : 0.0;
                                  final lastReps = sets.isNotEmpty ? sets.last.reps : 10;
                                  await repo.addSetToSession(
                                    sessionId: active.session.id,
                                    exerciseId: exerciseId,
                                    exerciseName: exerciseName,
                                    setNumber: sets.length + 1,
                                    weightKg: lastWeight,
                                    reps: lastReps,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final Function(double weight, int reps, bool completed) onUpdate;

  const _SetRow({
    required this.set,
    required this.onUpdate,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg > 0 ? widget.set.weightKg.toStringAsFixed(widget.set.weightKg % 1 == 0 ? 0 : 1) : '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '10',
    );
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set.isCompleted != widget.set.isCompleted) {
      // sync if updated from external
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: widget.set.isCompleted
            ? theme.colorScheme.primary.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: widget.set.isCompleted ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              child: Text(
                '${widget.set.setNumber}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.set.isCompleted ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (v) {
                  final w = double.tryParse(v) ?? 0.0;
                  final r = int.tryParse(_repsController.text) ?? widget.set.reps;
                  widget.onUpdate(w, r, widget.set.isCompleted);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (v) {
                  final w = double.tryParse(_weightController.text) ?? widget.set.weightKg;
                  final r = int.tryParse(v) ?? 0;
                  widget.onUpdate(w, r, widget.set.isCompleted);
                },
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: Icon(
                widget.set.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: widget.set.isCompleted ? theme.colorScheme.primary : Colors.grey,
              ),
              onPressed: () {
                final w = double.tryParse(_weightController.text) ?? widget.set.weightKg;
                final r = int.tryParse(_repsController.text) ?? widget.set.reps;
                widget.onUpdate(w, r, !widget.set.isCompleted);
              },
            ),
          ),
        ],
      ),
    );
  }
}
