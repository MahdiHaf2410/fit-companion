import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/health_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';

final _healthStateProvider = FutureProvider.autoDispose<(HealthAvailability, bool)>((ref) async {
  final s = ref.watch(healthServiceProvider);
  final a = await s.availability();
  final access = a == HealthAvailability.available && await s.hasAccess();
  return (a, access);
});

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(_healthStateProvider);
    final steps = ref.watch(healthStepsTodayProvider).value;
    final service = ref.read(healthServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.healthSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          state.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (s) {
              final (availability, access) = s;
              if (availability == HealthAvailability.unavailable) {
                return AppCard(child: Text(l10n.healthUnavailable, style: theme.textTheme.bodyMedium));
              }
              if (availability == HealthAvailability.needsInstall) {
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.healthNeedsInstall, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: service.install, child: Text(l10n.healthInstall)),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  AppCard(
                    gradient: context.heroGradient,
                    child: Row(
                      children: [
                        IconBadge(icon: access ? Icons.check_circle_rounded : Icons.link_rounded, color: access ? AppColors.success : AppColors.violet, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(access ? l10n.healthConnected : l10n.healthNotConnected,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                              Text(l10n.healthWhat, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!access)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_rounded),
                        label: Text(l10n.healthConnect),
                        onPressed: () async {
                          await service.requestAccess();
                          ref.invalidate(_healthStateProvider);
                          ref.invalidate(healthStepsTodayProvider);
                        },
                      ),
                    )
                  else
                    StatTile(
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.lime,
                      value: steps == null ? '—' : '$steps',
                      label: l10n.healthStepsToday,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
