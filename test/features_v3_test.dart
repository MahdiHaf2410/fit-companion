import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/core/utils/strength_calculator.dart';
import 'package:fit_companion/features/achievements/achievements.dart';
import 'package:fit_companion/features/achievements/achievements_screen.dart';
import 'package:fit_companion/features/nutrition/data/meal_tools_repository.dart';
import 'package:fit_companion/features/nutrition/data/nutrition_repository.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';
import 'package:fit_companion/features/workouts/presentation/exercise_detail_screen.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

WorkoutSet _set(double w, int r, {String type = 'normal'}) => WorkoutSet(
      id: '$w$r$type',
      sessionId: 's',
      exerciseId: 'e',
      exerciseName: 'E',
      setNumber: 1,
      weightKg: w,
      reps: r,
      isCompleted: true,
      isPersonalRecord: false,
      setType: type,
    );

Future<AppDatabase> _db() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.seedInitialData();
  await db.ensureSeedV3();
  return db;
}

/// Runs a full session of one exercise with the given (weight, reps, type) sets.
Future<String> _session(WorkoutRepository repo, String exerciseId, List<(double, int, String)> sets) async {
  final id = await repo.startWorkoutSession(programName: 'T');
  for (int i = 0; i < sets.length; i++) {
    await repo.addSetToSession(
        sessionId: id, exerciseId: exerciseId, exerciseName: exerciseId, setNumber: i + 1, weightKg: sets[i].$1, reps: sets[i].$2);
  }
  final rows = (await repo.watchActiveSession().first)!.sets;
  for (int i = 0; i < rows.length; i++) {
    await repo.updateSetMeta(setId: rows[i].id, setType: sets[i].$3);
    await repo.updateSet(setId: rows[i].id, weightKg: sets[i].$1, reps: sets[i].$2, isCompleted: true);
  }
  await repo.finishWorkoutSession(sessionId: id);
  return id;
}

