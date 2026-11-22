import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_progress_bar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../achievements/achievements_screen.dart';
import '../../ai/ai_tools.dart' show AiToolsCard;
import '../../challenges/challenges.dart' show ChallengesHomeCard;
import '../../progress/presentation/progress_photos_screen.dart' show ProgressPhotosHomeCard;
import '../../hydration/presentation/water_card.dart';
import '../../nutrition/domain/daily_nutrition_summary.dart';
import '../../nutrition/presentation/nutrition_providers.dart';
import '../../workouts/presentation/workout_providers.dart';
import '../../progress/presentation/progress_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.greetingMorning;
    if (h < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;

    // The dashboard always shows TODAY, even if the nutrition tab browsed another day.
    final summaryAsync = ref.watch(todayNutritionSummaryProvider);
    final activeSessionAsync = ref.watch(activeWorkoutSessionProvider);
    final latestMetricAsync = ref.watch(latestBodyMetricProvider);
    final statsAsync = ref.watch(trainingStatsProvider);
    final profile = ref.watch(profileStreamProvider).value;
    final userName = profile?.displayName ?? '';
    final stats = statsAsync.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayNutritionSummaryProvider);
            ref.invalidate(activeWorkoutSessionProvider);
            ref.invalidate(latestBodyMetricProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, kNavBarClearance),
            children: [
              // ---------------- Header ----------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.MMMMEEEEd(locale).format(DateTime.now()).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 4),
                        // Smaller greeting so the user's name always fits
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: userName.isNotEmpty ? '${_greeting(l10n)}${locale == 'ar' ? '،' : ','} ' : _greeting(l10n),
                              style: theme.textTheme.titleMedium?.copyWith(color: context.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            if (userName.isNotEmpty)
                              TextSpan(
                                text: userName,
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
                              ),
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _CircleButton(
                    icon: Icons.translate_rounded,
                    tooltip: l10n.profileLanguage,
                    onTap: () => ref.read(localeProvider.notifier).toggleLanguage(),
                  ),
                  const SizedBox(width: 8),
                  _CircleButton(
                    icon: Icons.add_rounded,
                    tooltip: l10n.dashboardActionAddFood,
                    filled: true,
                    onTap: () => context.push('/nutrition/search'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ---------------- Calories hero ----------------
              FadeSlideIn(
                child: summaryAsync.when(
                  data: (s) => _CaloriesHero(summary: s),
                  loading: () => const _LoadingCard(height: 250),
                  error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
                ),
              ),
              const SizedBox(height: 12),

              // ---------------- KPI tiles ----------------
              FadeSlideIn(
                index: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.flame,
                        value: '${stats?.currentStreakDays ?? 0}',
                        label: l10n.statsStreak,
                        onTap: () => context.go('/workouts'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        icon: Icons.fitness_center_rounded,
                        color: AppColors.violet,
                        value: '${stats?.workoutsThisWeek ?? 0}',
                        label: l10n.statsThisWeek,
                        onTap: () => context.go('/workouts'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        icon: Icons.monitor_weight_rounded,
                        color: AppColors.cyan,
                        value: latestMetricAsync.value != null
                            ? latestMetricAsync.value!.weightKg.toStringAsFixed(1)
                            : '—',
                        label: l10n.commonKg,
                        onTap: () => latestMetricAsync.value == null
                            ? context.push('/progress/add')
                            : context.go('/progress'),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- Today's workout ----------------
              SectionHeader(
                title: l10n.dashboardTodayWorkout,
                actionLabel: l10n.commonSeeAll,
                onAction: () => context.go('/workouts'),
              ),
              FadeSlideIn(
                index: 2,
                child: activeSessionAsync.when(
                  data: (active) {
                    if (active != null) {
                      final done = active.sets.where((s) => s.isCompleted).length;
                      final total = active.sets.length;
                      return AppCard(
                        onTap: () => context.push('/workouts/active'),
                        gradient: AppColors.violetGradient,
                        border: Border.all(color: Colors.transparent),
                        child: Row(
                          children: [
                            ProgressRing(
                              progress: total == 0 ? 0 : done / total,
                              size: 64,
                              strokeWidth: 7,
                              color: AppColors.onSecondary,
                              trackColor: AppColors.onSecondary.withValues(alpha: 0.25),
                              child: Text('$done/$total',
                                  style: TextStyle(color: AppColors.onSecondary, fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Pill(label: l10n.dashboardInProgress, color: AppColors.onSecondary, icon: Icons.bolt_rounded),
                                  const SizedBox(height: 6),
                                  Text(
                                    active.session.programName ?? l10n.workoutsActiveSession,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppColors.onSecondary, fontWeight: FontWeight.w800, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.play_circle_fill_rounded, color: AppColors.onSecondary, size: 40),
                          ],
                        ),
                      );
                    }
                    return AppCard(
                      onTap: () => context.go('/workouts'),
                      child: Row(
                        children: [
                          IconBadge(
                            icon: Icons.fitness_center_rounded,
                            color: AppColors.violet,
                            gradient: AppColors.limeGradient,
                            size: 52,
                            iconSize: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.dashboardStartWorkout, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(l10n.dashboardNoWorkoutToday, style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Icon(
                            context.forwardChevron,
                            color: context.textSecondary,
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const _LoadingCard(height: 90),
                  error: (e, _) => AppCard(child: Text('${l10n.commonError}: $e')),
                ),
              ),
              const SizedBox(height: 12),

              // ---------------- Weekly activity ----------------
              FadeSlideIn(
                index: 3,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(l10n.dashboardWeekActivity, style: theme.textTheme.titleSmall)),
                          if ((stats?.volumeThisWeekKg ?? 0) > 0)
                            Pill(
                              label: '${NumberFormat.compact(locale: locale).format(stats!.volumeThisWeekKg)} ${l10n.commonKg}',
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      WeekStrip(
                        days: stats?.last7Days ?? List.filled(7, false),
                        labels: last7DayLabels(locale),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const FadeSlideIn(index: 4, child: AiToolsCard()),
              const SizedBox(height: 12),
              const FadeSlideIn(index: 4, child: ChallengesHomeCard()),
              const SizedBox(height: 12),
              const FadeSlideIn(index: 4, child: ProgressPhotosHomeCard()),
              const SizedBox(height: 12),
              const FadeSlideIn(index: 4, child: AchievementsSummaryCard()),
              const SizedBox(height: 12),

              // ---------------- Water ----------------
              const FadeSlideIn(index: 4, child: WaterCard(today: true)),

              // ---------------- Tools ----------------
              SectionHeader(title: l10n.dashboardTools),
              FadeSlideIn(
                index: 5,
                child: AppCard(
                  onTap: () => context.push('/coach'),
                  gradient: AppColors.violetGradient,
                  border: Border.all(color: Colors.transparent),
                  child: Row(
                    children: [
                      Icon(Icons.smart_toy_rounded, color: AppColors.onSecondary, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.coachTitle, style: TextStyle(color: AppColors.onSecondary, fontWeight: FontWeight.w800, fontSize: 16)),
                            Text(l10n.coachTagline, style: TextStyle(color: AppColors.onSecondary.withValues(alpha: 0.75), fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(context.forwardChevron, color: AppColors.onSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                index: 5,
                child: AppCard(
                  onTap: () => context.push('/nutrition/academy'),
                  gradient: context.heroGradient,
                  child: Row(
                    children: [
                      IconBadge(icon: Icons.school_rounded, color: AppColors.violet, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(l10n.dashboardAcademyCard, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                Pill(label: l10n.academyLessonsCount(14), color: AppColors.violet),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.dashboardAcademyDesc, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                index: 6,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: [
                    _ToolTile(
                      icon: Icons.calculate_rounded,
                      color: AppColors.lime,
                      title: l10n.nutritionCalculatorTitle,
                      subtitle: l10n.calculatorBmrTdee,
                      onTap: () => context.push('/nutrition/calculator'),
                    ),
                    _ToolTile(
                      icon: Icons.scale_rounded,
                      color: AppColors.carbs,
                      title: l10n.foodCalculatorTitle,
                      subtitle: l10n.portionScaler,
                      onTap: () => context.push('/nutrition/food-calculator'),
                    ),
                    _ToolTile(
                      icon: Icons.construction_rounded,
                      color: AppColors.cyan,
                      title: l10n.toolsTitle,
                      subtitle: '1RM • ${l10n.toolsPlates}',
                      onTap: () => context.push('/tools'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big calories ring + macro bars.
class _CaloriesHero extends StatelessWidget {
  final DailyNutritionSummary summary;

  const _CaloriesHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final over = summary.caloriesRemaining < 0;
    final ringColor = over ? theme.colorScheme.error : theme.colorScheme.primary;

    return AppCard(
      onTap: () => context.go('/nutrition'),
      gradient: context.heroGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                progress: summary.calorieProgress,
                size: 138,
                strokeWidth: 14,
                color: ringColor,
                gradient: over ? null : (context.isDark ? AppColors.limeGradient : null),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedNumber(
                      value: summary.caloriesRemaining.abs(),
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: over ? ringColor : null),
                    ),
                    Text(over ? l10n.dashboardKcalOver : l10n.dashboardKcalLeft, style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroStat(
                      icon: Icons.restaurant_rounded,
                      label: l10n.dashboardConsumed,
                      value: '${summary.caloriesConsumed.toInt()}',
                      unit: l10n.commonKcal,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            icon: Icons.flag_rounded,
                            label: l10n.dashboardGoal,
                            value: '${summary.targetCalories}',
                            unit: l10n.commonKcal,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.profileEditGoals,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.tune_rounded, size: 20, color: context.textSecondary),
                          onPressed: () => context.push('/nutrition/calculator'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _HeroStat({required this.icon, required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: context.textSecondary),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: theme.textTheme.labelMedium, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(TextSpan(children: [
            TextSpan(text: value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            TextSpan(text: ' $unit', style: theme.textTheme.bodySmall),
          ])),
        ),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.isDark ? color : Color.lerp(color, Colors.black, 0.25)!;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: c, size: 36, iconSize: 19),
          const Spacer(),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge?.copyWith(fontSize: 12.5, height: 1.2)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  const _CircleButton({required this.icon, required this.tooltip, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? theme.colorScheme.primary : theme.colorScheme.surface,
        shape: CircleBorder(side: BorderSide(color: filled ? Colors.transparent : context.borderColor)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: filled ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        height: height - 32,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      ),
    );
  }
}
