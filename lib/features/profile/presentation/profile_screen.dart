import 'package:flutter/material.dart';
import '../../../core/widgets/ui_kit.dart' show kNavBarClearance;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palettes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'profile_providers.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileStreamProvider);
    final goalAsync = ref.watch(goalStreamProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    final profile = profileAsync.value;
    final goal = goalAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: SingleChildScrollView(
        // Leave room for the floating bottom navigation bar
        padding: const EdgeInsets.fromLTRB(16, 12, 16, kNavBarClearance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            AppCard(
              gradient: context.heroGradient,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: AppColors.limeGradient, shape: BoxShape.circle),
                    child: Text(
                      (profile?.displayName?.trim().isNotEmpty ?? false)
                          ? profile!.displayName!.trim()[0].toUpperCase()
                          : '💪',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onAccent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (profile?.displayName?.trim().isNotEmpty ?? false) ? profile!.displayName! : l10n.profileAthlete,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${l10n.profileYears(profile?.age ?? 25)} • ${profile?.heightCm.toInt() ?? 175} ${l10n.commonCm} • ${profile?.currentWeightKg.toStringAsFixed(1) ?? '75'} ${l10n.commonKg}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Targets Card
            Text(
              l10n.profileGoals,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(l10n.dashboardCalories, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge)),
                      Text(
                        "${goal?.targetCalories ?? 2000} ${l10n.commonKcal}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroCol(l10n.dashboardProtein, "${goal?.targetProteinGrams.toInt() ?? 150}g", Colors.blue),
                      _macroCol(l10n.dashboardCarbs, "${goal?.targetCarbsGrams.toInt() ?? 200}g", Colors.orange),
                      _macroCol(l10n.dashboardFat, "${goal?.targetFatGrams.toInt() ?? 65}g", Colors.pink),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/onboarding'),
                      child: Text(l10n.profileEditGoals),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preferences Section
            Text(
              l10n.profilePreferences,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Theme Selector
                  ListTile(
                    leading: Icon(Icons.palette_rounded, color: theme.colorScheme.primary),
                    title: Text(l10n.themesTitle),
                    subtitle: Text(
                      '${AppPalettes.byId(ref.watch(appearanceProvider).paletteId).name(currentLocale.languageCode)} • '
                      '${currentTheme == ThemeMode.light ? l10n.profileThemeLight : currentTheme == ThemeMode.dark ? l10n.profileThemeDark : l10n.profileThemeSystem}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/settings/themes'),
                  ),
                  const Divider(height: 1),

                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.profileLanguage),
                    subtitle: Text(
                      currentLocale.languageCode == 'ar' ? l10n.profileLanguageAr : l10n.profileLanguageEn,
                    ),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'ar', label: Text('ع')),
                      ],
                      selected: {currentLocale.languageCode},
                      onSelectionChanged: (v) => ref.read(localeProvider.notifier).setLocale(Locale(v.first)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // v1.1 features hub
            Text(
              l10n.profileFeatures,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in [
                    (Icons.smart_toy_rounded, l10n.coachTitle, '/coach'),
                    (Icons.cloud_sync_rounded, l10n.cloudTitle, '/settings/cloud'),
                    (Icons.notifications_active_rounded, l10n.remTitle, '/settings/reminders'),
                    (Icons.favorite_rounded, l10n.healthTitle, '/settings/health'),
                    (Icons.photo_library_rounded, l10n.photosTitle, '/progress/photos'),
                    (Icons.military_tech_rounded, l10n.achTitle, '/achievements'),
                    (Icons.backup_rounded, l10n.backupTitle, '/settings/backup'),
                  ]) ...[
                    ListTile(
                      leading: Icon(item.$1, color: theme.colorScheme.primary),
                      title: Text(item.$2),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(item.$3),
                    ),
                    if (item.$3 != '/settings/backup') const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data & Privacy Section
            Text(
              l10n.profileData,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.profileExportJson),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/profile/export'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                    title: Text(l10n.profileResetData, style: const TextStyle(color: Colors.red)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.profileResetData),
                          content: Text(l10n.profileResetConfirm),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.commonConfirm),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(profileRepositoryProvider).clearAllData();
                        ref.invalidate(profileStreamProvider);
                        ref.invalidate(goalStreamProvider);
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Card
            AppCard(
              backgroundColor: theme.colorScheme.primaryContainer.withAlpha(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.profileAbout,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.profileAboutText, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    l10n.profileOfflineStatus,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Branding + developer credit
            AppCard(
              gradient: context.heroGradient,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/branding/logo.png', width: 96, height: 96, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Text(l10n.appTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text('v1.6.2', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(l10n.aboutDevelopedBy, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    l10n.aboutDeveloperName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _macroCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
