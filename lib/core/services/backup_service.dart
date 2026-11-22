import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Full JSON snapshot of the user's data (used by local backup AND cloud sync).
///
/// - Includes `schemaVersion` so future versions can migrate old backups.
/// - Restore is tolerant: missing fields (older backups) get sensible defaults.
/// - Restore runs in ONE transaction: either everything is replaced or nothing.
/// - Progress photo FILES are not included (only their metadata).
class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  static const format = 'fit_companion_backup';

  /// Tables in foreign-key order (parents first).
  List<(String, TableInfo, Insertable Function(Map<String, dynamic>))> get _tables => [
        ('profiles', db.profiles, (j) => Profile.fromJson(j)),
        ('goals', db.goals, (j) => Goal.fromJson(j)),
        ('foods', db.foods, (j) => Food.fromJson(j)),
        ('foodLogs', db.foodLogs, (j) => FoodLog.fromJson(j)),
        ('recipes', db.recipes, (j) => Recipe.fromJson(j)),
        ('recipeIngredients', db.recipeIngredients, (j) => RecipeIngredient.fromJson(j)),
        ('exercises', db.exercises, (j) => Exercise.fromJson(j)),
        ('workoutPrograms', db.workoutPrograms, (j) => WorkoutProgram.fromJson(j)),
        ('programExercises', db.programExercises, (j) => ProgramExercise.fromJson(j)),
        ('workoutSessions', db.workoutSessions, (j) => WorkoutSession.fromJson(j)),
        ('workoutSets', db.workoutSets, (j) => WorkoutSet.fromJson(j)),
        ('bodyMetrics', db.bodyMetrics, (j) => BodyMetric.fromJson(j)),
        ('appPreferences', db.appPreferences, (j) => AppPreference.fromJson(j)),
        ('academyProgress', db.academyProgress, (j) => AcademyProgressData.fromJson(j)),
        ('mealTemplates', db.mealTemplates, (j) => MealTemplate.fromJson(j)),
        ('mealTemplateItems', db.mealTemplateItems, (j) => MealTemplateItem.fromJson(j)),
        ('progressPhotos', db.progressPhotos, (j) => ProgressPhoto.fromJson(j)),
      ];

  /// Defaults for non-null columns that may be missing in older backups.
  static const _defaults = <String, Object>{
    'setType': 'normal',
    'isFavorite': false,
    'isCustom': false,
    'isCompleted': false,
    'isPersonalRecord': false,
    'isOnboarded': false,
    'preferredUnits': 'metric',
    'preferredLanguage': 'en',
    'preferredTheme': 'system',
    'prepState': 'raw',
    'exerciseType': 'compound',
    'targetRestSeconds': 90,
    'totalVolumeKg': 0.0,
    'totalCompletedSets': 0,
    'servings': 1,
    'mealType': 'lunch',
    'pose': 'front',
    'quizScore': 0,
  };

  Future<Map<String, dynamic>> exportMap() async {
    final data = <String, dynamic>{};
    for (final (name, table, _) in _tables) {
      final rows = await db.select(table).get();
      data[name] = rows.map((r) => (r as DataClass).toJson()).toList();
    }
    return {
      'format': format,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    };
  }

  Future<String> exportJson() async => jsonEncode(await exportMap());

  /// Number of user records (excluding seeded catalogue rows) — used to warn before overwriting.
  static int countUserRows(Map<String, dynamic> backup) {
    final data = backup['data'] as Map<String, dynamic>? ?? const {};
    int n = 0;
    for (final k in ['foodLogs', 'workoutSessions', 'bodyMetrics', 'mealTemplates']) {
      n += (data[k] as List?)?.length ?? 0;
    }
    return n;
  }

  /// Replaces ALL local data with [json]. Throws [FormatException] for invalid files.
  Future<void> restoreJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic> || decoded['format'] != format) {
      throw const FormatException('Not a Fit Companion backup');
    }
    await restoreMap(decoded);
  }

  Future<void> restoreMap(Map<String, dynamic> backup) async {
    final data = backup['data'] as Map<String, dynamic>? ?? const {};
    // Parse everything BEFORE touching the database.
    final parsed = <(TableInfo, List<Insertable>)>[];
    for (final (name, table, fromJson) in _tables) {
      // Tables missing from the file (older/partial backups) are left untouched,
      // so catalogue rows (exercises, foods…) that other rows reference survive.
      if (!data.containsKey(name)) continue;
      final rows = (data[name] as List?) ?? const [];
      parsed.add((
        table,
        rows.map((r) {
          final m = Map<String, dynamic>.from(r as Map);
          _defaults.forEach((k, v) => m.putIfAbsent(k, () => v));
          return fromJson(m);
        }).toList(),
      ));
    }
    await db.transaction(() async {
      for (final (table, _) in parsed.reversed) {
        await db.delete(table).go();
      }
      for (final (table, rows) in parsed) {
        for (final row in rows) {
          await db.into(table).insert(row, mode: InsertMode.insertOrReplace);
        }
      }
    });
    // Restored backups from older versions still get the newest catalogue.
    await db.seedInitialData();
    await db.ensureSeedV3();
  }
}
