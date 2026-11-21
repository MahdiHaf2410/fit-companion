import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';

class ProgramWithExercises {
  final WorkoutProgram program;
  final List<ProgramExerciseDetail> exercises;

  ProgramWithExercises({required this.program, required this.exercises});
}

class ProgramExerciseDetail {
  final ProgramExercise programExercise;
  final Exercise exercise;

  ProgramExerciseDetail({required this.programExercise, required this.exercise});
}

class ActiveSessionWithSets {
  final WorkoutSession session;
  final List<WorkoutSet> sets;

  ActiveSessionWithSets({required this.session, required this.sets});
}

class WorkoutRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  WorkoutRepository(this._db);

  Stream<List<WorkoutProgram>> watchPrograms() {
    return (_db.select(_db.workoutPrograms)..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();
  }

  Future<List<WorkoutProgram>> getPrograms() {
    return (_db.select(_db.workoutPrograms)..orderBy([(p) => OrderingTerm.asc(p.name)])).get();
  }

  Stream<ProgramWithExercises?> watchProgramDetails(String programId) {
    final progStream = (_db.select(_db.workoutPrograms)..where((p) => p.id.equals(programId))).watchSingleOrNull();
    return progStream.asyncMap((prog) async {
      if (prog == null) return null;

      final pExercises = await (_db.select(_db.programExercises)
            ..where((pe) => pe.programId.equals(programId))
            ..orderBy([(pe) => OrderingTerm.asc(pe.sortOrder)]))
          .get();

      final details = <ProgramExerciseDetail>[];
      for (final pe in pExercises) {
        final ex = await (_db.select(_db.exercises)..where((e) => e.id.equals(pe.exerciseId))).getSingle();
        details.add(ProgramExerciseDetail(programExercise: pe, exercise: ex));
      }

      return ProgramWithExercises(program: prog, exercises: details);
    });
  }

  Stream<List<Exercise>> searchExercisesStream({String query = '', String muscleGroup = 'all'}) {
    return (_db.select(_db.exercises)
          ..where((e) {
            final matchesQuery = query.isEmpty
                ? const Constant(true)
                : (e.name.lower().contains(query.toLowerCase()) |
                   e.nameAr.lower().contains(query.toLowerCase()));
            final matchesGroup = muscleGroup == 'all'
                ? const Constant(true)
                : e.muscleGroup.equals(muscleGroup);
            return matchesQuery & matchesGroup;
          })
          ..orderBy([(e) => OrderingTerm.asc(e.name)]))
        .watch();
  }

  Future<void> createProgram({
    required String name,
    String? description,
    required String scheduledDays,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final now = DateTime.now();
    final programId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.workoutPrograms).insert(
        WorkoutProgramsCompanion.insert(
          id: programId,
          name: name,
          description: Value(description),
          scheduledDays: scheduledDays,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (int i = 0; i < exercises.length; i++) {
        final exData = exercises[i];
        await _db.into(_db.programExercises).insert(
          ProgramExercisesCompanion.insert(
            id: _uuid.v4(),
            programId: programId,
            exerciseId: exData['exerciseId'] as String,
            sortOrder: i + 1,
            targetSets: exData['targetSets'] as int? ?? 3,
            targetReps: exData['targetReps'] as int? ?? 10,
            targetRestSeconds: Value(exData['targetRestSeconds'] as int? ?? 90),
            notes: Value(exData['notes'] as String?),
          ),
        );
      }
    });
  }

  Future<void> deleteProgram(String programId) async {
    await (_db.delete(_db.workoutPrograms)..where((p) => p.id.equals(programId))).go();
  }

  // Active workout session management
  Stream<ActiveSessionWithSets?> watchActiveSession() {
    return (_db.select(_db.workoutSessions)..where((s) => s.status.equals('active'))).watchSingleOrNull().asyncMap((session) async {
      if (session == null) return null;
      final sets = await (_db.select(_db.workoutSets)
            ..where((s) => s.sessionId.equals(session.id))
            ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
          .get();
      return ActiveSessionWithSets(session: session, sets: sets);
    });
  }

  Future<WorkoutSession?> getActiveSession() async {
    return (_db.select(_db.workoutSessions)..where((s) => s.status.equals('active'))).getSingleOrNull();
  }

  Future<String> startWorkoutSession({
    String? programId,
    String? programName,
    List<ProgramExerciseDetail>? exercises,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.workoutSessions).insert(
        WorkoutSessionsCompanion.insert(
          id: sessionId,
          programId: Value(programId),
          programName: Value(programName ?? 'Quick Workout'),
          startTime: now,
          status: 'active',
        ),
      );

      if (exercises != null && exercises.isNotEmpty) {
        for (final item in exercises) {
          for (int s = 1; s <= item.programExercise.targetSets; s++) {
            await _db.into(_db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: _uuid.v4(),
                sessionId: sessionId,
                exerciseId: item.exercise.id,
                exerciseName: item.exercise.name,
                setNumber: s,
                weightKg: 0.0,
                reps: item.programExercise.targetReps,
                isCompleted: const Value(false),
              ),
            );
          }
        }
      }
    });

    return sessionId;
  }

  Future<void> addSetToSession({
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    required int setNumber,
    required double weightKg,
    required int reps,
  }) async {
    await _db.into(_db.workoutSets).insert(
      WorkoutSetsCompanion.insert(
        id: _uuid.v4(),
        sessionId: sessionId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        setNumber: setNumber,
        weightKg: weightKg,
        reps: reps,
        isCompleted: const Value(false),
      ),
    );
  }

  Future<void> updateSet({
    required String setId,
    required double weightKg,
    required int reps,
    required bool isCompleted,
  }) async {
    // Check if personal record
    final set = await (_db.select(_db.workoutSets)..where((s) => s.id.equals(setId))).getSingle();
    final previousMax = await _getMaxWeightForExercise(set.exerciseId);
    final isPr = isCompleted && weightKg > (previousMax ?? 0.0);

    await (_db.update(_db.workoutSets)..where((s) => s.id.equals(setId))).write(
      WorkoutSetsCompanion(
        weightKg: Value(weightKg),
        reps: Value(reps),
        isCompleted: Value(isCompleted),
        isPersonalRecord: Value(isPr),
        completedAt: Value(isCompleted ? DateTime.now() : null),
      ),
    );
  }

  Future<double?> _getMaxWeightForExercise(String exerciseId) async {
    final query = _db.select(_db.workoutSets)
      ..where((s) => s.exerciseId.equals(exerciseId) & s.isCompleted.equals(true))
      ..orderBy([(s) => OrderingTerm.desc(s.weightKg)])
      ..limit(1);
    final record = await query.getSingleOrNull();
    return record?.weightKg;
  }

  Future<void> finishWorkoutSession({
    required String sessionId,
    String? notes,
  }) async {
    final sets = await (_db.select(_db.workoutSets)
          ..where((s) => s.sessionId.equals(sessionId) & s.isCompleted.equals(true)))
        .get();

    double totalVolume = 0.0;
    for (final s in sets) {
      totalVolume += (s.weightKg * s.reps);
    }

    await (_db.update(_db.workoutSessions)..where((s) => s.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        endTime: Value(DateTime.now()),
        status: const Value('completed'),
        notes: Value(notes),
        totalVolumeKg: Value(totalVolume),
        totalCompletedSets: Value(sets.length),
      ),
    );
  }

  Future<void> discardWorkoutSession(String sessionId) async {
    await (_db.delete(_db.workoutSessions)..where((s) => s.id.equals(sessionId))).go();
  }

  Stream<List<WorkoutSession>> watchWorkoutHistory() {
    return (_db.select(_db.workoutSessions)
          ..where((s) => s.status.equals('completed'))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .watch();
  }

  Future<List<WorkoutSet>> getCompletedSetsForSession(String sessionId) {
    return (_db.select(_db.workoutSets)
          ..where((s) => s.sessionId.equals(sessionId) & s.isCompleted.equals(true)))
        .get();
  }

  Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    final allCompleted = await (_db.select(_db.workoutSets)
          ..where((s) => s.isCompleted.equals(true))
          ..orderBy([(s) => OrderingTerm.desc(s.weightKg)]))
        .get();

    final Map<String, WorkoutSet> prMap = {};
    for (final s in allCompleted) {
      if (!prMap.containsKey(s.exerciseId) || (s.weightKg > prMap[s.exerciseId]!.weightKg)) {
        prMap[s.exerciseId] = s;
      }
    }

    return prMap.values.map((s) => {
      'exerciseId': s.exerciseId,
      'exerciseName': s.exerciseName,
      'maxWeightKg': s.weightKg,
      'reps': s.reps,
      'date': s.completedAt,
    }).toList();
  }
}
