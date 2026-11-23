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

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get dashboardKcalLeft => 'kcal left';

  @override
  String get dashboardKcalOver => 'kcal over';

  @override
  String get dashboardGoal => 'Goal';

  @override
  String get dashboardInProgress => 'In progress';

  @override
  String get dashboardWeekActivity => 'Weekly activity';

  @override
  String get dashboardTools => 'Tools & learning';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonMl => 'ml';

  @override
  String get commonToday => 'Today';

  @override
  String get waterTitle => 'Hydration';

  @override
  String waterProgress(int amount, int goal) {
    return '$amount / $goal ml';
  }

  @override
  String get waterGoalReached => 'Daily water goal reached!';

  @override
  String get waterSetGoal => 'Daily water goal';

  @override
  String get waterUndo => 'Remove 250 ml';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsWorkouts => 'Workouts';

  @override
  String get statsVolume => 'Volume';

  @override
  String get statsStreak => 'Day streak';

  @override
  String get statsTotal => 'Total sessions';

  @override
  String academyLessonsCount(int count) {
    return '$count lessons';
  }

  @override
  String get calculatorBmrTdee => 'BMR & TDEE';

  @override
  String get portionScaler => 'Portion scaler';

  @override
  String get workoutsNoActive => 'No active workout session.';

  @override
  String get workoutsElapsed => 'Elapsed';

  @override
  String get workoutsPrevious => 'Last time';

  @override
  String get workoutsRest => 'Rest';

  @override
  String get workoutsSkip => 'Skip';

  @override
  String get workoutsNewPR => 'New personal record! 🏆';

  @override
  String get workoutsDeleteSet => 'Delete set';

  @override
  String get workoutsRestDone => 'Rest is over — next set!';

  @override
  String get workoutsQuickStart => 'Quick workout';

  @override
  String get workoutsQuickStartDesc =>
      'Start empty and add exercises as you go';

  @override
  String get workoutsEmptySession =>
      'Add your first exercise to start logging sets.';

  @override
  String get workoutsStart => 'Start';

  @override
  String workoutsExercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String get workoutsNoProgramsYet => 'No programs created yet.';

  @override
  String get workoutsSearchExercise => 'Search exercises';

  @override
  String get sessionDetailTitle => 'Workout summary';

  @override
  String get sessionDelete => 'Delete workout';

  @override
  String get sessionDeleteConfirm =>
      'Delete this workout from your history? This cannot be undone.';

  @override
  String sessionMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get progressRecentLogs => 'Recent logs';

  @override
  String get progressNoPRs =>
      'Complete workout sets to establish your personal strength records!';

  @override
  String get progressEst1RM => 'Est. 1RM';

  @override
  String get progressCurrent => 'Current';

  @override
  String get progressChange => 'Change';

  @override
  String get progressBmi => 'BMI';

  @override
  String progressSetFormat(String weight, int reps) {
    return '$weight kg × $reps';
  }

  @override
  String get toolsTitle => 'Gym tools';

  @override
  String get tools1RM => '1RM calculator';

  @override
  String get tools1RMDesc => 'Estimate your max and training loads';

  @override
  String get toolsPlates => 'Plate calculator';

  @override
  String get toolsPlatesDesc => 'Which plates to load on each side';

  @override
  String get toolsWeightKg => 'Weight (kg)';

  @override
  String get toolsReps => 'Reps';

  @override
  String get toolsTargetKg => 'Target weight (kg)';

  @override
  String get toolsBarKg => 'Bar (kg)';

  @override
  String get toolsPerSide => 'Per side';

  @override
  String toolsRemainder(String kg) {
    return 'Can\'t load exactly — $kg kg short';
  }

  @override
  String get toolsOnlyBar => 'Just the empty bar';

  @override
  String get toolsPercentOf1RM => '% of 1RM';

  @override
  String get nutritionMealEmpty => 'Nothing logged yet — tap + to add food';

  @override
  String get nutritionMacros => 'Macros';

  @override
  String get mealsCopyYesterdayHint =>
      'Nothing logged this day. Copy yesterday\'s meals?';

  @override
  String get mealsCopy => 'Copy';

  @override
  String mealsCopied(int count) {
    return '$count items copied';
  }

  @override
  String get mealsNothingToCopy => 'Nothing to copy';

  @override
  String get mealsCopyFromYesterday => 'Copy from yesterday';

  @override
  String get mealsUseTemplate => 'Add from template';

  @override
  String get mealsSaveTemplate => 'Save as template';

  @override
  String get mealsTemplateName => 'Template name';

  @override
  String get mealsTemplateSaved => 'Template saved';

  @override
  String get mealsTemplates => 'Meal templates';

  @override
  String get mealsNoTemplates =>
      'No templates yet. Open a meal menu (⋮) and choose \"Save as template\".';

  @override
  String get setsSuperset => 'Superset';

  @override
  String get setsSupersetWithNext => 'Superset with next exercise';

  @override
  String get setsRemoveSuperset => 'Remove superset';

  @override
  String get setTypeTitle => 'Set type';

  @override
  String get setTypeNormal => 'Normal';

  @override
  String get setTypeWarmup => 'Warm-up';

  @override
  String get setTypeDrop => 'Drop set';

  @override
  String get setTypeFailure => 'To failure';

  @override
  String get rpeHelp =>
      'RPE = how hard the set felt. 10 = no reps left, 8 = 2 reps left in the tank. Warm-up sets don\'t count toward volume or records.';

  @override
  String get commonClear => 'Clear';

  @override
  String overloadIncrease(String kg) {
    return 'Add $kg kg today';
  }

  @override
  String get overloadKeep => 'Same weight — beat your reps';

  @override
  String overloadDeload(String kg) {
    return 'Deload to $kg kg';
  }

  @override
  String get exerciseProgress => 'Exercise progress';

  @override
  String get exerciseTopWeight => 'Top weight';

  @override
  String get exerciseNoHistory =>
      'No completed sets for this exercise yet. Finish a workout with it to see your progress chart.';

  @override
  String get heatmapTitle => 'Muscles this week';

  @override
  String get heatmapHelp =>
      'Working sets in the last 7 days. 10–20 sets per muscle per week is the sweet spot for growth (green). Orange = very high volume.';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleLegs => 'Legs';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleArms => 'Arms';

  @override
  String get muscleCore => 'Core';

  @override
  String get achTitle => 'Achievements';

  @override
  String get achSubtitle =>
      'Earn badges by training consistently, eating well and hitting new records.';

  @override
  String get achNext => 'Next';

  @override
  String get achUnlocked => 'Achievement unlocked';

  @override
  String get achFirstWorkout => 'First step';

  @override
  String get achFirstWorkoutDesc => 'Complete your first workout.';

  @override
  String get achWorkouts10 => 'Regular';

  @override
  String get achWorkouts50 => 'Dedicated';

  @override
  String get achWorkouts100 => 'Iron legend';

  @override
  String achWorkoutsDesc(int count) {
    return 'Complete $count workouts.';
  }

  @override
  String get achStreak3 => 'On fire';

  @override
  String get achStreak7 => 'Unstoppable week';

  @override
  String get achStreak30 => 'Machine';

  @override
  String achStreakDesc(int count) {
    return 'Train $count days in a row.';
  }

  @override
  String get achFirstPr => 'Record breaker';

  @override
  String get achFirstPrDesc => 'Set your first personal record.';

  @override
  String get achPrs25 => 'PR hunter';

  @override
  String achPrsDesc(int count) {
    return 'Set $count personal records.';
  }

  @override
  String get achFood7 => 'Mindful eater';

  @override
  String get achFood30 => 'Nutrition pro';

  @override
  String achFoodDesc(int count) {
    return 'Log your food on $count different days.';
  }

  @override
  String get achWater7 => 'Hydrated';

  @override
  String achWaterDesc(int count) {
    return 'Reach your water goal on $count days.';
  }

  @override
  String get achWeigh10 => 'Tracker';

  @override
  String achWeighDesc(int count) {
    return 'Log your weight $count times.';
  }

  @override
  String get achVolume10t => '10 tonnes';

  @override
  String get achVolume100t => '100 tonnes';

  @override
  String achVolumeDesc(String tonnes) {
    return 'Lift $tonnes tonnes of total volume.';
  }

  @override
  String get measureTitle => 'Body measurements';

  @override
  String get measureMore => 'More measurements (optional)';

  @override
  String get measureChest => 'Chest';

  @override
  String get measureArm => 'Arm';

  @override
  String get measureThigh => 'Thigh';

  @override
  String get measureHips => 'Hips';

  @override
  String get measureBodyFat => 'Body fat';

  @override
  String get measureSaved => 'Measurement saved';

  @override
  String get profileFeatures => 'Tools & sync';

  @override
  String get scanTitle => 'Scan barcode';

  @override
  String get scanHint => 'Point the camera at a product barcode';

  @override
  String scanLooking(String code) {
    return 'Looking up $code…';
  }

  @override
  String get scanOffline =>
      'No internet — product lookup needs a connection the first time.';

  @override
  String get scanNotFound => 'Product not found';

  @override
  String scanNotFoundBody(String code) {
    return 'Barcode $code is not in the database yet. You can add it as a custom food.';
  }

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanCameraError =>
      'Camera unavailable. Allow camera access in the phone settings.';

  @override
  String get remTitle => 'Reminders';

  @override
  String get remSubtitle =>
      'Smart reminders that work even when the app is closed.';

  @override
  String get remWaterTitle => 'Drink water';

  @override
  String get remWaterBody => 'Time for a glass of water 💧';

  @override
  String get remMealTitle => 'Log your meal';

  @override
  String get remWorkoutTitle => 'Workout time';

  @override
  String get remWorkoutBody => 'Let\'s train today 💪';

  @override
  String get remWeighTitle => 'Morning weigh-in';

  @override
  String get remWeighBody =>
      'Weigh yourself before breakfast for the most accurate trend.';

  @override
  String get remEvery => 'Every';

  @override
  String remHours(int h) {
    return '$h h';
  }

  @override
  String get remFromTo => 'From – to';

  @override
  String get remTime => 'Time';

  @override
  String get remPermissionDenied =>
      'Notifications are blocked. Allow them in the phone settings.';

  @override
  String get remWatchInfo =>
      'The rest timer appears as a live countdown notification. If your watch (Wear OS, Galaxy Watch, Mi Band…) shows phone notifications, it shows the timer and vibrates when rest ends.';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupSubtitle =>
      'Save all your data to one file (send it to Google Drive, Telegram, email…) and restore it on any phone.';

  @override
  String get backupExport => 'Create backup';

  @override
  String get backupExportDesc =>
      'Exports a .json file and opens the share menu';

  @override
  String get backupRestore => 'Restore backup';

  @override
  String get backupRestoreDesc =>
      'Pick a backup file — replaces the data on this phone';

  @override
  String get backupRestoreConfirm =>
      'All current data on this phone will be replaced by the backup. Continue?';

  @override
  String get backupRestored => 'Backup restored ✓';

  @override
  String get backupInvalid => 'This file is not a Fit Companion backup.';

  @override
  String get backupPhotosNote =>
      'Note: progress photos stay on the phone and are not included in the backup file.';

  @override
  String get photosTitle => 'Progress photos';

  @override
  String get photosAdd => 'Add photo';

  @override
  String get photosCamera => 'Take a photo';

  @override
  String get photosGallery => 'Choose from gallery';

  @override
  String get photosFront => 'Front';

  @override
  String get photosSide => 'Side';

  @override
  String get photosBack => 'Back';

  @override
  String get photosCompare => 'Before / after';

  @override
  String get photosBefore => 'Before';

  @override
  String get photosAfter => 'After';

  @override
  String get photosEmpty =>
      'Take a photo every 2–4 weeks in the same light and pose to see your real change.';

  @override
  String get photosPrivacy =>
      '🔒 Photos are private and stored only on this phone. They leave it only if you ask for an AI analysis (you confirm each time).';

  @override
  String get photosDelete => 'Delete this photo?';

  @override
  String get healthTitle => 'Health Connect';

  @override
  String get healthSubtitle =>
      'Connect Android\'s Health Connect to read your daily steps and save your weight there automatically.';

  @override
  String get healthUnavailable =>
      'Health Connect is not available on this phone (needs Android 9+ and not a work profile).';

  @override
  String get healthNeedsInstall =>
      'Install or update the Health Connect app from Google Play first.';

  @override
  String get healthInstall => 'Open Google Play';

  @override
  String get healthConnected => 'Connected';

  @override
  String get healthNotConnected => 'Not connected';

  @override
  String get healthWhat => 'Reads: steps • Writes: body weight';

  @override
  String get healthConnect => 'Connect Health Connect';

  @override
  String get healthStepsToday => 'Steps today';

  @override
  String get cloudTitle => 'Cloud sync';

  @override
  String get coachTitle => 'AI coach';

  @override
  String get cloudSubtitle =>
      'Keep your data safe in the cloud and move it between phones. Free, with your own account.';

  @override
  String get cloudUnavailable =>
      'Cloud is unavailable right now (no internet at app start). Restart the app with internet.';

  @override
  String get cloudSignIn => 'Sign in';

  @override
  String get cloudCreateAccount => 'Create account';

  @override
  String get cloudEmail => 'Email';

  @override
  String get cloudPassword => 'Password (6+ characters)';

  @override
  String get cloudInvalidForm =>
      'Enter a valid email and a password of at least 6 characters.';

  @override
  String get cloudConfirmEmail =>
      'Account created. Check your email to confirm it, then sign in.';

  @override
  String get cloudSignedIn => 'Signed in ✓';

  @override
  String get cloudSignOut => 'Sign out';

  @override
  String get cloudLastSync => 'Last sync';

  @override
  String get cloudCloudCopy => 'Cloud copy';

  @override
  String get cloudRemoteNewer =>
      'The cloud copy is newer than this phone (uploaded from another device). Download it, or upload to replace it.';

  @override
  String get cloudUpload => 'Upload';

  @override
  String get cloudDownload => 'Download';

  @override
  String get cloudUploadOverwrite =>
      'This replaces the newer cloud copy with this phone\'s data. Continue?';

  @override
  String get cloudDownloadOverwrite =>
      'This replaces ALL data on this phone with the cloud copy. Continue?';

  @override
  String get cloudUploaded => 'Uploaded to the cloud ✓';

  @override
  String get cloudDownloaded => 'Cloud data restored ✓';

  @override
  String get cloudAuto => 'Automatic backup';

  @override
  String get cloudAutoDesc =>
      'Uploads when you leave the app (never overwrites a newer cloud copy).';

  @override
  String get cloudPrivacy =>
      '🔒 Each account can only read its own data (Row Level Security). Progress photos are never uploaded. Free projects pause after ~1 week without use and wake up on the next sync.';

  @override
  String get coachTagline => 'Personal advice from your own data';

  @override
  String get coachIntro =>
      'Ask anything about training, nutrition or your progress. The coach sees a short summary of your data (averages, goals, best lifts) — never your raw logs. It is not a doctor.';

  @override
  String get coachHint => 'Ask your coach…';

  @override
  String get coachClear => 'Clear conversation';

  @override
  String get coachNeedsAccount =>
      'The AI coach needs a free cloud account (your conversation is saved there).';

  @override
  String get coachSuggest1 => 'Analyse my last week';

  @override
  String get coachSuggest2 => 'How much protein do I need?';

  @override
  String get coachSuggest3 => 'Why isn\'t my weight moving?';

  @override
  String get coachSuggest4 => 'Suggest an Algerian high-protein dinner';

  @override
  String get coachErrNoKey =>
      'The coach is not configured yet: the Gemini API key must be added in Supabase (Edge Functions → Secrets → GEMINI_API_KEY).';

  @override
  String get coachErrLimit =>
      'Daily limit reached (40 messages). Try again tomorrow.';

  @override
  String get coachErrQuota =>
      'The free Gemini quota is used up for now. Try again later.';

  @override
  String get coachErrGeneric => 'The coach could not answer. Try again.';

  @override
  String get coachErrNetwork =>
      'No connection to the coach. Check your internet.';

  @override
  String get coachErrModel =>
      'The AI model name is not available. Set GEMINI_MODEL in Supabase secrets (e.g. gemini-3.8-flash).';

  @override
  String get coachErrBusy =>
      'The AI servers are busy right now. Wait a few seconds and try again.';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get equipBarbell => 'Barbell';

  @override
  String get equipDumbbell => 'Dumbbell';

  @override
  String get equipMachine => 'Machine';

  @override
  String get equipCable => 'Cable';

  @override
  String get equipBodyweight => 'Bodyweight';

  @override
  String get equipKettlebell => 'Kettlebell';

  @override
  String get equipOther => 'Other';

  @override
  String get exerciseCreateCustom => 'Add my exercise';

  @override
  String get exerciseCreateCustomHint => 'Can\'t find it? Create it in seconds';

  @override
  String get exerciseNotFound =>
      'No exercise found. Use \"Add my exercise\" above.';

  @override
  String get exerciseName => 'Exercise name';

  @override
  String get exerciseCompound => 'Compound';

  @override
  String get exerciseIsolation => 'Isolation';

  @override
  String get exerciseNotesOptional => 'Notes / how to do it (optional)';

  @override
  String get exerciseCreated => 'Exercise added ✓';

  @override
  String get programEdit => 'Edit program';

  @override
  String get programNameRequired => 'Give your program a name';

  @override
  String get programNeedsExercise => 'Add at least one exercise';

  @override
  String get programSaved => 'Program saved ✓';

  @override
  String get programNameHint => 'e.g. Upper A, Lower B, Arms & Abs';

  @override
  String get programReorderHint => 'Drag ⋮⋮ to reorder';

  @override
  String get programEmptyHint =>
      'No exercises yet. Tap \"Add exercise\" to build your workout.';

  @override
  String get programDeleteConfirm =>
      'Delete this program? Your workout history is kept.';

  @override
  String get programsEmptyTitle => 'Build your own split';

  @override
  String get programsEmptyBody =>
      'Create one program per training day, e.g. \"Upper A\", \"Lower A\", \"Upper B\", \"Lower B\", \"Arms & Abs\". Add only the exercises you want.';

  @override
  String get templatesTitle => 'Ready-made programs';

  @override
  String get templatesSubtitle =>
      'PPL, Upper/Lower, Full Body, 5/3/1 — copy one and customise it';

  @override
  String get templateUse => 'Add to my programs & edit';

  @override
  String get templateCopied => 'Copied to your programs — customise it';

  @override
  String get templateBadge => 'Template';

  @override
  String get foodsMine => 'My foods';

  @override
  String get foodsSuggestions => 'Suggestions';

  @override
  String get foodsAddMine => 'Add my food';

  @override
  String get foodsMineEmptyTitle => 'Your food list is empty';

  @override
  String get foodsMineEmptyBody =>
      'Add what you really eat: write the name, a short description and the weight — AI calculates calories, protein, carbs and fat for you. Ready-made foods are in \"Suggestions\".';

  @override
  String get foodsDeleteConfirm =>
      'Delete this food from your list? Past logs are kept.';

  @override
  String get myFoodName => 'Food name';

  @override
  String get myFoodNameHint => 'e.g. Chicken couscous';

  @override
  String get myFoodDescription =>
      'Description (ingredients, how it was cooked)';

  @override
  String get myFoodDescriptionHint =>
      'e.g. 150 g cooked couscous, 120 g chicken breast, vegetables, 1 tbsp olive oil';

  @override
  String get myFoodWeight => 'Weight of the portion';

  @override
  String get myFoodAnalyze => 'Calculate with AI';

  @override
  String get myFoodAnalyzing => 'Analysing…';

  @override
  String get myFoodNeedNameWeight => 'Enter the food name and its weight.';

  @override
  String get myFoodNeedValues =>
      'Calculate with AI or enter the calories manually.';

  @override
  String get myFoodNeedAccount =>
      'AI calculation needs a free account (My account → Cloud sync). You can also type the values yourself.';

  @override
  String get myFoodConfHigh => 'High accuracy';

  @override
  String get myFoodConfMedium => 'Medium accuracy';

  @override
  String get myFoodConfLow => 'Low accuracy — add details';

  @override
  String get myFoodPer100 => 'Per 100 g';

  @override
  String myFoodPortionValues(String grams) {
    return 'Values for $grams g';
  }

  @override
  String get myFoodEditHint =>
      'You can correct any value before saving. The more details in the description, the more accurate the result.';

  @override
  String get myFoodLogNow => 'Add it to today\'s meals';

  @override
  String get myFoodSaveAndLog => 'Save & add to meal';

  @override
  String get myFoodSaved => 'Food saved to your list ✓';

  @override
  String get myFoodSavedLogged => 'Food saved and added ✓';

  @override
  String get eatenQuestion => 'Did you eat it?';

  @override
  String get eatenYes => 'Yes — counts in today\'s totals';

  @override
  String get eatenPlanned => 'Not yet — saved as planned';

  @override
  String get eatenAtTime => 'Eaten at';

  @override
  String get eatenMark => 'Mark as eaten';

  @override
  String get eatenUndo => 'Mark as not eaten';

  @override
  String get eatenWhen => 'When did you eat it?';

  @override
  String get eatenAtShort => 'Eaten at';

  @override
  String get eatenPlannedShort => 'Planned — tap ○ when you eat it';

  @override
  String eatenPlannedKcal(int kcal) {
    return '$kcal kcal planned, not eaten yet';
  }

  @override
  String get themesTitle => 'Themes & appearance';

  @override
  String get themesColors => 'Colour themes';

  @override
  String get themesBackground => 'Animated background';

  @override
  String get themesAnimated => 'Animated background';

  @override
  String get themesAnimatedDesc =>
      'Smooth moving background behind every screen';

  @override
  String get themesInteractive => 'React to touch';

  @override
  String get themesInteractiveDesc =>
      'Ripples, glow and particles follow your finger';

  @override
  String get themesIntensity => 'Intensity';

  @override
  String get themesEffect => 'Effect';

  @override
  String get themesBatteryNote =>
      'The animation runs at 30 fps, pauses when the app is in the background and turns off automatically if \"Remove animations\" is enabled in Android accessibility settings.';

  @override
  String get fxAuto => 'Theme default';

  @override
  String get fxNone => 'None';

  @override
  String get fxOrbs => 'Glow orbs';

  @override
  String get fxParticles => 'Particles';

  @override
  String get fxWaves => 'Waves';

  @override
  String get fxGrid => 'Neon grid';

  @override
  String get fxAurora => 'Aurora';

  @override
  String get fxBokeh => 'Bokeh';

  @override
  String get fxStars => 'Stars';

  @override
  String get shapeSharp => 'Sharp corners';

  @override
  String get shapeSoft => 'Soft corners';

  @override
  String get shapeRounded => 'Rounded';

  @override
  String get shapePill => 'Pill shapes';

  @override
  String get aboutDevelopedBy => 'Developed by';

  @override
  String get aboutDeveloperName => 'Mahdi Hafiane';

  @override
  String scanAiEstimating(String name) {
    return 'Found \"$name\" — AI is calculating its nutrition…';
  }

  @override
  String scanNotFoundAi(String code) {
    return 'Barcode $code is not in the online database. Take a photo of the package (ideally the nutrition table) and AI will read the product name and its values.';
  }

  @override
  String get scanPhotoLabel => 'Photo of product';

  @override
  String get scanManual => 'Enter manually';

  @override
  String get scanReadingLabel => 'AI is reading the product…';

  @override
  String get photoTitle => 'Meal photo (AI)';

  @override
  String get photoHint =>
      'Take a photo of your plate, meal or product: AI identifies the foods and calculates calories, protein, carbs and fat.';

  @override
  String get photoAnalyzing => 'Analysing…';

  @override
  String get photoNote => 'Note for the AI (optional)';

  @override
  String get photoNoteHint => 'e.g. fried in olive oil, 2 eggs, big portion';

  @override
  String get photoNotFood =>
      'No food detected in this photo. Try another angle with the whole plate visible.';

  @override
  String get photoResults => 'Detected foods';

  @override
  String get photoSuggestions => 'To make it better';

  @override
  String photoLogged(int count) {
    return '$count items added to your meal ✓';
  }

  @override
  String get coachAttach => 'Send photo or video';

  @override
  String get coachTakePhoto => 'Take a photo';

  @override
  String get coachPickPhoto => 'Photo from gallery';

  @override
  String get coachRecordVideo => 'Record a video (max 60 s)';

  @override
  String get coachPickVideo => 'Video from gallery';

  @override
  String get coachPhotoAttached => 'Photo attached';

  @override
  String get coachVideoAttached => 'Video';

  @override
  String get coachUploading => 'Uploading…';

  @override
  String get coachAnalyzingVideo =>
      'Analysing the video (can take up to a minute)…';

  @override
  String get coachErrMediaBig =>
      'File too large (max 40 MB). Send a shorter video.';

  @override
  String get coachErrUpload =>
      'Upload failed. Check your internet and try again.';

  @override
  String get coachErrMediaType =>
      'This file type could not be analysed. Try another photo or an MP4 video.';

  @override
  String get photosDate => 'Date of the photo';

  @override
  String get photosLastWeek => 'Last week';

  @override
  String get photos2Weeks => '2 weeks ago';

  @override
  String get photosLastMonth => 'Last month';

  @override
  String get photosPose => 'Pose';

  @override
  String get photosNeedTwo =>
      'Add at least 2 photos in the same pose to compare them and get an AI analysis.';

  @override
  String photosDaysApart(int days) {
    return '$days days between the photos';
  }

  @override
  String get photosAiAnalyze => 'Analyse my progress with AI';

  @override
  String get photosAiConsentTitle => 'Send these 2 photos for analysis?';

  @override
  String get photosAiConsent =>
      'Your photos are private and stay on this phone. For this analysis only, the 2 selected photos are sent securely to Google Gemini (via your account). They are not saved on our server.';

  @override
  String get photosHomeEmpty =>
      'Add body photos to see your real transformation';

  @override
  String photosHomeLast(int days) {
    return 'Last photo $days days ago';
  }

  @override
  String get photosHomeCompare =>
      'Compare before / after and get an AI progress analysis';

  @override
  String get aiProgressTitle => 'AI progress analysis';

  @override
  String get aiMuscle => 'Muscle gain';

  @override
  String get aiFat => 'Body fat';

  @override
  String get aiGainClear => 'clear';

  @override
  String get aiGainSlight => 'slight';

  @override
  String get aiGainNone => 'not visible';

  @override
  String get aiUnclear => 'unclear';

  @override
  String get aiFatLess => 'lower';

  @override
  String get aiFatSame => 'same';

  @override
  String get aiFatMore => 'higher';

  @override
  String get aiNotComparable =>
      'The photos are hard to compare (different light, pose or distance).';

  @override
  String get aiAreas => 'By muscle group';

  @override
  String get aiTips => 'How to progress faster';

  @override
  String get profileAthlete => 'Athlete';

  @override
  String profileYears(int age) {
    return '$age y';
  }

  @override
  String get profilePreferences => 'App preferences';

  @override
  String get tdeeTitle => 'Your real maintenance calories';

  @override
  String get tdeeNeedData =>
      'Log your meals and weigh in for ~2 weeks and the app will calculate your real TDEE.';

  @override
  String get tdeePerDay => 'kcal / day';

  @override
  String tdeeExplain(int avg, String change, int days) {
    return 'You ate $avg kcal on average and your weight changed $change kg/week ($days days logged).';
  }

  @override
  String tdeeSuggest(int target, int current) {
    return 'Suggested target: $target kcal (now $current)';
  }

  @override
  String get tdeeApply => 'Apply';

  @override
  String get tdeeApplied => 'Calorie target updated';

  @override
  String get tdeeOnTrack => 'Your calorie target matches your real TDEE';

  @override
  String get fatigueFresh => 'Recovery looks good';

  @override
  String get fatigueFreshBody =>
      'Your strength is stable or rising. Keep pushing!';

  @override
  String get fatigueWatch => 'Watch your recovery';

  @override
  String get fatigueWatchBody =>
      'Some fatigue signs. Sleep well, eat enough and don\'t add volume this week.';

  @override
  String get fatigueDeload => 'Time for a deload week';

  @override
  String get fatigueDeloadBody =>
      'Cut weights by ~40% and sets by half for one week, then come back stronger.';

  @override
  String fatigueReasonDeclining(int n) {
    return '$n exercises got weaker 2 sessions in a row';
  }

  @override
  String get fatigueReasonRpe =>
      'Very high effort (RPE ≥ 9) in the last 2 weeks';

  @override
  String fatigueReasonWeeks(int weeks) {
    return '$weeks hard weeks in a row without a break';
  }

  @override
  String get noteSkipped => 'You skipped a set — go back and finish it?';

  @override
  String get noteWeightDropping =>
      'Your top weight dropped 2 sessions in a row. Rest well before this one.';

  @override
  String get noteMissedReps =>
      'Last time you missed the target reps. Keep the same weight today.';

  @override
  String noteCloseToPr(String kg) {
    return 'Only $kg kg from your record — go for it! 🏆';
  }

  @override
  String get chTitle => 'Challenges & levels';

  @override
  String get chWeekly => 'This week';

  @override
  String get chMonthly => 'This month';

  @override
  String chWorkouts(int n) {
    return 'Complete $n workouts';
  }

  @override
  String chProtein(int n) {
    return 'Hit your protein goal $n days';
  }

  @override
  String chWater(int n) {
    return 'Reach your water goal $n days';
  }

  @override
  String chLog(int n) {
    return 'Log your food $n days';
  }

  @override
  String chPrs(int n) {
    return 'Break $n personal records';
  }

  @override
  String chVolume(String t) {
    return 'Lift $t tonnes in total';
  }

  @override
  String chWeigh(int n) {
    return 'Weigh in $n times';
  }

  @override
  String get chDone => 'Completed';

  @override
  String chDaysLeft(int n) {
    return '$n days left';
  }

  @override
  String get chCompleted => 'Challenge completed';

  @override
  String xpToNext(int xp, int level) {
    return '$xp XP to level $level';
  }

  @override
  String get xpHowTitle => 'Where your XP comes from';

  @override
  String get xpWorkouts => 'Workouts (50 each)';

  @override
  String get xpPrs => 'Personal records (30 each)';

  @override
  String get xpFood => 'Days with food logged (10)';

  @override
  String get xpWater => 'Water goal days (10)';

  @override
  String get xpWeigh => 'Weigh-ins (5)';

  @override
  String get xpChallenges => 'Challenges';

  @override
  String get lvlBeginner => 'Beginner';

  @override
  String get lvlRookie => 'Rookie';

  @override
  String get lvlAthlete => 'Athlete';

  @override
  String get lvlWarrior => 'Warrior';

  @override
  String get lvlBeast => 'Beast';

  @override
  String get lvlLegend => 'Legend';

  @override
  String get aiToolsTitle => 'AI tools';

  @override
  String get aiSignIn => 'Sign in';

  @override
  String get aiGenerate => 'Generate';

  @override
  String get aiRegenerate => 'Generate again';

  @override
  String get aiThinking => 'The AI is working on it… (up to a minute)';

  @override
  String get aiKcal => 'kcal';

  @override
  String get aiReportTitle => 'Weekly AI report';

  @override
  String get aiReportIntro =>
      'A coach-style review of your week: training, food, weight, sleep, with goals for next week.';

  @override
  String get aiReportRemind => 'Remind me every Friday evening';

  @override
  String get aiReportNotifTitle => 'Your weekly report is ready 📊';

  @override
  String get aiReportNotifBody =>
      'Open Fit Companion to see how your week went.';

  @override
  String get aiWins => 'What went well';

  @override
  String get aiImprove => 'To improve';

  @override
  String get aiNextWeek => 'Goals for next week';

  @override
  String get aiProgramTitle => 'AI program builder';

  @override
  String aiProgramDays(int n) {
    return '$n training days per week';
  }

  @override
  String get aiProgramGoal => 'Goal';

  @override
  String get aiProgramEquipment => 'Available equipment';

  @override
  String get aiProgramNotes => 'Notes (optional)';

  @override
  String get aiProgramNotesHint => 'e.g. knee pain, 45 min max, focus on arms';

  @override
  String get aiProgramSave => 'Save to my programs';

  @override
  String get aiProgramSaved => 'Program saved to your workouts';

  @override
  String get aiGoalStrength => 'Strength';

  @override
  String get aiGoalMuscle => 'Muscle';

  @override
  String get aiGoalFatLoss => 'Fat loss';

  @override
  String get aiGoalEndurance => 'Endurance';

  @override
  String get aiEqBarbell => 'Barbell';

  @override
  String get aiEqDumbbell => 'Dumbbells';

  @override
  String get aiEqCable => 'Cables';

  @override
  String get aiEqMachine => 'Machines';

  @override
  String get aiEqBodyweight => 'Bodyweight';

  @override
  String get aiMealTitle => 'AI meal plan';

  @override
  String get aiMealIntro =>
      'A full day of meals that hits your calories and macros, with local foods and a shopping list.';

  @override
  String get aiMealRequest => 'Preferences (optional)';

  @override
  String get aiMealRequestHint =>
      'e.g. cheap, no fish, 4 meals, I work until 17:00';

  @override
  String get aiMealAdd => 'Add to today';

  @override
  String get aiMealAddedShort => 'Added';

  @override
  String get aiMealAdded =>
      'Added to today as planned (tick it when you eat it)';

  @override
  String get aiShopping => 'Shopping list';

  @override
  String get aiVoiceTitle => 'Log food by voice';

  @override
  String get aiVoiceHint =>
      'Say what you ate, e.g. \"two eggs, a piece of kesra and a coffee with milk\". Darija, Arabic, French or English.';

  @override
  String get aiVoiceTap => 'Tap to record';

  @override
  String get aiVoiceListening => 'Listening… tap to stop';

  @override
  String get aiVoiceNoMic => 'Microphone permission is needed';

  @override
  String get aiVoiceNothing => 'No food was recognised. Try again.';

  @override
  String aiVoiceLog(int n) {
    return 'Log $n items';
  }

  @override
  String aiVoiceLogged(int n) {
    return '$n items logged';
  }

  @override
  String get shareAction => 'Share';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsSubtitle => 'Weekly leaderboard with your friends';

  @override
  String get friendsNeedAccount =>
      'Sign in to your cloud account to add friends and compare progress.';

  @override
  String get friendsRetry => 'Retry';

  @override
  String get friendsMyCode => 'My friend code';

  @override
  String get friendsMyCodeHint => 'Share it — only friends see your stats';

  @override
  String get friendsCopy => 'Copy';

  @override
  String get friendsCopied => 'Code copied';

  @override
  String friendsInvite(String code) {
    return 'Train with me on Fit Companion! My friend code: $code';
  }

  @override
  String get friendsAdd => 'Add friend';

  @override
  String get friendsCode => 'Friend code';

  @override
  String friendsAdded(String name) {
    return '$name added';
  }

  @override
  String get friendsCodeNotFound => 'No user with this code';

  @override
  String get friendsOwnCode => 'This is your own code';

  @override
  String get friendsRemove => 'Remove friend';

  @override
  String friendsRemoveConfirm(String name) {
    return 'Remove $name from your friends?';
  }

  @override
  String get friendsRemoveHint => 'Long-press a friend to remove them';

  @override
  String get friendsSortVolume => 'Volume';

  @override
  String get friendsSortWorkouts => 'Workouts';

  @override
  String get friendsEmpty =>
      'No friends yet. Share your code to start competing!';

  @override
  String get friendsYou => 'you';

  @override
  String friendsLevel(int level) {
    return 'Level $level';
  }

  @override
  String get sleepTitle => 'Sleep & performance';

  @override
  String get sleepConnect =>
      'Connect Health Connect to read your sleep (from your watch or sleep app) and see how it affects your workouts.';

  @override
  String get sleepConnectButton => 'Connect sleep data';

  @override
  String sleepAvg(String hours, int nights) {
    return 'Average $hours h per night ($nights nights this week)';
  }

  @override
  String get sleepNeedMore =>
      'Train more on tracked nights to see the effect on your performance.';

  @override
  String sleepBetter(String pct) {
    return 'You lift $pct% more volume after 7 h+ of sleep';
  }

  @override
  String get sleepNoEffect =>
      'No clear effect of short nights on your volume yet';

  @override
  String get sleepTip => 'Aim for 7–9 h: muscle is built while you sleep.';

  @override
  String get exerciseWatchHow => 'Watch how';

  @override
  String get exerciseVideoError => 'Could not open the video';

  @override
  String get exerciseOpenYoutube => 'Open in YouTube';

  @override
  String get exerciseAnotherVideo => 'Another video';

  @override
  String get exerciseVideoSignIn =>
      'Sign in once to load the demo video inside the app.';

  @override
  String get exerciseVideoUnavailable =>
      'The demo video isn\'t available right now.';
}
