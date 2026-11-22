import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_colors.dart';
import 'package:fit_companion/core/theme/app_palettes.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/core/widgets/animated_background.dart';
import 'package:fit_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fit_companion/features/settings/themes_screen.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('there are many themes with unique ids', () {
    expect(AppPalettes.all.length, greaterThanOrEqualTo(18));
    expect(AppPalettes.all.map((p) => p.id).toSet().length, AppPalettes.all.length);
    expect(AppPalettes.all.map((p) => p.shape).toSet().length, 4);
    expect(AppPalettes.all.map((p) => p.effect).toSet().length, greaterThanOrEqualTo(7));
  });

  for (final p in AppPalettes.all) {
    test('${p.id}: text and buttons are readable (WCAG)', () {
      for (final b in Brightness.values) {
        final dark = b == Brightness.dark;
        final bg = dark ? p.bgDark : p.bgLight;
        final card = dark ? p.cardDark : p.cardLight;
        final text = dark ? p.textDark : p.textLight;
        final sub = dark ? p.textSecondaryDark : p.textSecondaryLight;
        expect(contrast(text, bg), greaterThan(7), reason: 'body text on background ($b)');
        expect(contrast(text, card), greaterThan(7), reason: 'body text on card ($b)');
        expect(contrast(sub, card), greaterThan(3.5), reason: 'secondary text on card ($b)');
        expect(contrast(p.onPrimary(b), p.primary(b)), greaterThan(4.5), reason: 'button label ($b)');
        expect(contrast(p.primary(b), card), greaterThan(dark ? 3 : 2.5), reason: 'accent visible on card ($b)');
      }
      expect(contrast(p.onColor(p.secondary), p.secondary), greaterThan(4.5), reason: 'text on secondary gradient');
    });
  }

  testWidgets('every theme renders the dashboard + theme picker with the animated background', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final p in AppPalettes.all) {
      for (final b in Brightness.values) {
        SharedPreferences.setMockInitialValues({'ui_palette': p.id});
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db.seedInitialData();
        AppColors.active = p;
        await tester.pumpWidget(ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.build(b, p, animatedBackground: true),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => BackgroundHost(
              enabled: true,
              effect: p.effect,
              interactive: true,
              intensity: 0.8,
              child: child!,
            ),
            home: const PageBackground(child: DashboardScreen()),
          ),
        ));
        for (int i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 120));
        }
        // Touch reacts without blocking the UI
        await tester.tapAt(const Offset(4, 736)); // empty area (no navigation)
        await tester.pump(const Duration(milliseconds: 120));
        expect(tester.takeException(), isNull, reason: '${p.id} $b dashboard');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
        await db.close();
      }
    }
    AppColors.active = AppPalettes.neon;
  });

  for (final lang in ['en', 'ar']) {
    testWidgets('theme picker renders and switches theme ($lang)', (tester) async {
      SharedPreferences.setMockInitialValues({'user_locale': lang});
      final prefs = await SharedPreferences.getInstance();
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      late ProviderContainer container;
      await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return MaterialApp(
            theme: AppTheme.darkTheme,
            locale: Locale(lang),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const ThemesScreen(),
          );
        }),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      // Tap the "Ocean Pulse" theme tile
      await tester.tap(find.text(lang == 'ar' ? 'نبض المحيط' : 'Ocean Pulse'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(appearanceProvider).paletteId, isNot('neon'));
      expect(prefs.getString('ui_palette'), isNot('neon'));
      // Scroll down to the effects
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
