import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';

final weeklyMuscleSetsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchMuscleSets(days: 7);
});

/// Evidence-based weekly working-set range per muscle for hypertrophy.
const kMinWeeklySets = 10;
const kMaxWeeklySets = 20;

Color muscleColor(BuildContext context, int sets) {
  if (sets <= 0) return context.borderColor;
  if (sets < kMinWeeklySets) {
    return Color.lerp(AppColors.cyan.withAlpha(90), AppColors.cyan, sets / kMinWeeklySets)!;
  }
  if (sets <= kMaxWeeklySets) return Theme.of(context).colorScheme.primary;
  return AppColors.flame;
}

String muscleName(AppLocalizations l10n, String g) => switch (g) {
      'chest' => l10n.muscleChest,
      'back' => l10n.muscleBack,
      'legs' => l10n.muscleLegs,
      'shoulders' => l10n.muscleShoulders,
      'arms' => l10n.muscleArms,
      'core' => l10n.muscleCore,
      'cardio' => l10n.muscleCardio,
      _ => g,
    };

/// Front + back body silhouettes coloured by weekly working sets per muscle group.
class MuscleHeatmapCard extends ConsumerWidget {
  const MuscleHeatmapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sets = ref.watch(weeklyMuscleSetsProvider).value ?? const {};
    const groups = ['chest', 'back', 'shoulders', 'arms', 'core', 'legs'];

    Color c(String g) => muscleColor(context, sets[g] ?? 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // The figures are not mirrored in RTL (front/back are anatomical views).
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    _Body(front: true, colors: c, outline: context.borderColor),
                    const SizedBox(width: 6),
                    _Body(front: false, colors: c, outline: context.borderColor),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    for (final g in groups)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: c(g), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(muscleName(l10n, g), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
                            Text('${sets[g] ?? 0}', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                            Text(' / $kMinWeeklySets+', style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(l10n.heatmapHelp, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final bool front;
  final Color Function(String group) colors;
  final Color outline;

  const _Body({required this.front, required this.colors, required this.outline});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(62, 140), painter: _BodyPainter(front: front, colors: colors, outline: outline));
  }
}

class _BodyPainter extends CustomPainter {
  final bool front;
  final Color Function(String group) colors;
  final Color outline;

  _BodyPainter({required this.front, required this.colors, required this.outline});

  @override
  void paint(Canvas canvas, Size size) {
    // Design grid: 100 x 220
    canvas.scale(size.width / 100, size.height / 220);
    Paint p(String g) => Paint()..color = colors(g);
    final base = Paint()..color = outline;
    RRect r(double l, double t, double w, double h, [double rad = 8]) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(l, t, w, h), Radius.circular(rad));

    // Head + neck
    canvas.drawCircle(const Offset(50, 14), 11, base);
    canvas.drawRRect(r(45, 24, 10, 8, 3), base);
    // Shoulders (delts)
    canvas.drawOval(const Rect.fromLTWH(16, 32, 20, 18), p('shoulders'));
    canvas.drawOval(const Rect.fromLTWH(64, 32, 20, 18), p('shoulders'));
    if (front) {
      // Chest
      canvas.drawRRect(r(31, 34, 18, 20, 7), p('chest'));
      canvas.drawRRect(r(51, 34, 18, 20, 7), p('chest'));
      // Abs / core
      for (int i = 0; i < 3; i++) {
        canvas.drawRRect(r(38, 57 + i * 13.0, 11, 11, 3), p('core'));
        canvas.drawRRect(r(51, 57 + i * 13.0, 11, 11, 3), p('core'));
      }
    } else {
      // Upper back / lats
      canvas.drawRRect(r(31, 34, 38, 22, 8), p('back'));
      canvas.drawRRect(r(33, 57, 34, 26, 10), p('back'));
      // Lower back (core)
      canvas.drawRRect(r(39, 84, 22, 12, 4), p('core'));
    }
    // Arms
    canvas.drawRRect(r(14, 51, 13, 30, 7), p('arms'));
    canvas.drawRRect(r(73, 51, 13, 30, 7), p('arms'));
    canvas.drawRRect(r(11, 83, 11, 28, 6), p('arms'));
    canvas.drawRRect(r(78, 83, 11, 28, 6), p('arms'));
    // Hips
    canvas.drawRRect(r(34, 97, 32, 16, 8), front ? base : p('legs'));
    // Legs
    canvas.drawRRect(r(33, 114, 16, 50, 8), p('legs'));
    canvas.drawRRect(r(51, 114, 16, 50, 8), p('legs'));
    canvas.drawRRect(r(35, 167, 13, 42, 7), p('legs'));
    canvas.drawRRect(r(52, 167, 13, 42, 7), p('legs'));
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) => true;
}
