// Dev-only: renders the dashboard in several themes to PNG files for a visual check.
// Run: flutter test test/screenshots/theme_shots_test.dart --dart-define=SHOTS_DIR=<folder>
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/database/demo_data.dart';
import 'package:fit_companion/core/theme/app_colors.dart';
import 'package:fit_companion/core/theme/app_palettes.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/core/widgets/animated_background.dart';
import 'package:fit_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

const shotsDir = String.fromEnvironment('SHOTS_DIR');

Future<void> _loadFonts() async {
  final dir = '${Platform.environment['FLUTTER_ROOT'] ?? r'C:\src\flutter'}/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf', 'roboto-black.ttf']) {
    final file = File('$dir/$f');
    if (file.existsSync()) roboto.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(File('$dir/materialicons-regular.otf').readAsBytesSync().buffer)));
  await icons.load();
}

void main() {
  testWidgets('theme screenshots', (tester) async {
    if (shotsDir.isEmpty) return;
    await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final ids = ['neon', 'ocean', 'crimson', 'royal', 'cyber', 'gold', 'sakura', 'aurora', 'algeria', 'mono'];
    for (int i = 0; i < ids.length; i++) {
      final p = AppPalettes.byId(ids[i]);
      final b = i == 6 || i == 9 ? Brightness.light : Brightness.dark;
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await tester.runAsync(() async {
        await db.seedInitialData();
        await db.ensureSeedV3();
        await DemoData.seedIfEmpty(db);
      });
      AppColors.active = p;
      final key = GlobalKey();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(b, p, animatedBackground: true).copyWith(),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            builder: (context, child) => BackgroundHost(enabled: true, effect: p.effect, interactive: true, intensity: 0.8, child: child!),
            home: const PageBackground(child: DashboardScreen()),
          ),
        ),
      ));
      for (int k = 0; k < 30; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.0);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$shotsDir/${i}_${p.id}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(db.close);
    }
  });
}
