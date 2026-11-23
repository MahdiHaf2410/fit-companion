import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';

const _configKey = 'reminders_config';

final reminderConfigProvider = StreamProvider<ReminderConfig>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.appPreferences)..where((p) => p.key.equals(_configKey)))
      .watchSingleOrNull()
      .map((row) => ReminderConfig.decode(row?.value));
});

/// Re-schedules the saved reminders once each time the app opens, so fixes to the
/// scheduling (and restores/backups) take effect without visiting the Reminders screen.
class ReminderSync extends ConsumerStatefulWidget {
  final Widget child;
  const ReminderSync({super.key, required this.child});

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_done) return;
    _done = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;
      final texts = reminderTexts(l10n);
      try {
        final c = await ref.read(reminderConfigProvider.future);
        if (c.water || c.meals || c.workout || c.weighIn) {
          await ref.read(notificationServiceProvider).applyReminders(c, texts);
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

ReminderTexts reminderTexts(AppLocalizations l10n) => ReminderTexts(
      waterTitle: l10n.remWaterTitle,
      waterBody: l10n.remWaterBody,
      mealTitle: l10n.remMealTitle,
      breakfast: l10n.nutritionMealBreakfast,
      lunch: l10n.nutritionMealLunch,
      dinner: l10n.nutritionMealDinner,
      workoutTitle: l10n.remWorkoutTitle,
      workoutBody: l10n.remWorkoutBody,
      weighTitle: l10n.remWeighTitle,
      weighBody: l10n.remWeighBody,
    );

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref, ReminderConfig c) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final service = ref.read(notificationServiceProvider);
    final anyOn = c.water || c.meals || c.workout || c.weighIn;
    if (anyOn) {
      final granted = await service.requestPermission();
      if (!granted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.remPermissionDenied)));
      }
    }
    await db.into(db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion(key: const Value(_configKey), value: Value(c.encode())),
        );
    await service.applyReminders(c, reminderTexts(l10n));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = ref.watch(reminderConfigProvider).value ?? const ReminderConfig();
    final locale = Localizations.localeOf(context).languageCode;
    final days = locale == 'ar'
        ? const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    Future<int?> pickHour(int current) async {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: current, minute: 0));
      return t?.hour;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.remSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          _ReminderCard(
            icon: Icons.water_drop_rounded,
            color: AppColors.water,
            title: l10n.remWaterTitle,
            enabled: c.water,
            onToggle: (v) => _save(context, ref, c.copyWith(water: v)),
            children: [
              _Row(
                label: l10n.remEvery,
                child: DropdownButton<int>(
                  value: c.waterEveryHours,
                  underline: const SizedBox(),
                  items: [1, 2, 3].map((h) => DropdownMenuItem(value: h, child: Text(l10n.remHours(h)))).toList(),
                  onChanged: (v) => _save(context, ref, c.copyWith(waterEveryHours: v)),
                ),
              ),
              _Row(
                label: l10n.remFromTo,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TimeChip(hour: c.waterStartHour, onTap: () async {
                      final h = await pickHour(c.waterStartHour);
                      if (h != null && context.mounted) _save(context, ref, c.copyWith(waterStartHour: h));
                    }),
                    const Text('  –  '),
                    _TimeChip(hour: c.waterEndHour, onTap: () async {
                      final h = await pickHour(c.waterEndHour);
                      if (h != null && context.mounted) _save(context, ref, c.copyWith(waterEndHour: h));
                    }),
                  ],
                ),
              ),
            ],
          ),
          _ReminderCard(
            icon: Icons.restaurant_rounded,
            color: AppColors.carbs,
            title: l10n.remMealTitle,
            enabled: c.meals,
            onToggle: (v) => _save(context, ref, c.copyWith(meals: v)),
            children: [
              for (final m in [
                (l10n.nutritionMealBreakfast, c.breakfastHour, (int h) => c.copyWith(breakfastHour: h)),
                (l10n.nutritionMealLunch, c.lunchHour, (int h) => c.copyWith(lunchHour: h)),
                (l10n.nutritionMealDinner, c.dinnerHour, (int h) => c.copyWith(dinnerHour: h)),
              ])
                _Row(
                  label: m.$1,
                  child: _TimeChip(hour: m.$2, onTap: () async {
                    final h = await pickHour(m.$2);
                    if (h != null && context.mounted) _save(context, ref, m.$3(h));
                  }),
                ),
            ],
          ),
          _ReminderCard(
            icon: Icons.fitness_center_rounded,
            color: AppColors.violet,
            title: l10n.remWorkoutTitle,
            enabled: c.workout,
            onToggle: (v) => _save(context, ref, c.copyWith(workout: v)),
            children: [
              Wrap(
                spacing: 6,
                children: [
                  for (int d = 1; d <= 7; d++)
                    FilterChip(
                      label: Text(days[d - 1]),
                      selected: c.workoutWeekdays.contains(d),
                      showCheckmark: false,
                      onSelected: (on) {
                        final list = [...c.workoutWeekdays];
                        on ? list.add(d) : list.remove(d);
                        list.sort();
                        _save(context, ref, c.copyWith(workoutWeekdays: list));
                      },
                    ),
                ],
              ),
              _Row(
                label: l10n.remTime,
                child: _TimeChip(hour: c.workoutHour, minute: c.workoutMinute, onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: c.workoutHour, minute: c.workoutMinute));
                  if (t != null && context.mounted) _save(context, ref, c.copyWith(workoutHour: t.hour, workoutMinute: t.minute));
                }),
              ),
            ],
          ),
          _ReminderCard(
            icon: Icons.monitor_weight_rounded,
            color: AppColors.cyan,
            title: l10n.remWeighTitle,
            enabled: c.weighIn,
            onToggle: (v) => _save(context, ref, c.copyWith(weighIn: v)),
            children: [
              _Row(
                label: l10n.remTime,
                child: _TimeChip(hour: c.weighInHour, onTap: () async {
                  final h = await pickHour(c.weighInHour);
                  if (h != null && context.mounted) _save(context, ref, c.copyWith(weighInHour: h));
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.remTestHint, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: Text(l10n.remTestButton),
                  onPressed: () async {
                    final service = ref.read(notificationServiceProvider);
                    final granted = await service.requestPermission();
                    if (!context.mounted) return;
                    if (!granted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.remPermissionDenied)));
                      return;
                    }
                    await service.showTest(title: l10n.remTestTitle, body: l10n.remTestBody);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconBadge(icon: Icons.watch_rounded, color: AppColors.lime, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.remWatchInfo, style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _ReminderCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.enabled,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                IconBadge(icon: icon, color: color, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: enabled
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(start: 52, top: 6),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;
  const _Row({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          // Scale down on narrow phones instead of overflowing
          Flexible(
            flex: 2,
            child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerEnd, child: child),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final int hour;
  final int minute;
  final VoidCallback onTap;
  const _TimeChip({required this.hour, this.minute = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
      onPressed: onTap,
    );
  }
}
