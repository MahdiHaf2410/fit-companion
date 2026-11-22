import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../nutrition/presentation/nutrition_providers.dart';
import 'water_providers.dart';

/// Interactive hydration tracker: ring + 8 glass indicators + quick add buttons.
/// When [today] is true it always tracks today; otherwise the nutrition tab's date.
class WaterCard extends ConsumerWidget {
  final bool today;

  const WaterCard({super.key, this.today = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final water = ref.watch(today ? todayWaterProvider : dailyWaterProvider).value ?? 0;
    final goal = ref.watch(waterGoalProvider).value ?? 2500;
    final progress = goal == 0 ? 0.0 : water / goal;
    final reached = water >= goal;
    final glasses = (goal / 250).ceil().clamp(4, 16);
    final filled = (water / 250).floor();

    Future<void> add(int ml) async {
      HapticFeedback.lightImpact();
      final date = today ? formatDateKey(DateTime.now()) : ref.read(selectedDateFormattedProvider);
      final wasReached = water >= goal;
      await ref.read(waterRepositoryProvider).addWater(date, ml);
      if (!wasReached && water + ml >= goal && context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.waterGoalReached)));
      }
    }

    return AppCard(
      onLongPress: () => _editGoal(context, ref, goal, l10n),
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 76,
            strokeWidth: 9,
            color: AppColors.water,
            gradient: AppColors.waterGradient,
            child: Icon(
              reached ? Icons.check_rounded : Icons.water_drop_rounded,
              color: AppColors.water,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l10n.waterTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                    InkWell(
                      onTap: () => _editGoal(context, ref, goal, l10n),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.edit_rounded, size: 16, color: context.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(l10n.waterProgress(water, goal), style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 3,
                  runSpacing: 3,
                  children: List.generate(glasses, (i) {
                    final on = i < filled;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + i * 30),
                      width: 10,
                      height: 16,
                      decoration: BoxDecoration(
                        color: on ? AppColors.water : AppColors.water.withAlpha(35),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4), top: Radius.circular(2)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _WaterButton(icon: Icons.add_rounded, label: '250', filled: true, onTap: () => add(250)),
              const SizedBox(height: 6),
              _WaterButton(
                icon: Icons.remove_rounded,
                label: '',
                tooltip: l10n.waterUndo,
                onTap: water > 0 ? () => add(-250) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref, int current, AppLocalizations l10n) async {
    int value = current;
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.waterSetGoal, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('$value ${l10n.commonMl}',
                  style: Theme.of(ctx).textTheme.displaySmall?.copyWith(color: AppColors.water)),
              Slider(
                value: value.toDouble(),
                min: 1000,
                max: 5000,
                divisions: 16,
                activeColor: AppColors.water,
                onChanged: (v) => setState(() => value = v.round()),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, value),
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) await ref.read(waterRepositoryProvider).setGoal(result);
  }
}

class _WaterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final bool filled;
  final VoidCallback? onTap;

  const _WaterButton({required this.icon, required this.label, this.tooltip, this.filled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: filled ? AppColors.water : AppColors.water.withAlpha(context.isDark ? 30 : 22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: filled ? 40 : 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? const Color(0xFF0B0E13) : AppColors.water),
              if (label.isNotEmpty)
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: filled ? const Color(0xFF0B0E13) : AppColors.water,
                    )),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
