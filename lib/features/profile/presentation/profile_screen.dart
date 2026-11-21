import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person_rounded, size: 32, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'Athlete',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${profile?.age ?? 25} yrs • ${profile?.heightCm.toInt() ?? 175} cm • ${profile?.currentWeightKg.toStringAsFixed(1) ?? '75'} kg",
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
                      Text(l10n.dashboardCalories, style: theme.textTheme.bodyLarge),
                      Text(
                        "${goal?.targetCalories ?? 2000} kcal",
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
              'App Preferences',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Theme Selector
                  ListTile(
                    leading: const Icon(Icons.brightness_6_rounded),
                    title: Text(l10n.profileAppearance),
                    subtitle: Text(
                      currentTheme == ThemeMode.light
                          ? l10n.profileThemeLight
                          : currentTheme == ThemeMode.dark
                              ? l10n.profileThemeDark
                              : l10n.profileThemeSystem,
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: currentTheme,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.profileThemeSystem)),
                        DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.profileThemeLight)),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.profileThemeDark)),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(mode);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.profileLanguage),
                    subtitle: Text(
                      currentLocale.languageCode == 'ar' ? l10n.profileLanguageAr : l10n.profileLanguageEn,
                    ),
                    trailing: DropdownButton<String>(
                      value: currentLocale.languageCode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: 'en', child: Text(l10n.profileLanguageEn)),
                        DropdownMenuItem(value: 'ar', child: Text(l10n.profileLanguageAr)),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(lang));
                        }
                      },
                    ),
                  ),
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
                      Text(
                        l10n.profileAbout,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
