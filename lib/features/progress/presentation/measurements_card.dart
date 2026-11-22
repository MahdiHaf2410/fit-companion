import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

/// Latest body measurements with the change since the first entry in range.
class MeasurementsCard extends StatelessWidget {
  final List<BodyMetric> metrics; // oldest -> newest

  const MeasurementsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final fields = <(String, String, double? Function(BodyMetric))>[
      (l10n.progressWaist, l10n.commonCm, (m) => m.waistCm),
      (l10n.measureChest, l10n.commonCm, (m) => m.chestCm),
      (l10n.measureArm, l10n.commonCm, (m) => m.armCm),
      (l10n.measureThigh, l10n.commonCm, (m) => m.thighCm),
      (l10n.measureHips, l10n.commonCm, (m) => m.hipsCm),
      (l10n.measureBodyFat, '%', (m) => m.bodyFatPercent),
    ];

    final rows = <Widget>[];
    for (final f in fields) {
      final values = metrics.map(f.$3).whereType<double>().toList();
      if (values.isEmpty) continue;
      final latest = values.last;
      final delta = latest - values.first;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(f.$1, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            Text('${latest.toStringAsFixed(1)} ${f.$2}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            SizedBox(
              width: 58,
              child: Text(
                values.length < 2 ? '—' : '‎${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: values.length < 2 || delta.abs() < 0.05 ? null : (delta < 0 ? AppColors.cyan : AppColors.flame),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Column(children: rows));
  }
}
