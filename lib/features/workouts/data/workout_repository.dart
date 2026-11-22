import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/strength_calculator.dart';

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

  /// Rest seconds per exercise id, taken from the program (falls back to 90s).
  final Map<String, int> restSecondsByExercise;

  /// Target reps per exercise id (from the program) — used by overload suggestions.
  final Map<String, int> targetRepsByExercise;

  /// Exercise type per id ('compound' / 'isolation').
  final Map<String, String> exerciseTypes;

  /// Program notes per exercise id (e.g. 5/3/1 instructions).
  final Map<String, String> notesByExercise;

  ActiveSessionWithSets({
    required this.session,
    required this.sets,
    this.restSecondsByExercise = const {},
    this.targetRepsByExercise = const {},
    this.exerciseTypes = const {},
    this.notesByExercise = const {},
  });

  int restFor(String exerciseId) => restSecondsByExercise[exerciseId] ?? 90;
}

/// Best completed set for an exercise (by estimated 1RM).
class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final double estimatedOneRepMax;
  final DateTime? date;

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.estimatedOneRepMax,
    this.date,
  });
}

/// Aggregated training statistics used by the dashboard & workouts screen.
class TrainingStats {
  final int totalWorkouts;
  final int workoutsThisWeek;
  final int currentStreakDays;
  final double volumeThisWeekKg;

  /// Which of the last 7 days (index 0 = 6 days ago, 6 = today) had a workout.
  final List<bool> last7Days;

  const TrainingStats({
    this.totalWorkouts = 0,
    this.workoutsThisWeek = 0,
    this.currentStreakDays = 0,
    this.volumeThisWeekKg = 0,
    this.last7Days = const [false, false, false, false, false, false, false],
  });
}

class ExerciseSessionStat {
  final String sessionId;
  final DateTime date;
  final double bestE1rm;
  final double topWeightKg;
  final double volumeKg;
  final int sets;
  final String bestSet;

  const ExerciseSessionStat({
    required this.sessionId,
    required this.date,
    required this.bestE1rm,
    required this.topWeightKg,
    required this.volumeKg,
    required this.sets,
    required this.bestSet,
  });
}

class SessionDetail {
  final WorkoutSession session;
  final List<WorkoutSet> sets;

  SessionDetail({required this.session, required this.sets});
}

class WorkoutRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  WorkoutRepository(this._db);

  /// The user's own programs (templates excluded).
  Stream<List<WorkoutProgram>> watchPrograms() {
    return (_db.select(_db.workoutPrograms)
          ..where((p) => p.isTemplate.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
        .watch();
  }

  /// Ready-made programs the user can copy and customise.
  Stream<List<WorkoutProgram>> watchTemplates() {
    return (_db.select(_db.workoutPrograms)
          ..where((p) => p.isTemplate.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  /// Creates (id == null) or replaces a user program with [exercises]
  /// (each: exerciseId, targetSets, targetReps, targetRestSeconds, notes?).
  Future<String> saveProgram({
    String? id,
    required String name,
    String? description,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final now = DateTime.now();
    final programId = id ?? _uuid.v4();
    await _db.transaction(() async {
      if (id == null) {
        await _db.into(_db.workoutPrograms).insert(WorkoutProgramsCompanion.insert(
              id: programId,
              name: name,
              description: Value(description),
              scheduledDays: '',
              createdAt: now,
              updatedAt: now,
            ));
      } else {
        await (_db.update(_db.workoutPrograms)..where((p) => p.id.equals(id))).write(WorkoutProgramsCompanion(
              name: Value(name),
              description: Value(description),
              isTemplate: const Value(false),
              updatedAt: Value(now),
            ));
        await (_db.delete(_db.programExercises)..where((pe) => pe.programId.equals(id))).go();
      }
      for (int i = 0; i < exercises.length; i++) {
        final e = exercises[i];
        await _db.into(_db.programExercises).insert(ProgramExercisesCompanion.insert(
              id: _uuid.v4(),
              programId: programId,
              exerciseId: e['exerciseId'] as String,
              sortOrder: i + 1,
              targetSets: e['targetSets'] as int? ?? 3,
              targetReps: e['targetReps'] as int? ?? 10,
              targetRestSeconds: Value(e['targetRestSeconds'] as int? ?? 90),
              notes: Value(e['notes'] as String?),
            ));
      }
    });
    return programId;
  }

  /// Copies a template into the user's programs so it can be customised freely.
  Future<String> copyTemplate(String templateId) async {
    final details = await watchProgramDetails(templateId).first;
    if (details == null) throw StateError('template_not_found');
    return saveProgram(
      name: details.program.name,
      description: details.program.description,
      exercises: [
        for (final d in details.exercises)
          {
            'exerciseId': d.exercise.id,
            'targetSets': d.programExercise.targetSets,
            'targetReps': d.programExercise.targetReps,
            'targetRestSeconds': d.programExercise.targetRestSeconds,
            'notes': d.programExercise.notes,
          },
      ],
    );
  }

  /// Adds an exercise that is missing from the library.
  Future<Exercise> createCustomExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
    String exerciseType = 'compound',
    String? instructions,
  }) async {
    final id = 'custom_${_uuid.v4()}';
    await _db.into(_db.exercises).insert(ExercisesCompanion.insert(
          id: id,
          name: name,
          nameAr: Value(name),
          muscleGroup: muscleGroup,
          equipment: equipment,
          exerciseType: Value(exerciseType),
          instructions: Value(instructions),
          instructionsAr: Value(instructions),
          isCustom: const Value(true),
        ));
    return (await getExercise(id))!;
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
        final ex = await (_db.select(_db.exercises)..where((e) => e.id.equals(pe.exerciseId))).getSingleOrNull();
        if (ex != null) details.add(ProgramExerciseDetail(programExercise: pe, exercise: ex));
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

  // ---------------------------------------------------------------------------
  // Active workout session management
  // ---------------------------------------------------------------------------

  /// Emits whenever the session row OR any of its sets change (previously only
  /// the sessions table was watched, so ticking a set did not refresh the UI).
  Stream<ActiveSessionWithSets?> watchActiveSession() {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.workoutSessions, _db.workoutSets},
        )
        .watch()
        .asyncMap((_) => _loadActiveSession());
  }

  Future<ActiveSessionWithSets?> _loadActiveSession() async {
    final session = await getActiveSession();
    if (session == null) return null;
    final sets = await (_db.select(_db.workoutSets)
          ..where((s) => s.sessionId.equals(session.id))
          ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
        .get();

    final rest = <String, int>{};
    final reps = <String, int>{};
    final notes = <String, String>{};
    if (session.programId != null) {
      final pes = await (_db.select(_db.programExercises)
            ..where((pe) => pe.programId.equals(session.programId!))
            ..orderBy([(pe) => OrderingTerm.asc(pe.sortOrder)]))
          .get();
      for (final pe in pes) {
        rest.putIfAbsent(pe.exerciseId, () => pe.targetRestSeconds);
        reps.putIfAbsent(pe.exerciseId, () => pe.targetReps);
        if (pe.notes != null && pe.notes!.isNotEmpty) notes.putIfAbsent(pe.exerciseId, () => pe.notes!);
      }
    }
    final ids = sets.map((s) => s.exerciseId).toSet().toList();
    final types = <String, String>{};
    if (ids.isNotEmpty) {
      final exs = await (_db.select(_db.exercises)..where((e) => e.id.isIn(ids))).get();
      for (final e in exs) {
        types[e.id] = e.exerciseType;
      }
    }
    return ActiveSessionWithSets(
      session: session,
      sets: sets,
      restSecondsByExercise: rest,
      targetRepsByExercise: reps,
      exerciseTypes: types,
      notesByExercise: notes,
    );
  }

  /// Returns the most recent active session. Tolerates legacy data where more than
  /// one session was left 'active' (that used to crash `watchSingleOrNull`).
  Future<WorkoutSession?> getActiveSession() async {
    final rows = await (_db.select(_db.workoutSessions)
          ..where((s) => s.status.equals('active'))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Starts a new session. If one is already active it is returned instead of
  /// creating a second active session.
  Future<String> startWorkoutSession({
    String? programId,
    String? programName,
    List<ProgramExerciseDetail>? exercises,
  }) async {
    final existing = await getActiveSession();
    if (existing != null) return existing.id;

    final sessionId = _uuid.v4();
    final now = DateTime.now();

    // Programs like 5/3/1 list the same exercise twice (main sets + BBB): keep
    // numbering continuous per exercise so blocks don't interleave.
    final nextSetNumber = <String, int>{};
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
          // Pre-fill with the smart progressive-overload suggestion
          final last = await getLastPerformance(item.exercise.id);
          final suggestion = StrengthCalculator.suggestNextWeight(
            lastSets: last ?? const [],
            targetReps: item.programExercise.targetReps,
            isCompound: item.exercise.exerciseType == 'compound',
          );
          for (int s = 1; s <= item.programExercise.targetSets; s++) {
            await _db.into(_db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: _uuid.v4(),
                sessionId: sessionId,
                exerciseId: item.exercise.id,
                exerciseName: item.exercise.name,
                setNumber: nextSetNumber.update(item.exercise.id, (v) => v + 1, ifAbsent: () => 1),
                weightKg: suggestion?.weightKg ?? 0.0,
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

  /// Adds a whole exercise (3 empty sets) to the running session.
  Future<void> addExerciseToSession({
    required String sessionId,
    required Exercise exercise,
    int sets = 3,
    int reps = 10,
  }) async {
    final last = await getLastPerformance(exercise.id);
    // Continue after existing sets of the same exercise in this session.
    final existing = await (_db.select(_db.workoutSets)
          ..where((x) => x.sessionId.equals(sessionId) & x.exerciseId.equals(exercise.id)))
        .get();
    final start = existing.fold<int>(0, (a, x) => x.setNumber > a ? x.setNumber : a);
    for (int s = 1; s <= sets; s++) {
      await addSetToSession(
        sessionId: sessionId,
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        setNumber: start + s,
        weightKg: (last?.isNotEmpty ?? false) ? last!.first.weightKg : 0,
        reps: reps,
      );
    }
  }

  /// Changes the type (normal / warmup / drop / failure) and RPE of a set.
  Future<void> updateSetMeta({required String setId, required String setType, double? rpe}) async {
    await (_db.update(_db.workoutSets)..where((s) => s.id.equals(setId))).write(
      WorkoutSetsCompanion(setType: Value(setType), rpe: Value(rpe)),
    );
  }

  /// Links [exerciseId] with [nextExerciseId] as a superset (same group number),
  /// or removes the link when [nextExerciseId] is null.
  Future<void> setSuperset({required String sessionId, required String exerciseId, String? nextExerciseId}) async {
    if (nextExerciseId == null) {
      final current = await (_db.select(_db.workoutSets)
            ..where((s) => s.sessionId.equals(sessionId) & s.exerciseId.equals(exerciseId))
            ..limit(1))
          .getSingleOrNull();
      final group = current?.supersetGroup;
      if (group == null) return;
      await (_db.update(_db.workoutSets)..where((s) => s.sessionId.equals(sessionId) & s.supersetGroup.equals(group)))
          .write(const WorkoutSetsCompanion(supersetGroup: Value(null)));
      return;
    }
    final all = await (_db.select(_db.workoutSets)..where((s) => s.sessionId.equals(sessionId))).get();
    final existing = all.firstWhere((s) => s.exerciseId == exerciseId).supersetGroup;
    final group = existing ?? (all.map((s) => s.supersetGroup ?? 0).fold<int>(0, (a, b) => a > b ? a : b) + 1);
    await (_db.update(_db.workoutSets)
          ..where((s) => s.sessionId.equals(sessionId) & s.exerciseId.isIn([exerciseId, nextExerciseId])))
        .write(WorkoutSetsCompanion(supersetGroup: Value(group)));
  }

  /// Per-session progress of one exercise (best e1RM, top weight, volume).
  Stream<List<ExerciseSessionStat>> watchExerciseHistory(String exerciseId) {
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.workoutSessions, _db.workoutSets})
        .watch()
        .asyncMap((_) async {
      final rows = await (_db.select(_db.workoutSets).join([
        innerJoin(_db.workoutSessions, _db.workoutSessions.id.equalsExp(_db.workoutSets.sessionId)),
      ])
            ..where(_db.workoutSets.exerciseId.equals(exerciseId) &
                _db.workoutSets.isCompleted.equals(true) &
                _db.workoutSets.setType.equals('warmup').not() &
                _db.workoutSessions.status.equals('completed'))
            ..orderBy([OrderingTerm.asc(_db.workoutSessions.startTime)]))
          .get();
      final bySession = <String, ExerciseSessionStat>{};
      for (final r in rows) {
        final session = r.readTable(_db.workoutSessions);
        final set = r.readTable(_db.workoutSets);
        final e1rm = StrengthCalculator.estimateOneRepMax(set.weightKg, set.reps);
        final prev = bySession[session.id];
        bySession[session.id] = ExerciseSessionStat(
          sessionId: session.id,
          date: session.startTime,
          bestE1rm: prev == null || e1rm > prev.bestE1rm ? e1rm : prev.bestE1rm,
          topWeightKg: prev == null || set.weightKg > prev.topWeightKg ? set.weightKg : prev.topWeightKg,
          volumeKg: (prev?.volumeKg ?? 0) + set.weightKg * set.reps,
          sets: (prev?.sets ?? 0) + 1,
          bestSet: prev == null || e1rm > prev.bestE1rm ? '${_fmt(set.weightKg)}×${set.reps}' : prev.bestSet,
        );
      }
      return bySession.values.toList();
    });
  }

  static String _fmt(double w) => w.toStringAsFixed(w % 1 == 0 ? 0 : 1);

  /// Completed working sets per muscle group during the last [days] days.
  Stream<Map<String, int>> watchMuscleSets({int days = 7}) {
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.workoutSessions, _db.workoutSets})
        .watch()
        .asyncMap((_) async {
      final since = DateTime.now().subtract(Duration(days: days));
      final rows = await (_db.select(_db.workoutSets).join([
        innerJoin(_db.exercises, _db.exercises.id.equalsExp(_db.workoutSets.exerciseId)),
        innerJoin(_db.workoutSessions, _db.workoutSessions.id.equalsExp(_db.workoutSets.sessionId)),
      ])
            ..where(_db.workoutSets.isCompleted.equals(true) &
                _db.workoutSets.setType.equals('warmup').not() &
                _db.workoutSessions.startTime.isBiggerOrEqualValue(since)))
          .get();
      final result = <String, int>{};
      for (final r in rows) {
        final g = r.readTable(_db.exercises).muscleGroup;
        result[g] = (result[g] ?? 0) + 1;
      }
      return result;
    });
  }

  Future<Exercise?> getExercise(String id) =>
      (_db.select(_db.exercises)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> deleteSet(String setId) async {
    await (_db.delete(_db.workoutSets)..where((s) => s.id.equals(setId))).go();
  }

  /// Updates a set and returns `true` when it became a new personal record.
  Future<bool> updateSet({
    required String setId,
    required double weightKg,
    required int reps,
    required bool isCompleted,
  }) async {
    final set = await (_db.select(_db.workoutSets)..where((s) => s.id.equals(setId))).getSingleOrNull();
    if (set == null) return false;
    // PR = heavier than any OTHER completed set of this exercise
    final previousMax = await _getMaxWeightForExercise(set.exerciseId, excludeSetId: setId);
    final isPr = isCompleted && set.setType != 'warmup' && weightKg > 0 && weightKg > (previousMax ?? 0.0);

    await (_db.update(_db.workoutSets)..where((s) => s.id.equals(setId))).write(
      WorkoutSetsCompanion(
        weightKg: Value(weightKg),
        reps: Value(reps),
        isCompleted: Value(isCompleted),
        isPersonalRecord: Value(isPr),
        completedAt: Value(isCompleted ? DateTime.now() : null),
      ),
    );
    return isPr && !set.isPersonalRecord;
  }

  Future<double?> _getMaxWeightForExercise(String exerciseId, {String? excludeSetId}) async {
    final query = _db.select(_db.workoutSets)
      ..where((s) {
        var cond = s.exerciseId.equals(exerciseId) & s.isCompleted.equals(true) & s.setType.equals('warmup').not();
        if (excludeSetId != null) cond = cond & s.id.equals(excludeSetId).not();
        return cond;
      })
      ..orderBy([(s) => OrderingTerm.desc(s.weightKg)])
      ..limit(1);
    final record = await query.getSingleOrNull();
    return record?.weightKg;
  }

  /// Completed sets of the most recent COMPLETED session that contained [exerciseId].
  Future<List<WorkoutSet>?> getLastPerformance(String exerciseId) async {
    final query = _db.select(_db.workoutSets).join([
      innerJoin(_db.workoutSessions, _db.workoutSessions.id.equalsExp(_db.workoutSets.sessionId)),
    ])
      ..where(_db.workoutSets.exerciseId.equals(exerciseId) &
          _db.workoutSets.isCompleted.equals(true) &
          _db.workoutSets.setType.equals('warmup').not() &
          _db.workoutSessions.status.equals('completed'))
      ..orderBy([OrderingTerm.desc(_db.workoutSessions.startTime), OrderingTerm.asc(_db.workoutSets.setNumber)]);

    final rows = await query.get();
    if (rows.isEmpty) return null;
    final lastSessionId = rows.first.readTable(_db.workoutSessions).id;
    return rows
        .where((r) => r.readTable(_db.workoutSessions).id == lastSessionId)
        .map((r) => r.readTable(_db.workoutSets))
        .toList();
  }

  /// Map exerciseId -> last completed sets (for the active workout "previous" column).
  Future<Map<String, List<WorkoutSet>>> getLastPerformanceFor(Iterable<String> exerciseIds) async {
    final result = <String, List<WorkoutSet>>{};
    for (final id in exerciseIds.toSet()) {
      final last = await getLastPerformance(id);
      if (last != null) result[id] = last;
    }
    return result;
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
      if (s.setType == 'warmup') continue; // warm-ups don't count as working volume
      totalVolume += (s.weightKg * s.reps);
    }

    // Drop sets that were never completed so history stays clean
    await (_db.delete(_db.workoutSets)
          ..where((s) => s.sessionId.equals(sessionId) & s.isCompleted.equals(false)))
        .go();

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

  Future<void> deleteSession(String sessionId) => discardWorkoutSession(sessionId);

  Stream<List<WorkoutSession>> watchWorkoutHistory() {
    return (_db.select(_db.workoutSessions)
          ..where((s) => s.status.equals('completed'))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .watch();
  }

  Stream<SessionDetail?> watchSessionDetail(String sessionId) {
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.workoutSessions, _db.workoutSets})
        .watch()
        .asyncMap((_) async {
      final session = await (_db.select(_db.workoutSessions)..where((s) => s.id.equals(sessionId))).getSingleOrNull();
      if (session == null) return null;
      final sets = await (_db.select(_db.workoutSets)
            ..where((s) => s.sessionId.equals(sessionId))
            ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
          .get();
      return SessionDetail(session: session, sets: sets);
    });
  }

  Future<List<WorkoutSet>> getCompletedSetsForSession(String sessionId) {
    return (_db.select(_db.workoutSets)
          ..where((s) => s.sessionId.equals(sessionId) & s.isCompleted.equals(true)))
        .get();
  }

  /// Live personal records: best estimated 1RM per exercise.
  Stream<List<PersonalRecord>> watchPersonalRecords() {
    return (_db.select(_db.workoutSets)..where((s) => s.isCompleted.equals(true))).watch().map((all) {
      final best = <String, PersonalRecord>{};
      for (final s in all) {
        if (s.weightKg <= 0 || s.setType == 'warmup') continue;
        final e1rm = StrengthCalculator.estimateOneRepMax(s.weightKg, s.reps);
        final current = best[s.exerciseId];
        if (current == null || e1rm > current.estimatedOneRepMax) {
          best[s.exerciseId] = PersonalRecord(
            exerciseId: s.exerciseId,
            exerciseName: s.exerciseName,
            weightKg: s.weightKg,
            reps: s.reps,
            estimatedOneRepMax: e1rm,
            date: s.completedAt,
          );
        }
      }
      final list = best.values.toList()
        ..sort((a, b) => b.estimatedOneRepMax.compareTo(a.estimatedOneRepMax));
      return list;
    });
  }

  /// Kept for backwards compatibility with older callers/tests.
  Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    final prs = await watchPersonalRecords().first;
    return prs
        .map((p) => {
              'exerciseId': p.exerciseId,
              'exerciseName': p.exerciseName,
              'maxWeightKg': p.weightKg,
              'reps': p.reps,
              'date': p.date,
            })
        .toList();
  }

  /// Streak, weekly volume and the 7-day activity strip.
  Stream<TrainingStats> watchTrainingStats() {
    return watchWorkoutHistory().map((history) => computeStats(history, DateTime.now()));
  }

  static TrainingStats computeStats(List<WorkoutSession> history, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final daysWithWorkout = <DateTime>{};
    for (final s in history) {
      final d = s.startTime;
      daysWithWorkout.add(DateTime(d.year, d.month, d.day));
    }

    final last7 = List<bool>.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return daysWithWorkout.contains(day);
    });

    // Week starts on Saturday? Use rolling 7 days which works for every locale.
    final weekStart = today.subtract(const Duration(days: 6));
    int weekCount = 0;
    double weekVolume = 0;
    for (final s in history) {
      if (!s.startTime.isBefore(weekStart)) {
        weekCount++;
        weekVolume += s.totalVolumeKg;
      }
    }

    // Streak: consecutive days with a workout, allowing today to be empty.
    int streak = 0;
    var cursor = daysWithWorkout.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (daysWithWorkout.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return TrainingStats(
      totalWorkouts: history.length,
      workoutsThisWeek: weekCount,
      currentStreakDays: streak,
      volumeThisWeekKg: weekVolume,
      last7Days: last7,
    );
  }
}
