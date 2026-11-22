import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_palettes.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/animated_background.dart';
import '../shared/providers/settings_provider.dart';
import 'router.dart';
import '../l10n/app_localizations.dart';

class FitCompanionApp extends ConsumerWidget {
  const FitCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final look = ref.watch(appearanceProvider);

    final palette = AppPalettes.byId(look.paletteId);
    // Brand colours used by widgets through AppColors follow the chosen theme.
    AppColors.active = palette;
    final effect = resolveEffect(palette, look.effect);
    final animated = look.animated && effect != BackgroundEffect.none;

    return MaterialApp.router(
      title: 'Fit Companion',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.build(Brightness.light, palette, animatedBackground: animated),
      darkTheme: AppTheme.build(Brightness.dark, palette, animatedBackground: animated),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 450),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => BackgroundHost(
        enabled: animated,
        effect: effect,
        interactive: look.interactive,
        intensity: look.intensity,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
