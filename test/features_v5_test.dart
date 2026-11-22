import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/coach/coach_screen.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';
import 'package:fit_companion/features/nutrition/data/open_food_facts.dart';
import 'package:fit_companion/features/nutrition/presentation/food_photo_screen.dart';
import 'package:fit_companion/features/progress/presentation/progress_photos_screen.dart';
import 'package:fit_companion/features/profile/presentation/profile_screen.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

void main() {
  test('Open Food Facts: product without nutrition is still returned (AI fills it)', () {
    final p = OffProduct.fromResponse('6130000000001', {
      'status': 1,
      'product': {'product_name': 'Cherbet citron', 'brands': 'Ifri', 'nutriments': {}},
    })!;
    expect(p.name, 'Cherbet citron (Ifri)');
    expect(p.complete, isFalse);
    // kcal + one macro → other macros default to 0 (e.g. sodas)
    final soda = OffProduct.fromResponse('2', {
      'status': 1,
      'product': {'product_name': 'Soda', 'nutriments': {'energy-kcal_100g': 42, 'carbohydrates_100g': 10.6}},
    })!;
    expect(soda.complete, isTrue);
    expect(soda.protein, 0);
  });

  test('AI-detected entries are logged and counted', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = NutritionRepository(db);
    final ts = DateTime(2026, 11, 22, 13);
    await repo.logCustomEntry(name: 'Chicken couscous', grams: 350, calories: 560, protein: 38, carbs: 70, fat: 14, mealType: 'lunch', timestamp: ts);
    await repo.logCustomEntry(name: 'Salad', grams: 120, calories: 60, protein: 2, carbs: 8, fat: 2, mealType: 'lunch', timestamp: ts, isEaten: false);
    final s = await repo.watchDailySummary('2026-11-22').first;
    expect(s.caloriesConsumed, 560);
    expect(s.plannedCalories, 60);
    final logs = await repo.getDailyLogs('2026-11-22');
    expect(logs.first.foodId, isNull);
    await db.close();
  });

  for (final lang in ['en', 'ar']) {
    final screens = <String, Widget>{
      'food photo': const FoodPhotoScreen(mealType: 'lunch'),
      'progress photos': const ProgressPhotosScreen(),
      'coach (signed out)': const CoachScreen(),
      'profile + credit': const ProfileScreen(),
      'home photos card': const Scaffold(body: Padding(padding: EdgeInsets.all(16), child: ProgressPhotosHomeCard())),
    };
    for (final e in screens.entries) {
      testWidgets('${e.key} renders without overflow ($lang)', (tester) async {
        SharedPreferences.setMockInitialValues({'user_locale': lang});
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        // Two photos in the same pose (files missing on purpose → placeholders, no crash)
        for (final d in [1, 40]) {
          final t = DateTime(2026, 11, 22).subtract(Duration(days: d));
          await db.into(db.progressPhotos).insert(ProgressPhotosCompanion.insert(
                id: 'ph$d',
                date: '2026-10-${(d % 28 + 1).toString().padLeft(2, '0')}',
                timestamp: t,
                filePath: 'missing_$d.jpg',
                pose: const Value('front'),
                weightKg: const Value(80),
              ));
        }
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            locale: Locale(lang),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: e.value,
          ),
        ));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(tester.takeException(), isNull);
        if (e.key == 'profile + credit') {
          await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
          await tester.pump(const Duration(milliseconds: 300));
          expect(find.text(lang == 'ar' ? 'حفيان المهدي' : 'Mahdi Hafiane'), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
        await db.close();
      });
    }
  }
}
