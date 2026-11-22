import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/services/backup_service.dart';
import 'package:fit_companion/core/services/notification_service.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/hydration/data/water_repository.dart';
import 'package:fit_companion/features/nutrition/data/meal_tools_repository.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';
import 'package:fit_companion/features/nutrition/data/open_food_facts.dart';
import 'package:fit_companion/features/progress/data/progress_repository.dart';
import 'package:fit_companion/features/progress/presentation/progress_photos_screen.dart';
import 'package:fit_companion/features/settings/backup_screen.dart';
import 'package:fit_companion/features/settings/health_screen.dart';
import 'package:fit_companion/features/settings/reminders_screen.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

Future<AppDatabase> _db() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.seedInitialData();
  await db.ensureSeedV3();
  return db;
}

void main() {
  test('backup export -> restore round trip keeps user data', () async {
    final a = await _db();
    final food = (await a.select(a.foods).get()).first;
    await NutritionRepository(a).logFood(food: food, quantityGrams: 150, mealType: 'dinner', timestamp: DateTime(2026, 11, 20, 20));
    await ProgressRepository(a).logMetric(weightKg: 78.4, chestCm: 101, date: DateTime(2026, 11, 20));
    await WaterRepository(a).addWater('2026-11-20', 750);
    final w = WorkoutRepository(a);
    final id = await w.startWorkoutSession(programName: 'B');
    await w.addSetToSession(sessionId: id, exerciseId: 'ex_deadlift', exerciseName: 'DL', setNumber: 1, weightKg: 140, reps: 5);
    final set = (await w.watchActiveSession().first)!.sets.single;
    await w.updateSetMeta(setId: set.id, setType: 'failure', rpe: 9.5);
    await w.updateSet(setId: set.id, weightKg: 140, reps: 5, isCompleted: true);
    await w.finishWorkoutSession(sessionId: id);
    await MealToolsRepository(a).saveMealAsTemplate(date: '2026-11-20', mealType: 'dinner', name: 'Dinner');

    final json = await BackupService(a).exportJson();
    final map = jsonDecode(json) as Map<String, dynamic>;
    expect(map['schemaVersion'], 4);
    expect(BackupService.countUserRows(map), greaterThanOrEqualTo(4));

    final b = await _db();
    await BackupService(b).restoreJson(json);
    expect((await b.select(b.foodLogs).get()).single.quantityG, 150);
    expect((await b.select(b.bodyMetrics).get()).single.chestCm, 101);
    expect(await WaterRepository(b).getWater('2026-11-20'), 750);
    final restoredSet = (await b.select(b.workoutSets).get()).single;
    expect(restoredSet.setType, 'failure');
    expect(restoredSet.rpe, 9.5);
    expect((await MealToolsRepository(b).watchTemplates().first).single.items.length, 1);
    await a.close();
    await b.close();
  });

  test('restore tolerates old backups without v3 fields and rejects foreign files', () async {
    final db = await _db();
    final old = {
      'format': BackupService.format,
      'schemaVersion': 2,
      'data': {
        'workoutSessions': [
          {'id': 's1', 'programId': null, 'programName': 'Old', 'startTime': 1761955200000, 'endTime': null, 'status': 'completed', 'notes': null, 'totalVolumeKg': 100.0, 'totalCompletedSets': 1}
        ],
        'workoutSets': [
          {'id': 'w1', 'sessionId': 's1', 'exerciseId': 'ex_bench_press', 'exerciseName': 'Bench', 'setNumber': 1, 'weightKg': 50.0, 'reps': 2, 'isCompleted': true, 'isPersonalRecord': false, 'completedAt': null}
        ],
      },
    };
    await BackupService(db).restoreJson(jsonEncode(old));
    expect((await db.select(db.workoutSets).get()).single.setType, 'normal');
    // Catalogue is re-seeded after restore
    expect((await db.select(db.exercises).get()).length, greaterThan(20));
    expect(() => BackupService(db).restoreJson('{"hello": 1}'), throwsFormatException);
    await db.close();
  });

  test('Open Food Facts parsing', () {
    final p = OffProduct.fromResponse('6130000000000', {
      'status': 1,
      'product': {
        'product_name': 'Yaourt nature',
        'brands': 'Soummam',
        'serving_quantity': 110,
        'nutriments': {'energy-kcal_100g': 62, 'proteins_100g': 3.5, 'carbohydrates_100g': '4,7', 'fat_100g': 3.2},
      },
    })!;
    expect(p.name, 'Yaourt nature (Soummam)');
    expect(p.carbs, 4.7);
    expect(p.servingG, 110);
    // kJ only -> converted to kcal
    final kj = OffProduct.fromResponse('1', {
      'status': 1,
      'product': {'product_name': 'X', 'nutriments': {'energy_100g': 418.4, 'proteins_100g': 1, 'carbohydrates_100g': 1, 'fat_100g': 1}},
    })!;
    expect(kj.kcal, closeTo(100, 0.01));
    expect(OffProduct.fromResponse('2', {'status': 0}), isNull);
  });

  test('reminder config', () {
    const c = ReminderConfig(water: true, waterEveryHours: 3, waterStartHour: 9, waterEndHour: 21);
    expect(c.waterHours(), [9, 12, 15, 18, 21]);
    final back = ReminderConfig.decode(c.copyWith(workoutWeekdays: [2, 4]).encode());
    expect(back.water, isTrue);
    expect(back.workoutWeekdays, [2, 4]);
    expect(ReminderConfig.decode('garbage').water, isFalse);
  });

  for (final lang in ['en', 'ar']) {
    final screens = <String, Widget>{
      'reminders': const RemindersScreen(),
      'backup': const BackupScreen(),
      'health': const HealthScreen(),
      'photos': const ProgressPhotosScreen(),
    };
    for (final e in screens.entries) {
      testWidgets('${e.key} screen renders ($lang)', (tester) async {
        SharedPreferences.setMockInitialValues({'user_locale': lang});
        final prefs = await SharedPreferences.getInstance();
        final db = await _db();
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
        if (e.key == 'reminders') {
          // Turning a reminder on persists the config (no-op notification service in tests).
          await tester.tap(find.byType(Switch).first);
          for (int i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 150));
          }
          final row = await (db.select(db.appPreferences)..where((p) => p.key.equals('reminders_config'))).getSingleOrNull();
          expect(ReminderConfig.decode(row?.value).water, isTrue);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
        await db.close();
      });
    }
  }
}
