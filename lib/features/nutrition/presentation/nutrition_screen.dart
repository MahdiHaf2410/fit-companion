import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_progress_bar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../hydration/presentation/water_card.dart';
import '../data/meal_tools_repository.dart';
import 'eaten_widgets.dart';
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
    final locale = ref.watch(localeProvider).languageCode;
    final isAr = locale == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionTitle),
        actions: [
          IconButton(
            tooltip: l10n.photoTitle,
            icon: const Icon(Icons.photo_camera_rounded),
            onPressed: () => context.push('/nutrition/photo'),
          ),
          IconButton(
            tooltip: l10n.scanTitle,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/nutrition/scan'),
          ),
          IconButton(
            tooltip: l10n.nutritionCreateRecipe,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/nutrition/recipe/create'),
          ),
          IconButton(
            tooltip: l10n.nutritionLogFood,
            icon: const Icon(Icons.add_circle_rounded),
            color: theme.colorScheme.primary,
            iconSize: 30,
            onPressed: () => context.push('/nutrition/search'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, kNavBarClearance),
        children: [
          // ---------------- Date strip ----------------
          _DateStrip(
            selected: selectedDate,
            locale: locale,
            onSelect: (d) => ref.read(selectedDateProvider.notifier).state = d,
          ),
          const SizedBox(height: 12),

          // ---------------- Summary ----------------
          summaryAsync.when(
            data: (s) {
              final over = s.caloriesRemaining < 0;
              return AppCard(
                gradient: context.heroGradient,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ProgressRing(
                          progress: s.calorieProgress,
                          size: 96,
                          strokeWidth: 11,
                          color: over ? theme.colorScheme.error : theme.colorScheme.primary,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedNumber(
                                value: s.caloriesConsumed,
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Text(l10n.commonKcal, style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.nutritionDailySummary, style: theme.textTheme.titleSmall),
                              const SizedBox(height: 6),
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: '${s.caloriesRemaining.abs().toInt()} ',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: over ? theme.colorScheme.error : null,
                                  ),
                                ),
                                TextSpan(
                                  text: over ? l10n.dashboardKcalOver : l10n.dashboardKcalLeft,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ])),
                              const SizedBox(height: 2),
                              Text('${l10n.dashboardGoal}: ${s.targetCalories} ${l10n.commonKcal}', style: theme.textTheme.bodySmall),
                              if (s.plannedCalories > 0)
                                Text('⏳ ${l10n.eatenPlannedKcal(s.plannedCalories.toInt())}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardProtein,
                            current: s.proteinConsumed,
                            target: s.targetProtein,
                            unit: l10n.commonGrams,
                            color: AppColors.protein,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardCarbs,
                            current: s.carbsConsumed,
                            target: s.targetCarbs,
                            unit: l10n.commonGrams,
                            color: AppColors.carbs,
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MacroProgressBar(
                            label: l10n.dashboardFat,
                            current: s.fatConsumed,
                            target: s.targetFat,
                            unit: l10n.commonGrams,
                            color: AppColors.fat,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const AppCard(child: SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
          ),
          const SizedBox(height: 12),

          // ---------------- Quick tools ----------------
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ToolChip(icon: Icons.photo_camera_rounded, label: l10n.photoTitle, onTap: () => context.push('/nutrition/photo')),
                _ToolChip(icon: Icons.qr_code_scanner_rounded, label: l10n.scanTitle, onTap: () => context.push('/nutrition/scan')),
                _ToolChip(icon: Icons.school_rounded, label: l10n.academyTitle, onTap: () => context.push('/nutrition/academy')),
                _ToolChip(icon: Icons.scale_rounded, label: l10n.foodCalculatorTitle, onTap: () => context.push('/nutrition/food-calculator')),
                _ToolChip(icon: Icons.calculate_rounded, label: l10n.nutritionCalculatorTitle, onTap: () => context.push('/nutrition/calculator')),
                _ToolChip(icon: Icons.add_box_rounded, label: l10n.nutritionAddCustomFood, onTap: () => context.push('/nutrition/custom')),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Water ----------------
          const WaterCard(),
          const SizedBox(height: 4),

          // ---------------- Meals ----------------
          logsAsync.when(
            data: (logs) => Column(
              children: [
                if (logs.isEmpty) const _CopyYesterdayBanner(),
                for (final meal in [
                  ('breakfast', Icons.wb_twilight_rounded, AppColors.carbs),
                  ('lunch', Icons.wb_sunny_rounded, AppColors.lime),
                  ('dinner', Icons.nights_stay_rounded, AppColors.violet),
                  ('snack', Icons.cookie_rounded, AppColors.fat),
                ])
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _MealSection(
                      mealType: meal.$1,
                      title: switch (meal.$1) {
                        'breakfast' => l10n.nutritionMealBreakfast,
                        'lunch' => l10n.nutritionMealLunch,
                        'dinner' => l10n.nutritionMealDinner,
                        _ => l10n.nutritionMealSnacks,
                      },
                      icon: meal.$2,
                      color: meal.$3,
                      logs: logs.where((l) => l.mealType == meal.$1).toList(),
                      isAr: isAr,
                    ),
                  ),
              ],
            ),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
            error: (e, _) => Text('${l10n.commonError}: $e'),
          ),
        ],
      ),
    );
  }
}

