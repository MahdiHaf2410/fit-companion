import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class FoodSearchScreen extends ConsumerWidget {
  final String? initialMealType;

  const FoodSearchScreen({super.key, this.initialMealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(foodSearchResultsProvider);
    final selectedCategory = ref.watch(foodCategoryFilterProvider);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    final categories = [
      {'id': 'all', 'label': l10n.nutritionCategoryAll},
      {'id': 'algerian', 'label': l10n.nutritionCategoryAlgerian},
      {'id': 'staples', 'label': l10n.nutritionCategoryStaples},
      {'id': 'protein', 'label': l10n.nutritionCategoryProtein},
      {'id': 'dairy', 'label': l10n.nutritionCategoryDairy},
      {'id': 'produce', 'label': l10n.nutritionCategoryProduce},
      {'id': 'snacks', 'label': l10n.nutritionCategorySnacks},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionLogFood),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.nutritionCustom),
            onPressed: () => context.push('/nutrition/custom'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.nutritionSearchPlaceholder,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ref.watch(foodSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          ref.read(foodSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(foodSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Categories Horizontal Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat['id'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(foodCategoryFilterProvider.notifier).state = cat['id']!;
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Search Results
          Expanded(
            child: resultsAsync.when(
              data: (foods) {
                if (foods.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: l10n.commonSearch,
                    description: isAr
                        ? 'لم يتم العثور على أطعمة مطابقة. يمكنك إضافة طعام مخصص.'
                        : 'No matching foods found. You can add a custom food.',
                    actionLabel: l10n.nutritionAddCustomFood,
                    onAction: () => context.push('/nutrition/custom'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: foods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    final displayName = (isAr && food.nameAr != null && food.nameAr!.isNotEmpty)
                        ? food.nameAr!
                        : food.name;

                    return AppCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        context.push(
                          '/nutrition/add?foodId=${food.id}&meal=${initialMealType ?? 'lunch'}',
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (food.category == 'algerian') ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isAr ? 'جزائري' : 'Algerian',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${food.caloriesPer100g.toInt()} kcal / 100g • ${food.servingDescription}",
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "P: ${food.proteinPer100g}g • C: ${food.carbsPer100g}g • F: ${food.fatPer100g}g",
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              food.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: food.isFavorite ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () {
                              ref.read(nutritionRepositoryProvider).toggleFavorite(food.id, food.isFavorite);
                            },
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
