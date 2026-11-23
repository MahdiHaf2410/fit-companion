import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'muscle_heatmap.dart' show muscleName;

const kMuscleGroups = ['chest', 'back', 'shoulders', 'arms', 'legs', 'core', 'cardio'];
const kEquipments = ['barbell', 'dumbbell', 'machine', 'cable', 'bodyweight', 'kettlebell', 'band', 'other'];

String equipmentName(AppLocalizations l10n, String e) => switch (e) {
      'barbell' => l10n.equipBarbell,
      'dumbbell' => l10n.equipDumbbell,
      'machine' => l10n.equipMachine,
      'cable' => l10n.equipCable,
      'bodyweight' => l10n.equipBodyweight,
      'kettlebell' => l10n.equipKettlebell,
      'band' => l10n.equipBand,
      _ => l10n.equipOther,
    };

String exerciseDisplayName(Exercise e, String locale) =>
    locale == 'ar' && (e.nameAr?.isNotEmpty ?? false) ? e.nameAr! : e.name;

/// Opens the searchable exercise picker. Returns the chosen (or newly created) exercise.
Future<Exercise?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ExercisePickerSheet(),
  );
}

class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({super.key});

  @override
  ConsumerState<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  String _query = '';
  String _group = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final repo = ref.watch(workoutRepositoryProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: l10n.workoutsSearchExercise, prefixIcon: const Icon(Icons.search_rounded)),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final g in ['all', ...kMuscleGroups])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: ChoiceChip(
                        label: Text(g == 'all' ? l10n.nutritionCategoryAll : muscleName(l10n, g)),
                        selected: _group == g,
                        onSelected: (_) => setState(() => _group = g),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Always visible: create an exercise that is missing from the library
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconBadge(icon: Icons.add_rounded, color: theme.colorScheme.primary, size: 38, iconSize: 20),
              title: Text(l10n.exerciseCreateCustom, style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
              subtitle: Text(l10n.exerciseCreateCustomHint),
              onTap: () async {
                final created = await showCreateExerciseSheet(context, ref, initialName: _query);
                if (created != null && context.mounted) Navigator.pop(context, created);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Exercise>>(
                stream: repo.searchExercisesStream(query: _query, muscleGroup: _group),
                builder: (context, snap) {
                  final list = snap.data ?? const <Exercise>[];
                  if (snap.hasData && list.isEmpty) {
                    return Center(child: Text(l10n.exerciseNotFound, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final e = list[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: IconBadge(icon: Icons.fitness_center_rounded, color: theme.colorScheme.primary, size: 38, iconSize: 18),
                        title: Text(exerciseDisplayName(e, locale), style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${muscleName(l10n, e.muscleGroup)} • ${equipmentName(l10n, e.equipment)}${e.isCustom ? ' • ★' : ''}'),
                        onTap: () => Navigator.pop(context, e),
                      );
                    },
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

/// Form to add a custom exercise. Returns the created exercise.
Future<Exercise?> showCreateExerciseSheet(BuildContext context, WidgetRef ref, {String initialName = ''}) {
  final l10n = AppLocalizations.of(context)!;
  final name = TextEditingController(text: initialName);
  final notes = TextEditingController();
  String group = 'chest';
  String equipment = 'dumbbell';
  String type = 'compound';

  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exerciseCreateCustom, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: name, autofocus: true, decoration: InputDecoration(labelText: l10n.exerciseName)),
              const SizedBox(height: 12),
              Text(l10n.workoutsMuscleGroup, style: Theme.of(ctx).textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final g in kMuscleGroups)
                    ChoiceChip(label: Text(muscleName(l10n, g)), selected: group == g, onSelected: (_) => setState(() => group = g)),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.workoutsEquipment, style: Theme.of(ctx).textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in kEquipments)
                    ChoiceChip(label: Text(equipmentName(l10n, e)), selected: equipment == e, onSelected: (_) => setState(() => equipment = e)),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: 'compound', label: Text(l10n.exerciseCompound)),
                  ButtonSegment(value: 'isolation', label: Text(l10n.exerciseIsolation)),
                ],
                selected: {type},
                onSelectionChanged: (v) => setState(() => type = v.first),
              ),
              const SizedBox(height: 12),
              TextField(controller: notes, maxLines: 2, decoration: InputDecoration(labelText: l10n.exerciseNotesOptional)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (name.text.trim().isEmpty) return;
                    final ex = await ref.read(workoutRepositoryProvider).createCustomExercise(
                          name: name.text.trim(),
                          muscleGroup: group,
                          equipment: equipment,
                          exerciseType: type,
                          instructions: notes.text.trim().isEmpty ? null : notes.text.trim(),
                        );
                    if (ctx.mounted) Navigator.pop(ctx, ex);
                  },
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
