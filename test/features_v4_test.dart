import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/nutrition/data/meal_tools_repository.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';
import 'package:fit_companion/features/nutrition/presentation/food_search_screen.dart';
import 'package:fit_companion/features/nutrition/presentation/my_food_screen.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';
import 'package:fit_companion/features/workouts/presentation/program_editor_screen.dart';
import 'package:fit_companion/features/workouts/presentation/templates_screen.dart';
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
  group('Programs v4', () {
    test('built-in programs are templates; my programs start empty', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      expect(await repo.watchPrograms().first, isEmpty);
      final templates = await repo.watchTemplates().first;
      expect(templates.length, greaterThanOrEqualTo(12));
      await db.close();
    });

    test('create, edit and copy programs (e.g. Upper A + Arms & Abs)', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      final id = await repo.saveProgram(name: 'Upper A', exercises: [
        {'exerciseId': 'ex_bench_press', 'targetSets': 4, 'targetReps': 6, 'targetRestSeconds': 150},
        {'exerciseId': 'ex_barbell_row', 'targetSets': 4, 'targetReps': 8},
      ]);
      var d = (await repo.watchProgramDetails(id).first)!;
      expect(d.program.scheduledDays, '');
      expect(d.exercises.map((e) => e.exercise.id), ['ex_bench_press', 'ex_barbell_row']);

      // Edit: reorder + change sets + add one
      await repo.saveProgram(id: id, name: 'Upper A+', exercises: [
        {'exerciseId': 'ex_barbell_row', 'targetSets': 3, 'targetReps': 10},
        {'exerciseId': 'ex_bench_press', 'targetSets': 5, 'targetReps': 5},
        {'exerciseId': 'ex_db_curl', 'targetSets': 3, 'targetReps': 12},
      ]);
      d = (await repo.watchProgramDetails(id).first)!;
      expect(d.program.name, 'Upper A+');
      expect(d.exercises.first.exercise.id, 'ex_barbell_row');
      expect(d.exercises[1].programExercise.targetSets, 5);
      expect(d.exercises.length, 3);

      final copy = await repo.copyTemplate('prog_ul_upper');
      final mine = await repo.watchPrograms().first;
      expect(mine.map((p) => p.id), containsAll([id, copy]));
      expect(mine.every((p) => !p.isTemplate), isTrue);
      await db.close();
    });

    test('custom exercise is searchable and usable', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      final ex = await repo.createCustomExercise(name: 'Qzx custom curl', muscleGroup: 'core', equipment: 'other');
      expect(ex.isCustom, isTrue);
      final found = await repo.searchExercisesStream(query: 'qzx').first;
      expect(found.single.id, ex.id);
      // Library is complete (base + v3 + v4)
      expect((await repo.searchExercisesStream().first).length, greaterThan(140));
      expect((await repo.searchExercisesStream(muscleGroup: 'cardio').first), isNotEmpty);
      await db.close();
    });
  });

  group('Food v4', () {
    test('planned food does not count until eaten; copy creates planned items', () async {
      final db = await _db();
      final repo = NutritionRepository(db);
      final food = (await db.select(db.foods).get()).first;
      final day = DateTime(2026, 11, 22, 12);
      await repo.logFood(food: food, quantityGrams: 100, mealType: 'lunch', timestamp: day, isEaten: false);
      var s = await repo.watchDailySummary('2026-11-22').first;
      expect(s.caloriesConsumed, 0);
      expect(s.plannedCalories, closeTo(food.caloriesPer100g, 0.2));

      final log = (await repo.getDailyLogs('2026-11-22')).single;
      expect(log.eatenAt, isNull);
      await repo.markEaten(log.id, at: DateTime(2026, 11, 22, 13, 30));
      s = await repo.watchDailySummary('2026-11-22').first;
      expect(s.caloriesConsumed, closeTo(food.caloriesPer100g, 0.2));
      expect(s.plannedCalories, 0);
      expect((await repo.getDailyLogs('2026-11-22')).single.eatenAt, DateTime(2026, 11, 22, 13, 30));

      await repo.markPlanned(log.id);
      expect((await repo.watchDailySummary('2026-11-22').first).caloriesConsumed, 0);

      await repo.markEaten(log.id);
      await MealToolsRepository(db).copyLogs(fromDate: '2026-11-22', toDate: '2026-11-23');
      final copied = (await repo.getDailyLogs('2026-11-23')).single;
      expect(copied.isEaten, isFalse);
      await db.close();
    });

    test('my foods vs suggestions + description + delete', () async {
      final db = await _db();
      final repo = NutritionRepository(db);
      expect(await repo.searchFoodsStream(mine: true).first, isEmpty);
      expect(await repo.searchFoodsStream(mine: false).first, isNotEmpty);
      final id = await repo.saveCustomFood(
        name: 'Couscous poulet',
        description: '150 g couscous, 120 g chicken',
        category: 'custom',
        servingWeightG: 300,
        servingDescription: '300 g',
        caloriesPer100g: 160,
        proteinPer100g: 11,
        carbsPer100g: 20,
        fatPer100g: 4,
        prepState: 'prepared',
      );
      final mine = await repo.searchFoodsStream(mine: true).first;
      expect(mine.single.description, contains('chicken'));
      expect(await repo.deleteCustomFood(id), isTrue);
      expect(await repo.searchFoodsStream(mine: true).first, isEmpty);
      await db.close();
    });
  });

  for (final lang in ['en', 'ar']) {
    final screens = <String, Widget>{
      'program editor': const ProgramEditorScreen(),
      'program editor (edit)': const ProgramEditorScreen(programId: 'prog_ul_upper'),
      'templates': const TemplatesScreen(),
      'food search': const FoodSearchScreen(initialMealType: 'lunch'),
      'my food': const MyFoodScreen(mealType: 'dinner'),
    };
    for (final e in screens.entries) {
      testWidgets('${e.key} renders without overflow ($lang)', (tester) async {
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
        if (e.key == 'food search') {
          // Suggestions tab still lists the built-in foods
          await tester.tap(find.byType(Tab).last);
          for (int i = 0; i < 8; i++) {
            await tester.pump(const Duration(milliseconds: 150));
          }
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 100));
        await db.close();
      });
    }
  }
}
