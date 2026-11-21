// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fit Companion';

  @override
  String get navHome => 'Home';

  @override
  String get navNutrition => 'Nutrition';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get dashboardTitle => 'Daily Overview';

  @override
  String get dashboardNutritionCard => 'Daily Nutrition';

  @override
  String get dashboardCalories => 'Calories';

  @override
  String dashboardCalorieTarget(int target) {
    return 'Target: $target kcal';
  }

  @override
  String get dashboardConsumed => 'Consumed';

  @override
  String get dashboardRemaining => 'Remaining';

  @override
  String get dashboardOverLimit => 'Over by';

  @override
  String get dashboardProtein => 'Protein';

  @override
  String get dashboardCarbs => 'Carbs';

  @override
  String get dashboardFat => 'Fat';

  @override
  String dashboardGrams(String amount, String target) {
    return '${amount}g / ${target}g';
  }

  @override
  String get dashboardTodayWorkout => 'Today\'s Workout';

  @override
  String get dashboardNoWorkoutToday => 'No workout scheduled for today';

  @override
  String get dashboardStartWorkout => 'Start Workout';

  @override
  String get dashboardResumeWorkout => 'Resume Workout';

  @override
  String get dashboardWorkoutCompleted => 'Today\'s Workout Completed!';

  @override
  String get dashboardBodyProgress => 'Body Progress';

  @override
  String dashboardLatestWeight(String weight) {
    return 'Latest Weight: $weight kg';
  }

  @override
  String get dashboardNoWeightYet => 'No weight recorded yet';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardActionAddFood => 'Log Food';

  @override
  String get dashboardActionStartWorkout => 'Workout';

  @override
  String get dashboardActionLogWeight => 'Log Weight';

  @override
  String get dashboardActionBuildRecipe => 'New Recipe';

  @override
  String dashboardEstimatedTarget(int target) {
    return 'Estimated Daily Target: $target kcal';
  }

  @override
  String get dashboardCalculatorCard => 'Personal Energy Calculator';

  @override
  String get dashboardCalculatorDesc =>
      'Calculate evidence-based calories and macros with Mifflin–St Jeor.';

  @override
  String get dashboardAcademyCard => 'Nutrition Academy';

  @override
  String get dashboardAcademyDesc =>
      '14 practical lessons with quizzes and interactive tools.';

  @override
  String get onboardingTitle => 'Welcome to Fit Companion';

  @override
  String get onboardingSubtitle =>
      'Your offline personal fitness and nutrition companion';

  @override
  String get onboardingName => 'Display Name (Optional)';

  @override
  String get onboardingAge => 'Age';

  @override
  String get onboardingSex => 'Sex';

  @override
  String get onboardingSexMale => 'Male';

  @override
  String get onboardingSexFemale => 'Female';

  @override
  String get onboardingHeight => 'Height (cm)';

  @override
  String get onboardingWeight => 'Current Weight (kg)';

  @override
  String get onboardingActivity => 'Activity Level';

  @override
  String get onboardingActivitySedentary => 'Sedentary (little or no exercise)';

  @override
  String get onboardingActivityLight => 'Lightly Active (1-3 days/week)';

  @override
  String get onboardingActivityModerate => 'Moderately Active (3-5 days/week)';

  @override
  String get onboardingActivityVery => 'Very Active (6-7 days/week)';

  @override
  String get onboardingActivityExtra =>
      'Extra Active (hard daily exercise or physical job)';

  @override
  String get onboardingGoal => 'Fitness Goal';

  @override
  String get onboardingGoalMuscleGain => 'Muscle Gain / Weight Gain';

  @override
  String get onboardingGoalFatLoss => 'Fat Loss';

  @override
  String get onboardingGoalMaintenance => 'Maintenance';

  @override
  String get onboardingGoalRecomp => 'Body Recomposition';

  @override
  String get onboardingTrainingFreq => 'Training Days Per Week';

  @override
  String get onboardingUnits => 'Measurement Units';

  @override
  String get onboardingLanguage => 'Language';

  @override
  String get onboardingAppearance => 'Appearance';

  @override
  String get onboardingCalculate => 'Calculate Energy Needs';

  @override
  String get onboardingTargetSummary => 'Estimated Daily Energy Needs';

  @override
  String get onboardingDisclaimer =>
      'Estimated with the Mifflin–St Jeor equation. Calorie targets are scientific estimates for guidance, not medical prescriptions.';

  @override
  String get onboardingGetStarted => 'Save and Get Started';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionDailySummary => 'Daily Summary';

  @override
  String get nutritionLogFood => 'Log Food';

  @override
  String get nutritionMealBreakfast => 'Breakfast';

  @override
  String get nutritionMealLunch => 'Lunch';

  @override
  String get nutritionMealDinner => 'Dinner';

  @override
  String get nutritionMealSnacks => 'Snacks';

  @override
  String get nutritionSearchPlaceholder => 'Search foods or Algerian dishes...';

  @override
  String get nutritionCategories => 'Categories';

  @override
  String get nutritionCategoryAll => 'All';

  @override
  String get nutritionCategoryStaples => 'Staples & Grains';

  @override
  String get nutritionCategoryProtein => 'Meat & Fish';

  @override
  String get nutritionCategoryDairy => 'Dairy & Eggs';

  @override
  String get nutritionCategoryProduce => 'Fruits & Veggies';

  @override
  String get nutritionCategoryAlgerian => 'Algerian Dishes';

  @override
  String get nutritionCategorySnacks => 'Legumes & Nuts';

  @override
  String get nutritionRecent => 'Recent Foods';

  @override
  String get nutritionFavorites => 'Favorites';

  @override
  String get nutritionCustom => 'Custom Foods';

  @override
  String get nutritionAddCustomFood => 'Create Custom Food';

  @override
  String get nutritionRecipes => 'Recipes';

  @override
  String get nutritionCreateRecipe => 'Build Recipe';

  @override
  String get nutritionServingSize => 'Serving Size';

  @override
  String get nutritionQuantity => 'Quantity (grams)';

  @override
  String get nutritionSelectMeal => 'Select Meal Type';

  @override
  String get nutritionSaveLog => 'Add to Log';

  @override
  String get nutritionDeleteLog => 'Delete Entry';

  @override
  String get nutritionCaloriesPer100g => 'Calories (per 100g)';

  @override
  String get nutritionProteinPer100g => 'Protein (per 100g)';

  @override
  String get nutritionCarbsPer100g => 'Carbs (per 100g)';

  @override
  String get nutritionFatPer100g => 'Fat (per 100g)';

  @override
  String get nutritionFiberPer100g => 'Fiber (per 100g)';

  @override
  String get nutritionFoodName => 'Food Name';

  @override
  String get nutritionFoodNameArabic => 'Food Name (Arabic - Optional)';

  @override
  String get nutritionState => 'Preparation State (e.g., Raw, Cooked)';

  @override
  String get nutritionSource => 'Source / Confidence';

  @override
  String get nutritionVerified => 'Verified';

  @override
  String get nutritionEstimated => 'Estimated';

  @override
  String get nutritionUserAdded => 'Custom';

  @override
  String get nutritionNoLogs =>
      'No food logged for this day yet. Tap \'+\' to start logging!';

  @override
  String nutritionTotalCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get recipeTitle => 'Recipe Builder';

  @override
  String get recipeName => 'Recipe Name';

  @override
  String get recipeServings => 'Number of Servings';

  @override
  String get recipeTotalCookedYield => 'Total Cooked Weight (grams, optional)';

  @override
  String get recipeYieldHelp =>
      'Water loss or absorption during cooking changes total weight.';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeAddIngredient => 'Add Ingredient';

  @override
  String recipePerServing(int cal, String p, String c, String f) {
    return 'Per Serving: $cal kcal | P: ${p}g | C: ${c}g | F: ${f}g';
  }

  @override
  String get recipeSave => 'Save Recipe';

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get workoutsPrograms => 'Workout Programs';

  @override
  String get workoutsCreateProgram => 'New Program';

  @override
  String get workoutsProgramName => 'Program Name';

  @override
  String get workoutsProgramDesc => 'Description';

  @override
  String workoutsDays(String days) {
    return 'Days: $days';
  }

  @override
  String get workoutsExercises => 'Exercises';

  @override
  String get workoutsAddExercise => 'Add Exercise';

  @override
  String get workoutsExerciseLibrary => 'Exercise Library';

  @override
  String get workoutsMuscleGroup => 'Muscle Group';

  @override
  String get workoutsEquipment => 'Equipment';

  @override
  String workoutsTargetSets(int sets, int reps) {
    return 'Target Sets: $sets x $reps reps';
  }

  @override
  String get workoutsActiveSession => 'Active Workout';

  @override
  String get workoutsRestTimer => 'Rest Timer';

  @override
  String workoutsRestTimeRemaining(int seconds) {
    return '${seconds}s Rest';
  }

  @override
  String get workoutsSetHeader => 'Set';

  @override
  String get workoutsWeightHeader => 'kg';

  @override
  String get workoutsRepsHeader => 'Reps';

  @override
  String get workoutsCompletedHeader => 'Done';

  @override
  String get workoutsAddSet => 'Add Set';

  @override
  String get workoutsSkipExercise => 'Skip Exercise';

  @override
  String get workoutsFinishWorkout => 'Finish Workout';

  @override
  String get workoutsDiscardWorkout => 'Discard Workout';

  @override
  String get workoutsConfirmFinish =>
      'Do you want to complete and save this workout?';

  @override
  String get workoutsConfirmDiscard =>
      'Are you sure you want to discard this session?';

  @override
  String get workoutsSessionCompleted => 'Workout Summary';

  @override
  String workoutsDuration(int minutes) {
    return 'Duration: $minutes mins';
  }

  @override
  String workoutsTotalVolume(String volume) {
    return 'Total Volume: $volume kg';
  }

  @override
  String workoutsTotalSets(int sets) {
    return 'Completed Sets: $sets';
  }

  @override
  String get workoutsHistory => 'Workout History';

  @override
  String get workoutsNoHistory =>
      'No completed workouts yet. Start your first session!';

  @override
  String get workoutsPR => 'Personal Record!';

  @override
  String get progressTitle => 'Progress & Metrics';

  @override
  String get progressWeightHistory => 'Body Weight Trend';

  @override
  String get progressAddMetric => 'Log Body Metric';

  @override
  String get progressWaist => 'Waist Circumference (cm)';

  @override
  String get progressDate => 'Date';

  @override
  String get progressTimeRange1M => '1 Month';

  @override
  String get progressTimeRange3M => '3 Months';

  @override
  String get progressTimeRangeAll => 'All Time';

  @override
  String progressWeeklyAverage(String avg) {
    return '7-Day Moving Avg: $avg kg';
  }

  @override
  String get progressExercisePRs => 'Exercise Personal Records';

  @override
  String get progressNoMetrics =>
      'No body measurements logged yet. Track your weight regularly to see trends!';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileGoals => 'Goals & Targets';

  @override
  String get profileEditGoals => 'Adjust Targets';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileThemeSystem => 'System Default';

  @override
  String get profileThemeLight => 'Light Mode';

  @override
  String get profileThemeDark => 'Dark Mode';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileLanguageAr => 'العربية (Arabic)';

  @override
  String get profileUnits => 'Units';

  @override
  String get profileUnitsMetric => 'Metric (kg, cm)';

  @override
  String get profileUnitsImperial => 'Imperial (lb, in)';

  @override
  String get profileData => 'Data & Privacy';

  @override
  String get profileExportJson => 'Export Data (JSON)';

  @override
  String get profileResetData => 'Clear All Data';

  @override
  String get profileResetConfirm =>
      'Are you sure? This will delete all logged foods, workouts, and measurements.';

  @override
  String get profileAbout => 'About Fit Companion';

  @override
  String get profileAboutText =>
      'Fit Companion is a private, offline-first fitness and nutrition companion engineered for real-life workout and nutrition tracking.';

  @override
  String get profileOfflineStatus =>
      '100% Offline & Private: Your data is stored strictly on your device.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonClose => 'Close';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonSuccess => 'Operation completed successfully';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonKcal => 'kcal';

  @override
  String get commonGrams => 'g';

  @override
  String get commonKg => 'kg';

  @override
  String get commonCm => 'cm';

  @override
  String get commonReps => 'reps';

  @override
  String get commonSets => 'sets';

  @override
  String get nutritionCalculatorTitle => 'Personal Nutrition Calculator';

  @override
  String get nutritionCalculatorDesc =>
      'Calculate evidence-based energy requirements and macronutrient targets tailored to your body.';

  @override
  String get nutritionCalculatorBmr => 'Basal Metabolic Rate (BMR)';

  @override
  String get nutritionCalculatorBmrDesc =>
      'Energy consumed at complete rest to keep your brain, heart, and vital organs alive.';

  @override
  String get nutritionCalculatorTdee => 'Total Daily Energy Expenditure (TDEE)';

  @override
  String get nutritionCalculatorTdeeDesc =>
      'Resting energy multiplied by your physical activity factor.';

  @override
  String get nutritionCalculatorTarget => 'Personalized Target';

  @override
  String get nutritionCalculatorHow => 'How Was This Calculated?';

  @override
  String get nutritionCalculatorFormula => 'Mifflin–St Jeor Equation';

  @override
  String get nutritionCalculatorManualAdjust => 'Adjust Targets Manually';

  @override
  String get nutritionCalculatorReset => 'Restore Recommended Targets';

  @override
  String get nutritionCalculatorApply => 'Apply Targets to My Profile';

  @override
  String get nutritionCalculatorConfirm =>
      'Update your profile targets? Your daily dashboard and diary targets will update immediately.';

  @override
  String get nutritionCalculatorMacroWarning =>
      'Warning: Total calories from macros (P×4 + C×4 + F×9) does not match the target calories.';

  @override
  String get nutritionTrainingType => 'Training Style';

  @override
  String get nutritionTrainingStrength => 'Strength & Hypertrophy';

  @override
  String get nutritionTrainingCardio => 'Cardio & Endurance';

  @override
  String get nutritionTrainingHybrid => 'Functional & Hybrid';

  @override
  String get nutritionTrainingGeneral => 'General Health & Fitness';

  @override
  String get academyTitle => 'Nutrition Academy';

  @override
  String get academySubtitle =>
      'Master nutrition and calorie tracking with practical beginner-friendly lessons and quizzes.';

  @override
  String academyLesson(int number) {
    return 'Lesson $number';
  }

  @override
  String get academyQuiz => 'Knowledge Check';

  @override
  String get academyCompleted => 'Completed';

  @override
  String get academyTakeaway => 'Practical Takeaway';

  @override
  String get academyInteractiveTool => 'Interactive Calculator Tool';

  @override
  String academyScore(int score) {
    return 'Score: $score%';
  }

  @override
  String get foodCalculatorTitle => 'Smart Food Calculator';

  @override
  String get foodCalculatorSubtitle =>
      'Calculate precise nutrition values based on portion weight and preparation state.';

  @override
  String get foodCalculatorServingType => 'Serving & Prep State';

  @override
  String get foodCalculatorFormulaHelp =>
      'Formula: (Nutrient per 100g × Grams) ÷ 100';

  @override
  String get foodCalculatorAddToMeal => 'Log Calculated Food';
}
