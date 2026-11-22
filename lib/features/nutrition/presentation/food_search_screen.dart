import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

final _myFoodsProvider = StreamProvider.autoDispose<List<Food>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  return ref.watch(nutritionRepositoryProvider).searchFoodsStream(query: query, mine: true);
});

final _suggestedFoodsProvider = StreamProvider.autoDispose<List<Food>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  final category = ref.watch(foodCategoryFilterProvider);
  return ref.watch(nutritionRepositoryProvider).searchFoodsStream(query: query, category: category, mine: false);
});

/// Pick a food to log. "My foods" (created by the user) is the main tab;
/// the built-in database lives in "Suggestions".
class FoodSearchScreen extends ConsumerWidget {
  final String? initialMealType;

  const FoodSearchScreen({super.key, this.initialMealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final meal = initialMealType != null ? '?meal=$initialMealType' : '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.nutritionLogFood),
          actions: [
            IconButton(
              tooltip: l10n.photoTitle,
              icon: const Icon(Icons.photo_camera_rounded),
              onPressed: () => context.push('/nutrition/photo$meal'),
            ),
            IconButton(
              tooltip: l10n.scanTitle,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () => context.push('/nutrition/scan$meal'),
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(118),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: l10n.nutritionSearchPlaceholder, prefixIcon: const Icon(Icons.search_rounded)),
                    onChanged: (v) => ref.read(foodSearchQueryProvider.notifier).state = v.trim(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TabBar(tabs: [Tab(height: 36, text: l10n.foodsMine), Tab(height: 36, text: l10n.foodsSuggestions)]),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/nutrition/custom$meal'),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.foodsAddMine),
        ),
        body: TabBarView(
          children: [
            _MyFoodsTab(mealType: initialMealType),
            _SuggestionsTab(mealType: initialMealType),
          ],
        ),
      ),
    );
  }
}

class _MyFoodsTab extends ConsumerWidget {
  final String? mealType;
  const _MyFoodsTab({this.mealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final foods = ref.watch(_myFoodsProvider);
    return foods.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
            children: [
              IconBadge(icon: Icons.restaurant_menu_rounded, color: AppColors.lime, gradient: AppColors.limeGradient, size: 72, iconSize: 34),
              const SizedBox(height: 16),
              Text(l10n.foodsMineEmptyTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l10n.foodsMineEmptyBody, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(l10n.foodsAddMine),
                onPressed: () => context.push('/nutrition/custom${mealType != null ? '?meal=$mealType' : ''}'),
              ),
            ],
          );
        }
        return _FoodList(foods: list, mealType: mealType, mine: true);
      },
    );
  }
}

class _SuggestionsTab extends ConsumerWidget {
  final String? mealType;
  const _SuggestionsTab({this.mealType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(foodCategoryFilterProvider);
    final foods = ref.watch(_suggestedFoodsProvider);
    final categories = [
      ('all', l10n.nutritionCategoryAll),
      ('algerian', l10n.nutritionCategoryAlgerian),
      ('staples', l10n.nutritionCategoryStaples),
      ('protein', l10n.nutritionCategoryProtein),
      ('dairy', l10n.nutritionCategoryDairy),
      ('produce', l10n.nutritionCategoryProduce),
      ('snacks', l10n.nutritionCategorySnacks),
    ];
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    label: Text(c.$2),
                    selected: selected == c.$1,
                    onSelected: (_) => ref.read(foodCategoryFilterProvider.notifier).state = c.$1,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: foods.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(l10n.nutritionNoLogs))
                : _FoodList(foods: list, mealType: mealType, mine: false),
          ),
        ),
      ],
    );
  }
}

class _FoodList extends ConsumerWidget {
  final List<Food> foods;
  final String? mealType;
  final bool mine;

  const _FoodList({required this.foods, required this.mealType, required this.mine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final food = foods[i];
        final name = isAr && (food.nameAr?.isNotEmpty ?? false) ? food.nameAr! : food.name;
        final card = AppCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          onTap: () => context.push('/nutrition/add?foodId=${food.id}&meal=${mealType ?? 'lunch'}'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (food.category == 'algerian') ...[
                          Pill(label: l10n.nutritionCategoryAlgerian, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(name, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    if (food.description?.isNotEmpty ?? false)
                      Text(food.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(
                      '${food.caloriesPer100g.toInt()} ${l10n.commonKcal}/100${l10n.commonGrams} • '
                      'P ${food.proteinPer100g.toStringAsFixed(1)} • C ${food.carbsPer100g.toStringAsFixed(1)} • F ${food.fatPer100g.toStringAsFixed(1)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(food.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: food.isFavorite ? AppColors.carbs : context.textSecondary),
                onPressed: () => ref.read(nutritionRepositoryProvider).toggleFavorite(food.id, food.isFavorite),
              ),
            ],
          ),
        );
        if (!mine) return card;
        // Own foods can be swiped away
        return Dismissible(
          key: ValueKey(food.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
          confirmDismiss: (_) async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.foodsDeleteConfirm),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                  ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
                ],
              ),
            );
            if (ok == true) await ref.read(nutritionRepositoryProvider).deleteCustomFood(food.id);
            return ok == true;
          },
          child: card,
        );
      },
    );
  }
}
