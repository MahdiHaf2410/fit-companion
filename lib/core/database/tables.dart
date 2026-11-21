import 'package:drift/drift.dart';

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  IntColumn get age => integer()();
  TextColumn get sex => text()(); // 'male', 'female'
  RealColumn get heightCm => real()();
  RealColumn get currentWeightKg => real()();
  TextColumn get activityLevel => text()();
  IntColumn get trainingFrequency => integer().nullable()();
  TextColumn get preferredUnits => text().withDefault(const Constant('metric'))();
  TextColumn get preferredLanguage => text().withDefault(const Constant('en'))();
  TextColumn get preferredTheme => text().withDefault(const Constant('system'))();
  BoolColumn get isOnboarded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get goalType => text()(); // 'muscleGain', 'fatLoss', 'maintenance', 'recomposition'
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get targetCalories => integer()();
  RealColumn get targetProteinGrams => real()();
  RealColumn get targetCarbsGrams => real()();
  RealColumn get targetFatGrams => real()();
  RealColumn get calculatedBmr => real()();
  RealColumn get calculatedTdee => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get category => text()(); // 'staples', 'protein', 'dairy', 'produce', 'algerian', 'snacks', 'custom'
  TextColumn get source => text()(); // 'verified', 'estimated', 'user'
  TextColumn get servingDescription => text()();
  RealColumn get servingWeightG => real()();
  RealColumn get caloriesPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get carbsPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get fiberPer100g => real().nullable()();
  TextColumn get prepState => text().withDefault(const Constant('raw'))(); // 'raw', 'cooked', 'prepared'
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class FoodLogs extends Table {
  TextColumn get id => text()();
  TextColumn get foodId => text().nullable().references(Foods, #id, onDelete: KeyAction.setNull)();
  TextColumn get date => text()(); // YYYY-MM-DD
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get mealType => text()(); // 'breakfast', 'lunch', 'dinner', 'snack'
  RealColumn get quantityG => real()();
  // Historical snapshot fields to prevent historical logs rewriting
  TextColumn get foodName => text()();
  TextColumn get foodNameAr => text().nullable()();
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  RealColumn get totalCookedYieldG => real().nullable()();
  RealColumn get totalCalories => real()();
  RealColumn get totalProtein => real()();
  RealColumn get totalCarbs => real()();
  RealColumn get totalFat => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get foodId => text().references(Foods, #id)();
  TextColumn get foodName => text()();
  RealColumn get quantityG => real()();
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get muscleGroup => text()(); // 'chest', 'back', 'legs', 'shoulders', 'arms', 'core'
  TextColumn get equipment => text()(); // 'barbell', 'dumbbell', 'cable', 'machine', 'bodyweight'
  TextColumn get exerciseType => text().withDefault(const Constant('compound'))(); // 'compound', 'isolation'
  TextColumn get instructions => text().nullable()();
  TextColumn get instructionsAr => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutPrograms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get scheduledDays => text()(); // e.g. "Monday,Wednesday,Friday"
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProgramExercises extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text().references(WorkoutPrograms, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get sortOrder => integer()();
  IntColumn get targetSets => integer()();
  IntColumn get targetReps => integer()();
  IntColumn get targetRestSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get programId => text().nullable().references(WorkoutPrograms, #id, onDelete: KeyAction.setNull)();
  TextColumn get programName => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get status => text()(); // 'active', 'completed', 'discarded'
  TextColumn get notes => text().nullable()();
  RealColumn get totalVolumeKg => real().withDefault(const Constant(0.0))();
  IntColumn get totalCompletedSets => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get exerciseName => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isPersonalRecord => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyMetrics extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get waistCm => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class AcademyProgress extends Table {
  TextColumn get lessonId => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get quizScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {lessonId};
}
