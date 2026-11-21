import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_progress_bar.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider);
    final logsAsync = ref.watch(dailyLogsProvider);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final dateDisplay = isToday
        ? (isAr ? 'اليوم' : 'Today')
        : DateFormat.yMMMd(currentLocale.languageCode).format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionTitle),
        actions: [
          IconButton(
            tooltip: l10n.academyTitle,
            icon: const Icon(Icons.school_rounded),
            onPressed: () => context.push('/nutrition/academy'),
          ),
          IconButton(
            tooltip: l10n.foodCalculatorTitle,
            icon: const Icon(Icons.scale_rounded),
            onPressed: () => context.push('/nutrition/food-calculator'),
          ),
          IconButton(
            tooltip: l10n.nutritionCreateRecipe,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/nutrition/recipe/create'),
          ),
          IconButton(
            tooltip: l10n.nutritionLogFood,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/nutrition/search'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Date Switcher Row
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      ref.read(selectedDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 1));
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(
                      dateDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        ref.read(selectedDateProvider.notifier).state = picked;
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      ref.read(selectedDateProvider.notifier).state =
                          selectedDate.add(const Duration(days: 1));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quick Tools Bar: Academy, Food Scaler, Calculator, Recipe
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.school_rounded, size: 16),
                    label: Text(l10n.academyTitle),
                    onPressed: () => context.push('/nutrition/academy'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.scale_rounded, size: 16),
                    label: Text(l10n.foodCalculatorTitle),
                    onPressed: () => context.push('/nutrition/food-calculator'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.calculate_rounded, size: 16),
                    label: Text(l10n.nutritionCalculatorTitle),
                    onPressed: () => context.push('/nutrition/calculator'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.menu_book_rounded, size: 16),
                    label: Text(l10n.nutritionCreateRecipe),
                    onPressed: () => context.push('/nutrition/recipe/create'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Daily Summary Card
            summaryAsync.when(
              data: (summary) => AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.nutritionDailySummary,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${summary.caloriesConsumed.toInt()} / ${summary.targetCalories} ${l10n.commonKcal}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: summary.calorieProgress,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.outline.withAlpha(30),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          summary.caloriesRemaining >= 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardProtein,
                            current: summary.proteinConsumed,
                            target: summary.targetProtein,
                            unit: l10n.commonGrams,
                            color: AppColors.protein,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardCarbs,
                            current: summary.carbsConsumed,
                            target: summary.targetCarbs,
                            unit: l10n.commonGrams,
                            color: AppColors.carbs,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardFat,
                            current: summary.fatConsumed,
                            target: summary.targetFat,
                            unit: l10n.commonGrams,
                            color: AppColors.fat,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const AppCard(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))),
              error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
            ),
            const SizedBox(height: 16),

            // Meals Sections: Breakfast, Lunch, Dinner, Snacks
            logsAsync.when(
              data: (logs) {
                return Column(
                  children: [
                    _MealSection(
                      mealType: 'breakfast',
                      title: l10n.nutritionMealBreakfast,
                      icon: Icons.wb_twilight_rounded,
                      logs: logs.where((l) => l.mealType == 'breakfast').toList(),
                      isAr: isAr,
                    ),
                    const SizedBox(height: 12),
                    _MealSection(
                      mealType: 'lunch',
                      title: l10n.nutritionMealLunch,
                      icon: Icons.wb_sunny_rounded,
                      logs: logs.where((l) => l.mealType == 'lunch').toList(),
                      isAr: isAr,
                    ),
                    const SizedBox(height: 12),
                    _MealSection(
                      mealType: 'dinner',
                      title: l10n.nutritionMealDinner,
                      icon: Icons.nights_stay_rounded,
                      logs: logs.where((l) => l.mealType == 'dinner').toList(),
                      isAr: isAr,
                    ),
                    const SizedBox(height: 12),
                    _MealSection(
                      mealType: 'snack',
                      title: l10n.nutritionMealSnacks,
                      icon: Icons.cookie_rounded,
                      logs: logs.where((l) => l.mealType == 'snack').toList(),
                      isAr: isAr,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
              error: (e, _) => Text('${l10n.commonError}: $e'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final String mealType;
  final String title;
  final IconData icon;
  final List<FoodLog> logs;
  final bool isAr;

  const _MealSection({
    required this.mealType,
    required this.title,
    required this.icon,
    required this.logs,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    double mealCals = 0;
    for (final l in logs) {
      mealCals += l.calories;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "${mealCals.toInt()} ${l10n.commonKcal}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  context.push('/nutrition/search?meal=$mealType');
                },
              ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const Divider(height: 18),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                final displayName = (isAr && log.foodNameAr != null && log.foodNameAr!.isNotEmpty)
                    ? log.foodNameAr!
                    : log.foodName;

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            "${log.quantityG.toInt()}${l10n.commonGrams} • P: ${log.protein.toStringAsFixed(1)}g • C: ${log.carbs.toStringAsFixed(1)}g • F: ${log.fat.toStringAsFixed(1)}g",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${log.calories.toInt()} ${l10n.commonKcal}",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                      onPressed: () async {
                        await ref.read(nutritionRepositoryProvider).deleteFoodLog(log.id);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
