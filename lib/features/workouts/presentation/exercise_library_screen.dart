import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/settings_provider.dart';
import 'workout_providers.dart';
import '../../../l10n/app_localizations.dart';

class ExerciseLibraryScreen extends ConsumerWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(exerciseSearchResultsProvider);
    final selectedMuscle = ref.watch(exerciseMuscleGroupFilterProvider);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    final muscleGroups = [
      {'id': 'all', 'label': isAr ? 'الكل' : 'All'},
      {'id': 'chest', 'label': isAr ? 'الصدر' : 'Chest'},
      {'id': 'back', 'label': isAr ? 'الظهر' : 'Back'},
      {'id': 'legs', 'label': isAr ? 'الأرجل' : 'Legs'},
      {'id': 'shoulders', 'label': isAr ? 'الأكتاف' : 'Shoulders'},
      {'id': 'arms', 'label': isAr ? 'الذراعين' : 'Arms'},
      {'id': 'core', 'label': isAr ? 'البطن والوسط' : 'Core'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutsExerciseLibrary),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: isAr ? 'ابحث عن تمرين...' : 'Search exercises...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ref.watch(exerciseSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          ref.read(exerciseSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(exerciseSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Muscle group filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: muscleGroups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final m = muscleGroups[i];
                final isSel = selectedMuscle == m['id'];
                return ChoiceChip(
                  label: Text(m['label']!),
                  selected: isSel,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(exerciseMuscleGroupFilterProvider.notifier).state = m['id']!;
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: resultsAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Text(isAr ? 'لم يتم العثور على تمارين' : 'No exercises found'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final ex = exercises[i];
                    final displayName = (isAr && ex.nameAr != null && ex.nameAr!.isNotEmpty)
                        ? ex.nameAr!
                        : ex.name;
                    final instructions = (isAr && ex.instructionsAr != null && ex.instructionsAr!.isNotEmpty)
                        ? ex.instructionsAr!
                        : (ex.instructions ?? '');

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ex.muscleGroup.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${l10n.workoutsEquipment}: ${ex.equipment} • ${ex.exerciseType}",
                            style: theme.textTheme.bodySmall,
                          ),
                          if (instructions.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              instructions,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
