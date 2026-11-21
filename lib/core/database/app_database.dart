import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'seed_data.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Profiles,
  Goals,
  Foods,
  FoodLogs,
  Recipes,
  RecipeIngredients,
  Exercises,
  WorkoutPrograms,
  ProgramExercises,
  WorkoutSessions,
  WorkoutSets,
  BodyMetrics,
  AppPreferences,
  AcademyProgress,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(academyProgress);
      }
    },
  );

  /// Seeds initial foods, exercises, and programs if not already present
  Future<void> seedInitialData() async {
    final existingFoodsCount = await select(foods).get();
    if (existingFoodsCount.isNotEmpty) return;

    final now = DateTime.now();

    // 1. Seed initial foods
    await batch((b) {
      for (final item in SeedData.initialFoods) {
        b.insert(
          foods,
          FoodsCompanion.insert(
            id: item['id'] as String,
            name: item['name'] as String,
            nameAr: Value(item['nameAr'] as String?),
            category: item['category'] as String,
            source: item['source'] as String,
            servingDescription: item['servingDescription'] as String,
            servingWeightG: (item['servingWeightG'] as num).toDouble(),
            caloriesPer100g: (item['caloriesPer100g'] as num).toDouble(),
            proteinPer100g: (item['proteinPer100g'] as num).toDouble(),
            carbsPer100g: (item['carbsPer100g'] as num).toDouble(),
            fatPer100g: (item['fatPer100g'] as num).toDouble(),
            fiberPer100g: Value((item['fiberPer100g'] as num?)?.toDouble()),
            prepState: Value(item['prepState'] as String? ?? 'raw'),
            isFavorite: Value(item['isFavorite'] as bool? ?? false),
            isCustom: Value(item['isCustom'] as bool? ?? false),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    // 2. Seed initial exercises
    await batch((b) {
      for (final ex in SeedData.initialExercises) {
        b.insert(
          exercises,
          ExercisesCompanion.insert(
            id: ex['id'] as String,
            name: ex['name'] as String,
            nameAr: Value(ex['nameAr'] as String?),
            muscleGroup: ex['muscleGroup'] as String,
            equipment: ex['equipment'] as String,
            exerciseType: Value(ex['exerciseType'] as String? ?? 'compound'),
            instructions: Value(ex['instructions'] as String?),
            instructionsAr: Value(ex['instructionsAr'] as String?),
            isCustom: Value(ex['isCustom'] as bool? ?? false),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    // 3. Seed starter workout programs
    final programs = [
      SeedData.starterPushProgram,
      SeedData.starterPullProgram,
      SeedData.starterLegsProgram,
    ];

    for (final prog in programs) {
      final progId = prog['id'] as String;
      await into(workoutPrograms).insert(
        WorkoutProgramsCompanion.insert(
          id: progId,
          name: prog['name'] as String,
          description: Value(prog['description'] as String?),
          scheduledDays: prog['scheduledDays'] as String,
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

      final exercisesList = prog['exercises'] as List<Map<String, dynamic>>;
      await batch((b) {
        for (final pEx in exercisesList) {
          b.insert(
            programExercises,
            ProgramExercisesCompanion.insert(
              id: '${progId}_${pEx['exerciseId']}',
              programId: progId,
              exerciseId: pEx['exerciseId'] as String,
              sortOrder: pEx['sortOrder'] as int,
              targetSets: pEx['targetSets'] as int,
              targetReps: pEx['targetReps'] as int,
              targetRestSeconds: Value(pEx['targetRestSeconds'] as int? ?? 90),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    }
  }

  Stream<List<AcademyProgressData>> watchAllAcademyProgress() {
    return select(academyProgress).watch();
  }

  Future<AcademyProgressData?> getLessonProgress(String lessonId) {
    return (select(academyProgress)..where((tbl) => tbl.lessonId.equals(lessonId))).getSingleOrNull();
  }

  Future<void> saveLessonProgress({
    required String lessonId,
    required bool isCompleted,
    required int quizScore,
  }) async {
    await into(academyProgress).insertOnConflictUpdate(
      AcademyProgressCompanion.insert(
        lessonId: lessonId,
        isCompleted: Value(isCompleted),
        quizScore: Value(quizScore),
        completedAt: Value(DateTime.now()),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fit_companion.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
