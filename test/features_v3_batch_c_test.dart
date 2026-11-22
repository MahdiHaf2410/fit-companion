import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/services/cloud_service.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/coach/coach_context.dart';
import 'package:fit_companion/features/coach/coach_screen.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';
import 'package:fit_companion/features/progress/data/progress_repository.dart';
import 'package:fit_companion/features/settings/cloud_screen.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

void main() {
  test('coach context is a compact summary without personal identifiers', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedInitialData();
    final now = DateTime.now();
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: 'p',
          displayName: const Value('Secret Name'),
          age: 24,
          sex: 'male',
          heightCm: 178,
          currentWeightKg: 80,
          activityLevel: 'moderate',
          updatedAt: now,
        ));
    final food = (await db.select(db.foods).get()).first;
    await NutritionRepository(db).logFood(food: food, quantityGrams: 300, mealType: 'lunch', timestamp: now);
    await ProgressRepository(db).logMetric(weightKg: 81, date: now.subtract(const Duration(days: 10)));
    await ProgressRepository(db).logMetric(weightKg: 80, date: now);

    final ctx = await CoachContextBuilder(db).build();
    expect(ctx, contains('Profile: male, 24 y'));
    expect(ctx, contains('logged 1/7 days'));
    expect(ctx, contains('81.0 → 80.0 kg'));
    expect(ctx, isNot(contains('Secret Name')));
    expect(ctx.length, lessThan(4000));
    await db.close();
  });

  test('cloud status: remote newer detection', () {
    final t = DateTime(2026, 11, 22, 10);
    expect(CloudStatus(enabled: true, email: 'a@b.c', lastSyncedAt: t, remoteUpdatedAt: t).remoteIsNewer, isFalse);
    expect(CloudStatus(enabled: true, email: 'a@b.c', lastSyncedAt: t, remoteUpdatedAt: t.add(const Duration(minutes: 5))).remoteIsNewer, isTrue);
    expect(CloudStatus(enabled: true, email: 'a@b.c', remoteUpdatedAt: t).remoteIsNewer, isTrue);
  });

  for (final lang in ['en', 'ar']) {
    for (final e in {'cloud': const CloudScreen(), 'coach': const CoachScreen()}.entries) {
      testWidgets('${e.key} screen renders offline ($lang)', (tester) async {
        SharedPreferences.setMockInitialValues({'user_locale': lang});
        final prefs = await SharedPreferences.getInstance();
        final db = AppDatabase.forTesting(NativeDatabase.memory());
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
        for (int i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
        await db.close();
      });
    }
  }
}
