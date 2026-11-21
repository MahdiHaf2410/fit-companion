import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _daysController = TextEditingController(text: 'Monday,Wednesday,Friday');

  final List<Map<String, dynamic>> _selectedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickExerciseModal() async {
    final repo = ref.read(workoutRepositoryProvider);
    final exercises = await repo.searchExercisesStream().first;

    if (!mounted) return;

    Exercise? pickedEx;
    int sets = 3;
    int reps = 10;
    int rest = 90;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Select Exercise',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollCtrl,
                          itemCount: exercises.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, i) {
                            final ex = exercises[i];
                            final isSel = pickedEx?.id == ex.id;
                            return ListTile(
                              title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${ex.muscleGroup} • ${ex.equipment}'),
                              trailing: isSel ? const Icon(Icons.check_circle, color: Colors.green) : null,
                              onTap: () {
                                setModalState(() => pickedEx = ex);
                              },
                            );
                          },
                        ),
                      ),
                      if (pickedEx != null) ...[
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: '3',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Sets'),
                                onChanged: (v) => sets = int.tryParse(v) ?? 3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: '10',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Reps'),
                                onChanged: (v) => reps = int.tryParse(v) ?? 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: '90',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Rest (s)'),
                                onChanged: (v) => rest = int.tryParse(v) ?? 90,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.add({
                                    'exerciseId': pickedEx!.id,
                                    'exerciseName': pickedEx!.name,
                                    'targetSets': sets,
                                    'targetReps': reps,
                                    'targetRestSeconds': rest,
                                  });
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final repo = ref.read(workoutRepositoryProvider);
    await repo.createProgram(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      scheduledDays: _daysController.text.trim(),
      exercises: _selectedExercises,
    );

    ref.invalidate(workoutProgramsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program created successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutsCreateProgram),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.workoutsProgramName,
                  prefixIcon: const Icon(Icons.fitness_center_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: l10n.workoutsProgramDesc,
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                  labelText: 'Scheduled Days (e.g. Monday, Wednesday, Friday)',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.workoutsExercises,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.workoutsAddExercise),
                    onPressed: _pickExerciseModal,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_selectedExercises.isEmpty)
                AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('No exercises added yet. Tap "${l10n.workoutsAddExercise}" to pick exercises.'),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final ex = _selectedExercises[i];
                    return AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.primary,
                            radius: 14,
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex['exerciseName'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${ex['targetSets']} sets × ${ex['targetReps']} reps • ${ex['targetRestSeconds']}s rest'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                            onPressed: () {
                              setState(() => _selectedExercises.removeAt(i));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProgram,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
