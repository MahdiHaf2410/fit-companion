import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkoutRepository(db);
    await db.seedInitialData();
  });

  tearDown(() async {
    await db.close();
  });

  group('WorkoutRepository Unit Tests', () {
    test('Starts workout session with exercises and sets', () async {
      final prog = await repo.watchProgramDetails('prog_push_hypertrophy').first;
      expect(prog, isNotNull);

      final sessionId = await repo.startWorkoutSession(
        programId: prog!.program.id,
        programName: prog.program.name,
        exercises: prog.exercises,
      );

      final active = await repo.getActiveSession();
      expect(active, isNotNull);
      expect(active!.id, equals(sessionId));
      expect(active.status, equals('active'));

      final sessionData = await repo.watchActiveSession().first;
      expect(sessionData, isNotNull);
      expect(sessionData!.sets.length, greaterThan(0));
    });

    test('Completes sets and calculates personal records', () async {
      final sessionId = await repo.startWorkoutSession(
        programName: 'PR Test Session',
      );

      await repo.addSetToSession(
        sessionId: sessionId,
        exerciseId: 'ex_bench_press',
        exerciseName: 'Barbell Bench Press',
        setNumber: 1,
        weightKg: 100.0,
        reps: 5,
      );

      final sessionData = await repo.watchActiveSession().first;
      final set = sessionData!.sets.first;

      // Update set to completed with 100kg
      await repo.updateSet(
        setId: set.id,
        weightKg: 100.0,
        reps: 5,
        isCompleted: true,
      );

      final updatedSessionData = await repo.watchActiveSession().first;
      final updatedSet = updatedSessionData!.sets.first;
      expect(updatedSet.isCompleted, isTrue);
      expect(updatedSet.isPersonalRecord, isTrue);

      // Finish workout
      await repo.finishWorkoutSession(sessionId: sessionId);

      final activeAfterFinish = await repo.getActiveSession();
      expect(activeAfterFinish, isNull);

      final history = await repo.watchWorkoutHistory().first;
      expect(history.length, equals(1));
      expect(history.first.totalVolumeKg, equals(500.0)); // 100 * 5
    });
  });
}
