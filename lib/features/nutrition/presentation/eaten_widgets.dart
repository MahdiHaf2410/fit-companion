import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

String formatTime(BuildContext context, DateTime t) =>
    MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(t), alwaysUse24HourFormat: true);

/// "Did you eat it?" switch + time, used when logging a food.
class EatenToggleCard extends StatelessWidget {
  final bool eaten;
  final TimeOfDay time;
  final ValueChanged<bool> onEatenChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const EatenToggleCard({
    super.key,
    required this.eaten,
    required this.time,
    required this.onEatenChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(eaten ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: eaten ? AppColors.success : context.textSecondary),
            title: Text(l10n.eatenQuestion, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(eaten ? l10n.eatenYes : l10n.eatenPlanned, style: theme.textTheme.bodySmall),
            value: eaten,
            onChanged: onEatenChanged,
          ),
          if (eaten)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_rounded),
              title: Text(l10n.eatenAtTime),
              trailing: ActionChip(
                label: Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w800)),
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: time);
                  if (t != null) onTimeChanged(t);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Round check button in the meal list. Tapping a planned item asks when it was
/// eaten (default: now); tapping an eaten item turns it back to planned.
class EatenCheckButton extends StatelessWidget {
  final bool eaten;
  final Future<void> Function(TimeOfDay time) onMarkEaten;
  final Future<void> Function() onMarkPlanned;

  const EatenCheckButton({super.key, required this.eaten, required this.onMarkEaten, required this.onMarkPlanned});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: eaten ? l10n.eatenUndo : l10n.eatenMark,
      child: InkResponse(
        radius: 22,
        onTap: () async {
          HapticFeedback.selectionClick();
          if (eaten) {
            await onMarkPlanned();
            return;
          }
          final now = TimeOfDay.now();
          final picked = await showTimePicker(context: context, initialTime: now, helpText: l10n.eatenWhen);
          if (picked == null) return;
          await onMarkEaten(picked);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: eaten ? color : Colors.transparent,
            border: Border.all(color: eaten ? color : context.borderColor, width: 2),
          ),
          child: eaten ? Icon(Icons.check_rounded, size: 18, color: Theme.of(context).colorScheme.onPrimary) : null,
        ),
      ),
    );
  }
}