void main() {
  group('Progressive overload suggestion', () {
    test('increase when all top sets hit target', () {
      final s = StrengthCalculator.suggestNextWeight(lastSets: [_set(60, 8), _set(60, 9)], targetReps: 8, isCompound: true)!;
      expect(s.change, OverloadChange.increase);
      expect(s.weightKg, 62.5);
    });
    test('isolation uses smaller step and warm-ups are ignored', () {
      final s = StrengthCalculator.suggestNextWeight(
          lastSets: [_set(5, 15, type: 'warmup'), _set(12, 12)], targetReps: 12, isCompound: false)!;
      expect(s.weightKg, 13.25);
    });
    test('keep when close, deload when far below', () {
      expect(StrengthCalculator.suggestNextWeight(lastSets: [_set(60, 7)], targetReps: 8, isCompound: true)!.change,
          OverloadChange.keep);
      final d = StrengthCalculator.suggestNextWeight(lastSets: [_set(100, 4)], targetReps: 8, isCompound: true)!;
      expect(d.change, OverloadChange.decrease);
      expect(d.weightKg, lessThan(100));
    });
    test('no history -> null', () {
      expect(StrengthCalculator.suggestNextWeight(lastSets: const [], targetReps: 8, isCompound: true), isNull);
    });
  });

  group('Workout v3 data', () {
    test('warm-ups excluded from volume, PRs and last performance', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      final id = await _session(repo, 'ex_bench_press', [(40, 10, 'warmup'), (80, 5, 'normal')]);
      final detail = await repo.watchSessionDetail(id).first;
      expect(detail!.session.totalVolumeKg, 400);
      final last = await repo.getLastPerformance('ex_bench_press');
      expect(last!.length, 1);
      final prs = await repo.watchPersonalRecords().first;
      expect(prs.single.weightKg, 80);
      await db.close();
    });

    test('exercise history and weekly muscle sets', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      await _session(repo, 'ex_bench_press', [(60, 8, 'normal'), (60, 8, 'normal')]);
      final hist = await repo.watchExerciseHistory('ex_bench_press').first;
      expect(hist.single.sets, 2);
      expect(hist.single.topWeightKg, 60);
      final muscles = await repo.watchMuscleSets().first;
      expect(muscles['chest'], 2);
      await db.close();
    });

    test('5/3/1 main + BBB blocks are numbered in order, not interleaved', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      final prog = await repo.watchProgramDetails('prog_531_press').first;
      await repo.startWorkoutSession(programId: prog!.program.id, programName: prog.program.name, exercises: prog.exercises);
      final active = (await repo.watchActiveSession().first)!;
      final bench = active.sets.where((s) => s.exerciseId == 'ex_bench_press').toList();
      expect(bench.map((s) => s.reps).toList(), [5, 5, 5, 10, 10, 10, 10, 10]);
      expect(bench.map((s) => s.setNumber).toList(), [1, 2, 3, 4, 5, 6, 7, 8]);
      // Adding the same exercise again continues the numbering
      final ex = (await repo.getExercise('ex_bench_press'))!;
      await repo.addExerciseToSession(sessionId: active.session.id, exercise: ex, sets: 2);
      final after = (await repo.watchActiveSession().first)!.sets.where((s) => s.exerciseId == 'ex_bench_press').toList();
      expect(after.last.setNumber, 10);
      await db.close();
    });

    test('superset links two exercises and can be removed', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      final id = await repo.startWorkoutSession(programName: 'SS');
      await repo.addSetToSession(sessionId: id, exerciseId: 'ex_barbell_curl', exerciseName: 'Curl', setNumber: 1, weightKg: 20, reps: 10);
      await repo.addSetToSession(sessionId: id, exerciseId: 'ex_triceps_pushdown', exerciseName: 'Push', setNumber: 1, weightKg: 20, reps: 10);
      await repo.setSuperset(sessionId: id, exerciseId: 'ex_barbell_curl', nextExerciseId: 'ex_triceps_pushdown');
      var sets = (await repo.watchActiveSession().first)!.sets;
      expect(sets.map((s) => s.supersetGroup).toSet(), {1});
      await repo.setSuperset(sessionId: id, exerciseId: 'ex_barbell_curl');
      sets = (await repo.watchActiveSession().first)!.sets;
      expect(sets.every((s) => s.supersetGroup == null), isTrue);
      await db.close();
    });

    test('program start pre-fills the overload suggestion', () async {
      final db = await _db();
      final repo = WorkoutRepository(db);
      // Bench target in push program = 8 reps; last time 60x8 on all sets -> 62.5
      await _session(repo, 'ex_bench_press', [(60, 8, 'normal'), (60, 8, 'normal')]);
      final prog = await repo.watchProgramDetails('prog_push_hypertrophy').first;
      await repo.startWorkoutSession(programId: prog!.program.id, programName: 'Push', exercises: prog.exercises);
      final active = (await repo.watchActiveSession().first)!;
      final bench = active.sets.where((s) => s.exerciseId == 'ex_bench_press');
      expect(bench.first.weightKg, 62.5);
      expect(active.targetRepsByExercise['ex_bench_press'], 8);
      await db.close();
    });
  });

  group('Meals v3', () {
    test('copy yesterday and templates', () async {
      final db = await _db();
      final nutrition = NutritionRepository(db);
      final tools = MealToolsRepository(db);
      final food = (await db.select(db.foods).get()).first;
      await nutrition.logFood(food: food, quantityGrams: 200, mealType: 'lunch', timestamp: DateTime(2026, 11, 21, 13));
      expect(await tools.copyLogs(fromDate: '2026-11-21', toDate: '2026-11-22'), 1);
      expect((await nutrition.getDailyLogs('2026-11-22')).single.quantityG, 200);

      expect(await tools.saveMealAsTemplate(date: '2026-11-21', mealType: 'lunch', name: 'My lunch'), isTrue);
      final templates = await tools.watchTemplates().first;
      expect(templates.single.items.length, 1);
      await tools.applyTemplate(templateId: templates.single.template.id, date: '2026-11-23', mealType: 'dinner');
      expect((await nutrition.getDailyLogs('2026-11-23')).single.mealType, 'dinner');
      await tools.deleteTemplate(templates.single.template.id);
      expect(await tools.watchTemplates().first, isEmpty);
      await db.close();
    });

    test('scanned food is cached by barcode', () async {
      final db = await _db();
      final tools = MealToolsRepository(db);
      await tools.saveScannedFood(barcode: '123', name: 'Yogurt', caloriesPer100g: 60, proteinPer100g: 4, carbsPer100g: 5, fatPer100g: 2);
      expect((await tools.findByBarcode('123'))!.name, 'Yogurt');
      await db.close();
    });
  });

  test('achievement stats', () async {
    final db = await _db();
    final repo = WorkoutRepository(db);
    await _session(repo, 'ex_bench_press', [(60, 8, 'normal')]);
    final stats = await AchievementsRepository(db).computeStats();
    expect(stats.workouts, 1);
    expect(stats.longestStreak, 1);
    expect(stats.prs, 1);
    final first = achievementDefs.firstWhere((d) => d.id == 'first_workout');
    expect(Achievement(first, first.value(stats)).unlocked, isTrue);
    await db.close();
  });

  for (final lang in ['en', 'ar']) {
    for (final screen in ['exercise', 'achievements']) {
      testWidgets('$screen screen renders without overflow ($lang)', (tester) async {
        SharedPreferences.setMockInitialValues({'user_locale': lang});
        final prefs = await SharedPreferences.getInstance();
        final db = await _db();
        await _session(WorkoutRepository(db), 'ex_bench_press', [(60, 8, 'normal'), (62.5, 8, 'normal')]);
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
            home: screen == 'exercise' ? const ExerciseDetailScreen(exerciseId: 'ex_bench_press') : const AchievementsScreen(),
          ),
        ));
        for (int i = 0; i < 12; i++) {
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
