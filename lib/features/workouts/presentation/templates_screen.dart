import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import 'workout_providers.dart';

/// Ready-made programs. Opening one shows its exercises and a button to copy it
/// into "my programs", where it can be edited freely.
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final templates = ref.watch(workoutTemplatesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.templatesSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final t in templates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => context.push('/workouts/program/${t.id}'),
                child: Row(
                  children: [
                    IconBadge(icon: Icons.auto_awesome_rounded, color: AppColors.violet, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          if (t.description?.isNotEmpty ?? false)
                            Text(t.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(context.forwardChevron, color: context.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
