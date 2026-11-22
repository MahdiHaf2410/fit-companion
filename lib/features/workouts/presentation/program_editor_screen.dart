import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'exercise_picker.dart';
import 'muscle_heatmap.dart' show muscleName;

class _Item {
  final Exercise exercise;
  int sets;
  int reps;
  int rest;
  String? notes;
  final Key key = UniqueKey();

  _Item(this.exercise, {this.sets = 3, this.reps = 10, this.rest = 90, this.notes});
}

/// Create or edit one of the user's own programs (e.g. "Upper A", "Lower B", "Arms & Abs").
class ProgramEditorScreen extends ConsumerStatefulWidget {
  final String? programId;

  const ProgramEditorScreen({super.key, this.programId});

  @override
  ConsumerState<ProgramEditorScreen> createState() => _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _items = <_Item>[];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.programId != null) {
      final d = await ref.read(workoutRepositoryProvider).watchProgramDetails(widget.programId!).first;
      if (d != null) {
        _name.text = d.program.name;
        _desc.text = d.program.description ?? '';
        for (final pe in d.exercises) {
          _items.add(_Item(
            pe.exercise,
            sets: pe.programExercise.targetSets,
            reps: pe.programExercise.targetReps,
            rest: pe.programExercise.targetRestSeconds,
            notes: pe.programExercise.notes,
          ));
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final ex = await showExercisePicker(context);
    if (ex == null) return;
    HapticFeedback.selectionClick();
    final isolation = ex.exerciseType == 'isolation';
    setState(() => _items.add(_Item(ex, sets: 3, reps: isolation ? 12 : 8, rest: isolation ? 60 : 120)));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.programNameRequired)));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.programNeedsExercise)));
      return;
    }
    setState(() => _saving = true);
    final id = await ref.read(workoutRepositoryProvider).saveProgram(
          id: widget.programId,
          name: _name.text.trim(),
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          exercises: [
            for (final i in _items)
              {
                'exerciseId': i.exercise.id,
                'targetSets': i.sets,
                'targetReps': i.reps,
                'targetRestSeconds': i.rest,
                'notes': i.notes,
              },
          ],
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.programSaved)));
    if (widget.programId == null) {
      context.pushReplacement('/workouts/program/$id');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final totalSets = _items.fold<int>(0, (a, i) => a + i.sets);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.programId == null ? l10n.workoutsCreateProgram : l10n.programEdit),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: Text(l10n.commonSave)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.workoutsAddExercise),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(labelText: l10n.workoutsProgramName, hintText: l10n.programNameHint),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _desc,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.workoutsProgramDesc),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Pill(label: l10n.workoutsExercisesCount(_items.length), color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Pill(label: '$totalSets ${l10n.commonSets}', color: AppColors.violet),
                      const SizedBox(width: 8),
                      if (_items.length > 1)
                        Expanded(
                          child: Text(l10n.programReorderHint,
                              textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_items.isEmpty)
                    AppCard(
                      onTap: _add,
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        children: [
                          Icon(Icons.playlist_add_rounded, size: 40, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(l10n.programEmptyHint, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                ],
              ),
              // onReorderItem already adjusts newIndex for the removed item.
              onReorderItem: (oldIndex, newIndex) {
                setState(() => _items.insert(newIndex, _items.removeAt(oldIndex)));
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  Padding(
                    key: _items[i].key,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: theme.colorScheme.primary.withAlpha(40),
                                child: Text('${i + 1}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exerciseDisplayName(_items[i].exercise, locale),
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                    Text(muscleName(l10n, _items[i].exercise.muscleGroup), style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.commonDelete,
                                icon: const Icon(Icons.close_rounded, color: AppColors.error),
                                onPressed: () => setState(() => _items.removeAt(i)),
                              ),
                              ReorderableDragStartListener(
                                index: i,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(Icons.drag_indicator_rounded, color: context.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _Stepper(label: l10n.commonSets, value: _items[i].sets, min: 1, max: 12, onChanged: (v) => setState(() => _items[i].sets = v))),
                              Expanded(child: _Stepper(label: l10n.commonReps, value: _items[i].reps, min: 1, max: 100, onChanged: (v) => setState(() => _items[i].reps = v))),
                              Expanded(
                                child: _Stepper(
                                  label: l10n.workoutsRest,
                                  value: _items[i].rest,
                                  min: 15,
                                  max: 600,
                                  step: 15,
                                  suffix: 's',
                                  onChanged: (v) => setState(() => _items[i].rest = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget btn(IconData icon, int delta) => InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            final next = (value + delta).clamp(min, max);
            if (next != value) {
              HapticFeedback.selectionClick();
              onChanged(next);
            }
          },
          child: Padding(padding: const EdgeInsets.all(5), child: Icon(icon, size: 18, color: theme.colorScheme.primary)),
        );
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            btn(Icons.remove_rounded, -step),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$value$suffix', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ),
            ),
            btn(Icons.add_rounded, step),
          ],
        ),
      ],
    );
  }
}
