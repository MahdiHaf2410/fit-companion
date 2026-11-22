import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import 'achievements.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final list = ref.watch(achievementsProvider).value ?? const <Achievement>[];
    final unlocked = list.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          AppCard(
            gradient: context.heroGradient,
            child: Row(
              children: [
                ProgressRing(
                  progress: list.isEmpty ? 0 : unlocked / list.length,
                  size: 76,
                  strokeWidth: 9,
                  color: AppColors.carbs,
                  child: Text('$unlocked/${list.length}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(l10n.achSubtitle, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
            children: [for (final a in list) _AchievementTile(a: a)],
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement a;
  const _AchievementTile({required this.a});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (title, desc) = achievementText(l10n, a.def.id);
    final color = a.unlocked ? a.def.color : context.textSecondary;

    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(a.def.icon, color: color, size: 40),
          title: Text(title, textAlign: TextAlign.center),
          content: Text(
            '$desc\n\n${a.current.clamp(0, a.def.target).toStringAsFixed(0)} / ${a.def.target.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonClose))],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressRing(
            progress: a.progress,
            size: 56,
            strokeWidth: 5,
            color: color,
            child: Opacity(opacity: a.unlocked ? 1 : 0.45, child: Icon(a.def.icon, color: color, size: 24)),
          ),
          const SizedBox(height: 8),
          Text(title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: a.unlocked ? theme.colorScheme.onSurface : null,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

/// Dashboard entry card + "new badge unlocked" celebration.
class AchievementsSummaryCard extends ConsumerStatefulWidget {
  const AchievementsSummaryCard({super.key});

  @override
  ConsumerState<AchievementsSummaryCard> createState() => _AchievementsSummaryCardState();
}

class _AchievementsSummaryCardState extends ConsumerState<AchievementsSummaryCard> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(achievementsProvider, (_, next) async {
      final list = next.value;
      if (list == null) return;
      final repo = ref.read(achievementsRepositoryProvider);
      final seen = await repo.getSeen();
      final unlocked = list.where((a) => a.unlocked).map((a) => a.def.id).toSet();
      final fresh = unlocked.difference(seen);
      if (fresh.isEmpty) return;
      await repo.markSeen(seen.union(unlocked));
      // Don't celebrate everything on the very first run with existing data.
      if (seen.isEmpty && fresh.length > 1) return;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      HapticFeedback.heavyImpact();
      final (title, _) = achievementText(l10n, fresh.first);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🏅 ${l10n.achUnlocked}: $title')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final list = ref.watch(achievementsProvider).value ?? const <Achievement>[];
    final unlocked = list.where((a) => a.unlocked).toList();
    final next = list.where((a) => !a.unlocked).toList()..sort((a, b) => b.progress.compareTo(a.progress));

    return AppCard(
      onTap: () => context.push('/achievements'),
      child: Row(
        children: [
          const IconBadge(icon: Icons.military_tech_rounded, color: AppColors.carbs, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.achTitle} • ${unlocked.length}/${list.length}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                if (next.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${l10n.achNext}: ${achievementText(l10n, next.first.def.id).$1}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: next.first.progress, minHeight: 5, color: AppColors.carbs),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(context.forwardChevron, color: context.textSecondary),
        ],
      ),
    );
  }
}