/// Week-style date picker: 7 days centred on the selection, plus a calendar button.
class _DateStrip extends StatelessWidget {
  final DateTime selected;
  final String locale;
  final ValueChanged<DateTime> onSelect;

  const _DateStrip({required this.selected, required this.locale, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final today = DateUtils.dateOnly(DateTime.now());
    // Show up to 3 days after the selection but never more than 1 day into the future.
    var end = selected.add(const Duration(days: 3));
    if (end.isAfter(today.add(const Duration(days: 1)))) end = today.add(const Duration(days: 1));
    if (end.isBefore(selected)) end = selected;
    final days = List.generate(7, (i) => end.subtract(Duration(days: 6 - i)));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateUtils.isSameDay(selected, today) ? l10n.commonToday : DateFormat.yMMMMd(locale).format(selected),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (!DateUtils.isSameDay(selected, today))
              TextButton(onPressed: () => onSelect(today), child: Text(l10n.commonToday)),
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selected,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) onSelect(DateUtils.dateOnly(picked));
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final d in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: _DayChip(
                    date: d,
                    locale: locale,
                    selected: DateUtils.isSameDay(d, selected),
                    isToday: DateUtils.isSameDay(d, today),
                    onTap: () => onSelect(d),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final String locale;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayChip({required this.date, required this.locale, required this.selected, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.transparent : (isToday ? theme.colorScheme.primary.withAlpha(140) : context.borderColor)),
        ),
        child: Column(
          children: [
            Text(
              DateFormat.E(locale).format(date),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: theme.textTheme.labelSmall?.copyWith(color: selected ? fg.withAlpha(200) : null, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text('${date.day}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final String mealType;
  final String title;
  final IconData icon;
  final Color color;
  final List<FoodLog> logs;
  final bool isAr;

  const _MealSection({
    required this.mealType,
    required this.title,
    required this.icon,
    required this.color,
    required this.logs,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final c = context.isDark ? color : Color.lerp(color, Colors.black, 0.25)!;
    // Only eaten items count toward the meal totals.
    final mealCals = logs.where((l) => l.isEaten).fold<double>(0, (a, l) => a + l.calories);
    final mealProtein = logs.where((l) => l.isEaten).fold<double>(0, (a, l) => a + l.protein);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: c, size: 38, iconSize: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    if (logs.isNotEmpty)
                      Text('${mealCals.toInt()} ${l10n.commonKcal} • ${mealProtein.toStringAsFixed(0)}${l10n.commonGrams} ${l10n.dashboardProtein}',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.nutritionLogFood,
                style: IconButton.styleFrom(backgroundColor: c.withAlpha(context.isDark ? 40 : 28), foregroundColor: c),
                icon: const Icon(Icons.add_rounded),
                onPressed: () => context.push('/nutrition/search?meal=$mealType'),
              ),
              _MealMenu(mealType: mealType, mealTitle: title, hasLogs: logs.isNotEmpty),
            ],
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 50, top: 2),
              child: Text(l10n.nutritionMealEmpty, style: theme.textTheme.bodySmall),
            )
          else ...[
            const SizedBox(height: 6),
            for (final log in logs)
              Dismissible(
                key: ValueKey(log.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                ),
                // Delete first, then let the row animate out (avoids 'dismissed Dismissible still in tree').
                confirmDismiss: (_) async {
                  await ref.read(nutritionRepositoryProvider).deleteFoodLog(log.id);
                  return true;
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6, end: 6, top: 6, bottom: 6),
                  child: Row(
                    children: [
                      // Did you eat it? (tap → choose the time)
                      EatenCheckButton(
                        eaten: log.isEaten,
                        onMarkEaten: (t) => ref.read(nutritionRepositoryProvider).markEaten(
                              log.id,
                              at: DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day, t.hour, t.minute),
                            ),
                        onMarkPlanned: () => ref.read(nutritionRepositoryProvider).markPlanned(log.id),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Opacity(
                         opacity: log.isEaten ? 1 : 0.6,
                         child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (isAr && (log.foodNameAr?.isNotEmpty ?? false)) ? log.foodNameAr! : log.foodName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text('${log.quantityG.toInt()}${l10n.commonGrams}', style: theme.textTheme.bodySmall),
                                const SizedBox(width: 8),
                                _MacroDot(color: AppColors.protein, value: log.protein),
                                _MacroDot(color: AppColors.carbs, value: log.carbs),
                                _MacroDot(color: AppColors.fat, value: log.fat),
                              ],
                            ),
                            const SizedBox(height: 2),
                            log.isEaten
                                ? Text(
                                    '✓ ${l10n.eatenAtShort} ${formatTime(context, log.eatenAt ?? log.timestamp)}',
                                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.success),
                                  )
                                : Text('⏳ ${l10n.eatenPlannedShort}', style: theme.textTheme.labelSmall),
                          ],
                        ),
                        ),
                      ),
                      Text('${log.calories.toInt()}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text(' ${l10n.commonKcal}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MacroDot extends StatelessWidget {
  final Color color;
  final double value;
  const _MacroDot({required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(value.toStringAsFixed(value < 10 ? 1 : 0), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Shown when the selected day is empty: one tap copies the previous day.
class _CopyYesterdayBanner extends ConsumerWidget {
  const _CopyYesterdayBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedDateProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            IconBadge(icon: Icons.content_copy_rounded, color: Theme.of(context).colorScheme.primary, size: 36, iconSize: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.mealsCopyYesterdayHint, style: Theme.of(context).textTheme.bodyMedium)),
            TextButton(
              onPressed: () async {
                final n = await ref.read(mealToolsRepositoryProvider).copyLogs(
                      fromDate: formatDateKey(selected.subtract(const Duration(days: 1))),
                      toDate: formatDateKey(selected),
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(n == 0 ? l10n.mealsNothingToCopy : l10n.mealsCopied(n))),
                  );
                }
              },
              child: Text(l10n.mealsCopy),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⋮ menu of a meal: copy from yesterday, save as template, use a template.
class _MealMenu extends ConsumerWidget {
  final String mealType;
  final String mealTitle;
  final bool hasLogs;

  const _MealMenu({required this.mealType, required this.mealTitle, required this.hasLogs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedDateProvider);

    void toast(String m) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: context.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) async {
        final repo = ref.read(mealToolsRepositoryProvider);
        switch (v) {
          case 'copy':
            final n = await repo.copyLogs(
              fromDate: formatDateKey(selected.subtract(const Duration(days: 1))),
              toDate: formatDateKey(selected),
              mealType: mealType,
            );
            toast(n == 0 ? l10n.mealsNothingToCopy : l10n.mealsCopied(n));
          case 'save':
            final name = await _askName(context, l10n, mealTitle);
            if (name == null || name.isEmpty) return;
            final ok = await repo.saveMealAsTemplate(date: formatDateKey(selected), mealType: mealType, name: name);
            toast(ok ? l10n.mealsTemplateSaved : l10n.mealsNothingToCopy);
          case 'use':
            if (!context.mounted) return;
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => _TemplatesSheet(mealType: mealType, date: formatDateKey(selected)),
            );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'copy', child: ListTile(leading: const Icon(Icons.history_rounded), title: Text(l10n.mealsCopyFromYesterday))),
        PopupMenuItem(value: 'use', child: ListTile(leading: const Icon(Icons.bookmarks_rounded), title: Text(l10n.mealsUseTemplate))),
        if (hasLogs)
          PopupMenuItem(value: 'save', child: ListTile(leading: const Icon(Icons.bookmark_add_rounded), title: Text(l10n.mealsSaveTemplate))),
      ],
    );
  }

  Future<String?> _askName(BuildContext context, AppLocalizations l10n, String initial) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mealsSaveTemplate),
        content: TextField(controller: c, autofocus: true, decoration: InputDecoration(labelText: l10n.mealsTemplateName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}

class _TemplatesSheet extends ConsumerWidget {
  final String mealType;
  final String date;

  const _TemplatesSheet({required this.mealType, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final templates = ref.watch(mealTemplatesProvider).value ?? const <MealTemplateWithItems>[];
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.mealsTemplates, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (templates.isEmpty)
              Expanded(child: Center(child: Text(l10n.mealsNoTemplates, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium)))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final t = templates[i];
                    return AppCard(
                      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                      onTap: () async {
                        await ref.read(mealToolsRepositoryProvider).applyTemplate(templateId: t.template.id, date: date, mealType: mealType);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.template.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                Text(
                                  '${t.items.length} • ${t.calories.toInt()} ${l10n.commonKcal} • ${t.protein.toInt()}${l10n.commonGrams} ${l10n.dashboardProtein}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () => ref.read(mealToolsRepositoryProvider).deleteTemplate(t.template.id),
                          ),
                        ],
                      ),
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
