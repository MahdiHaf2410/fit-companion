import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_progress_bar.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../nutrition/presentation/nutrition_providers.dart';
import '../../workouts/presentation/workout_providers.dart';
import '../../progress/presentation/progress_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final summaryAsync = ref.watch(dailyNutritionSummaryProvider);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final latestMetricAsync = ref.watch(latestBodyMetricProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    final profile = profileAsync.value;
    final userName = profile?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName.isNotEmpty ? '${l10n.dashboardTitle}, $userName' : l10n.dashboardTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateTime.now().toLocal().toString().split(' ')[0],
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.profileLanguage,
            icon: const Icon(Icons.language_rounded),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLanguage();
            },
          ),
          IconButton(
            tooltip: l10n.dashboardActionAddFood,
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/nutrition/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyNutritionSummaryProvider);
          ref.invalidate(activeWorkoutSessionProvider);
          ref.invalidate(latestBodyMetricProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.fastfood_rounded,
                      label: l10n.dashboardActionAddFood,
                      onTap: () => context.push('/nutrition/search'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.fitness_center_rounded,
                      label: l10n.dashboardActionStartWorkout,
                      onTap: () => context.push('/workouts/programs'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.monitor_weight_rounded,
                      label: l10n.dashboardActionLogWeight,
                      onTap: () => context.push('/progress/add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Daily Nutrition Card
              Text(
                l10n.dashboardNutritionCard,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              summaryAsync.when(
                data: (summary) => AppCard(
                  onTap: () => context.go('/nutrition'),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dashboardConsumed,
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                "${summary.caloriesConsumed.toInt()} ${l10n.commonKcal}",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    l10n.dashboardEstimatedTarget(summary.targetCalories),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _showTargetExplanationDialog(context, l10n),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: summary.caloriesRemaining >= 0
                                  ? theme.colorScheme.primary.withAlpha(25)
                                  : theme.colorScheme.error.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  summary.caloriesRemaining >= 0
                                      ? l10n.dashboardRemaining
                                      : l10n.dashboardOverLimit,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: summary.caloriesRemaining >= 0
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                                Text(
                                  "${summary.caloriesRemaining.abs().toInt()} ${l10n.commonKcal}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: summary.caloriesRemaining >= 0
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Linear Overall Calorie progress
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
                      const SizedBox(height: 20),
                      // Macronutrient Breakdown
                      MacroProgressBar(
                        label: l10n.dashboardProtein,
                        current: summary.proteinConsumed,
                        target: summary.targetProtein,
                        unit: l10n.commonGrams,
                        color: AppColors.protein,
                      ),
                      const SizedBox(height: 10),
                      MacroProgressBar(
                        label: l10n.dashboardCarbs,
                        current: summary.carbsConsumed,
                        target: summary.targetCarbs,
                        unit: l10n.commonGrams,
                        color: AppColors.carbs,
                      ),
                      const SizedBox(height: 10),
                      MacroProgressBar(
                        label: l10n.dashboardFat,
                        current: summary.fatConsumed,
                        target: summary.targetFat,
                        unit: l10n.commonGrams,
                        color: AppColors.fat,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => context.push('/nutrition/calculator'),
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(l10n.profileEditGoals),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const AppCard(
                  child: Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                ),
                error: (e, _) => AppCard(
                  child: Text('${l10n.commonError}: $e'),
                ),
              ),
              const SizedBox(height: 16),

              // Nutrition Academy & Calculators Section
              AppCard(
                onTap: () => context.push('/nutrition/academy'),
                backgroundColor: theme.colorScheme.primary.withAlpha(20),
                border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.dashboardAcademyCard,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '14 Lessons',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.dashboardAcademyDesc,
                            style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      onTap: () => context.push('/nutrition/calculator'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.calculate_rounded, color: theme.colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.nutritionCalculatorTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'BMR & TDEE',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppCard(
                      onTap: () => context.push('/nutrition/food-calculator'),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.scale_rounded, color: theme.colorScheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.foodCalculatorTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Portion Scaler',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Workout Card (Planned or In-Progress or Finished)
              Text(
                l10n.dashboardTodayWorkout,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              activeSessionAsync.when(
                data: (active) {
                  if (active != null) {
                    // Active session in progress!
                    return AppCard(
                      backgroundColor: theme.colorScheme.primary.withAlpha(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  active.session.programName ?? 'Workout',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${active.sets.where((s) => s.isCompleted).length} / ${active.sets.length} ${l10n.commonSets}",
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.dashboardResumeWorkout),
                              onPressed: () => context.push('/workouts/active'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // No active session
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dashboardNoWorkoutToday,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.fitness_center_rounded),
                            label: Text(l10n.dashboardStartWorkout),
                            onPressed: () => context.push('/workouts/programs'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
              ),
              const SizedBox(height: 20),

              // 4. Body Progress Card
              Text(
                l10n.dashboardBodyProgress,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              latestMetricAsync.when(
                data: (metric) {
                  if (metric == null) {
                    return AppCard(
                      onTap: () => context.push('/progress/add'),
                      child: Row(
                        children: [
                          Icon(Icons.monitor_weight_outlined, color: theme.colorScheme.primary, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.dashboardNoWeightYet, style: theme.textTheme.bodyMedium),
                                Text(l10n.dashboardActionLogWeight, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    );
                  }

                  return AppCard(
                    onTap: () => context.go('/progress'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.monitor_weight_rounded, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashboardLatestWeight(metric.weightKg.toStringAsFixed(1)),
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  metric.date,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  );
                },
                loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showTargetExplanationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.green),
            const SizedBox(width: 8),
            Text(l10n.nutritionCalculatorHow),
          ],
        ),
        content: Text(
          l10n.onboardingDisclaimer,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonClose),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/nutrition/calculator');
            },
            child: Text(l10n.profileEditGoals),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
