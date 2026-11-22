import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/app/app.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/profile/data/profile_repository.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';
import 'package:fit_companion/features/workouts/presentation/active_workout_screen.dart';
import 'package:fit_companion/features/workouts/presentation/workout_providers.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

Future<void> _pumpFrames(WidgetTester tester, [int n = 10]) async {
  for (int i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  testWidgets('saving an onboarded profile leaves the onboarding screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedInitialData();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const FitCompanionApp(),
    ));
    await _pumpFrames(tester);
    expect(find.text('Welcome to Fit Companion'), findsOneWidget);

    final now = DateTime.now();
    await ProfileRepository(db).saveProfileAndGoal(
      profile: ProfilesCompanion.insert(
        id: 'p1', age: 25, sex: 'male', heightCm: 175, currentWeightKg: 75,
        activityLevel: 'moderate', isOnboarded: const Value(true), updatedAt: now,
      ),
      goal: GoalsCompanion.insert(
        id: 'g1', profileId: 'p1', goalType: 'maintenance', targetCalories: 2500,
        targetProteinGrams: 150, targetCarbsGrams: 280, targetFatGrams: 80,
        calculatedBmr: 1700, calculatedTdee: 2500, updatedAt: now,
      ),
    );
    await _pumpFrames(tester, 15);
    expect(find.text('Welcome to Fit Companion'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('swipe-deleting a set in the active workout does not throw', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedInitialData();
    final repo = WorkoutRepository(db);
    final prog = await repo.watchProgramDetails('prog_push_hypertrophy').first;
    await repo.startWorkoutSession(programId: prog!.program.id, programName: prog.program.name, exercises: prog.exercises);
    final before = (await repo.watchActiveSession().first)!.sets.length;

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ActiveWorkoutScreen(),
      ),
    ));
    await _pumpFrames(tester);

    // Start the swipe on the set-number area (not on a TextField).
    final rect = tester.getRect(find.byType(Dismissible).first);
    await tester.flingFrom(Offset(rect.left + 20, rect.center.dy), const Offset(-600, 0), 2500);
    await _pumpFrames(tester, 12);
    expect(tester.takeException(), isNull);
    final after = (await repo.watchActiveSession().first)!.sets.length;
    expect(after, before - 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  test('"last time" provider is fresh for each new session', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedInitialData();
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final repo = container.read(workoutRepositoryProvider);

    Future<void> doSession(double kg) async {
      final id = await repo.startWorkoutSession(programName: 'S');
      await repo.addSetToSession(sessionId: id, exerciseId: 'ex_bench_press', exerciseName: 'Bench', setNumber: 1, weightKg: kg, reps: 5);
      final set = (await repo.watchActiveSession().first)!.sets.single;
      await repo.updateSet(setId: set.id, weightKg: kg, reps: 5, isCompleted: true);
      await repo.finishWorkoutSession(sessionId: id);
      // Push older sessions back in time so ordering is unambiguous.
      await db.customStatement('UPDATE workout_sessions SET start_time = start_time - 86400 WHERE id != ?', [id]);
    }

    Future<double> readLast() async {
      final sub = container.listen(lastPerformanceProvider('ex_bench_press'), (_, __) {});
      final v = await container.read(lastPerformanceProvider('ex_bench_press').future);
      sub.close();
      await Future<void>.delayed(Duration.zero); // let autoDispose run
      return v['ex_bench_press']!.single.weightKg;
    }

    await doSession(60);
    expect(await readLast(), 60);
    await doSession(65);
    expect(await readLast(), 65);

    container.dispose();
    await db.close();
  });
}
