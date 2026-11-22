import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/utils/strength_calculator.dart';
import 'package:fit_companion/features/hydration/data/water_repository.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';

void main() {
  group('StrengthCalculator', () {
    test('Epley 1RM', () {
      expect(StrengthCalculator.estimateOneRepMax(100, 1), 100);
      expect(StrengthCalculator.estimateOneRepMax(100, 10), closeTo(133.33, 0.01));
      expect(StrengthCalculator.estimateOneRepMax(0, 5), 0);
    });

    test('Plate calculator loads per side greedily', () {
      final r = StrengthCalculator.platesPerSide(100, barKg: 20);
      expect(r.plates, [25, 15]);
      expect(r.achievedKg, 100);
      expect(r.remainderKg, 0);
      expect(StrengthCalculator.platesPerSide(15).plates, isEmpty);
      final odd = StrengthCalculator.platesPerSide(21, barKg: 20);
      expect(odd.remainderKg, greaterThan(0));
    });
  });

  group('Training stats', () {
    WorkoutSession s(DateTime start, double vol) => WorkoutSession(
          id: start.toIso8601String(),
          startTime: start,
          status: 'completed',
          totalVolumeKg: vol,
          totalCompletedSets: 3,
        );

    test('streak counts consecutive days ending today or yesterday', () {
      final now = DateTime(2026, 11, 22, 18);
      final history = [
        s(DateTime(2026, 11, 21, 10), 1000),
        s(DateTime(2026, 11, 20, 10), 500),
        s(DateTime(2026, 11, 18, 10), 200),
      ];
      final stats = WorkoutRepository.computeStats(history, now);
      expect(stats.currentStreakDays, 2);
      expect(stats.workoutsThisWeek, 3);
      expect(stats.volumeThisWeekKg, 1700);
      expect(stats.last7Days.last, isFalse); // today empty
      expect(stats.last7Days[5], isTrue); // yesterday
    });
  });

  group('WorkoutRepository session behaviour', () {
    late AppDatabase db;
    late WorkoutRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = WorkoutRepository(db);
      await db.seedInitialData();
    });

    tearDown(() => db.close());

    test('active session stream re-emits when a set changes', () async {
      final id = await repo.startWorkoutSession(programName: 'Stream test');
      await repo.addSetToSession(
        sessionId: id, exerciseId: 'ex_bench_press', exerciseName: 'Bench', setNumber: 1, weightKg: 50, reps: 8);

      final emissions = <ActiveSessionWithSets?>[];
      final sub = repo.watchActiveSession().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final setId = emissions.last!.sets.single.id;

      await repo.updateSet(setId: setId, weightKg: 60, reps: 8, isCompleted: true);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emissions.last!.sets.single.isCompleted, isTrue);
      expect(emissions.last!.sets.single.weightKg, 60);
    });

    test('starting a workout while one is active returns the same session', () async {
      final a = await repo.startWorkoutSession(programName: 'A');
      final b = await repo.startWorkoutSession(programName: 'B');
      expect(b, a);
    });

    test('finishing removes unfinished sets and last performance is reported', () async {
      final id = await repo.startWorkoutSession(programName: 'History');
      await repo.addSetToSession(sessionId: id, exerciseId: 'ex_bench_press', exerciseName: 'Bench', setNumber: 1, weightKg: 70, reps: 6);
      await repo.addSetToSession(sessionId: id, exerciseId: 'ex_bench_press', exerciseName: 'Bench', setNumber: 2, weightKg: 70, reps: 6);
      final sets = (await repo.watchActiveSession().first)!.sets;
      final isPr = await repo.updateSet(setId: sets.first.id, weightKg: 70, reps: 6, isCompleted: true);
      expect(isPr, isTrue);
      await repo.finishWorkoutSession(sessionId: id);

      final detail = await repo.watchSessionDetail(id).first;
      expect(detail!.sets.length, 1);
      final last = await repo.getLastPerformance('ex_bench_press');
      expect(last!.single.weightKg, 70);
      final prs = await repo.watchPersonalRecords().first;
      expect(prs.single.estimatedOneRepMax, closeTo(84, 0.01));
    });
  });

  group('WaterRepository', () {
    test('adds and clamps water per day', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repo = WaterRepository(db);
      await repo.addWater('2026-11-22', 250);
      await repo.addWater('2026-11-22', 500);
      expect(await repo.getWater('2026-11-22'), 750);
      await repo.addWater('2026-11-22', -5000);
      expect(await repo.getWater('2026-11-22'), 0);
      expect(WaterRepository.recommendedGoal(80), 2750);
      await db.close();
    });
  });
}
