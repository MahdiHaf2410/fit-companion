import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fit Companion'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get navNutrition;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Overview'**
  String get dashboardTitle;

  /// No description provided for @dashboardNutritionCard.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutrition'**
  String get dashboardNutritionCard;

  /// No description provided for @dashboardCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get dashboardCalories;

  /// No description provided for @dashboardCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {target} kcal'**
  String dashboardCalorieTarget(int target);

  /// No description provided for @dashboardConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get dashboardConsumed;

  /// No description provided for @dashboardRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get dashboardRemaining;

  /// No description provided for @dashboardOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Over by'**
  String get dashboardOverLimit;

  /// No description provided for @dashboardProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dashboardProtein;

  /// No description provided for @dashboardCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get dashboardCarbs;

  /// No description provided for @dashboardFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get dashboardFat;

  /// No description provided for @dashboardGrams.
  ///
  /// In en, this message translates to:
  /// **'{amount}g / {target}g'**
  String dashboardGrams(String amount, String target);

  /// No description provided for @dashboardTodayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get dashboardTodayWorkout;

  /// No description provided for @dashboardNoWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'No workout scheduled for today'**
  String get dashboardNoWorkoutToday;

  /// No description provided for @dashboardStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get dashboardStartWorkout;

  /// No description provided for @dashboardResumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get dashboardResumeWorkout;

  /// No description provided for @dashboardWorkoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout Completed!'**
  String get dashboardWorkoutCompleted;

  /// No description provided for @dashboardBodyProgress.
  ///
  /// In en, this message translates to:
  /// **'Body Progress'**
  String get dashboardBodyProgress;

  /// No description provided for @dashboardLatestWeight.
  ///
  /// In en, this message translates to:
  /// **'Latest Weight: {weight} kg'**
  String dashboardLatestWeight(String weight);

  /// No description provided for @dashboardNoWeightYet.
  ///
  /// In en, this message translates to:
  /// **'No weight recorded yet'**
  String get dashboardNoWeightYet;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardActionAddFood.
  ///
  /// In en, this message translates to:
  /// **'Log Food'**
  String get dashboardActionAddFood;

  /// No description provided for @dashboardActionStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get dashboardActionStartWorkout;

  /// No description provided for @dashboardActionLogWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get dashboardActionLogWeight;

  /// No description provided for @dashboardActionBuildRecipe.
  ///
  /// In en, this message translates to:
  /// **'New Recipe'**
  String get dashboardActionBuildRecipe;

  /// No description provided for @dashboardEstimatedTarget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Daily Target: {target} kcal'**
  String dashboardEstimatedTarget(int target);

  /// No description provided for @dashboardCalculatorCard.
  ///
  /// In en, this message translates to:
  /// **'Personal Energy Calculator'**
  String get dashboardCalculatorCard;

  /// No description provided for @dashboardCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate evidence-based calories and macros with Mifflin–St Jeor.'**
  String get dashboardCalculatorDesc;

  /// No description provided for @dashboardAcademyCard.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Academy'**
  String get dashboardAcademyCard;

  /// No description provided for @dashboardAcademyDesc.
  ///
  /// In en, this message translates to:
  /// **'14 practical lessons with quizzes and interactive tools.'**
  String get dashboardAcademyDesc;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fit Companion'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your offline personal fitness and nutrition companion'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingName.
  ///
  /// In en, this message translates to:
  /// **'Display Name (Optional)'**
  String get onboardingName;

  /// No description provided for @onboardingAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAge;

  /// No description provided for @onboardingSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get onboardingSex;

  /// No description provided for @onboardingSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingSexMale;

  /// No description provided for @onboardingSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingSexFemale;

  /// No description provided for @onboardingHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get onboardingHeight;

  /// No description provided for @onboardingWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get onboardingWeight;

  /// No description provided for @onboardingActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get onboardingActivity;

  /// No description provided for @onboardingActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (little or no exercise)'**
  String get onboardingActivitySedentary;

  /// No description provided for @onboardingActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active (1-3 days/week)'**
  String get onboardingActivityLight;

  /// No description provided for @onboardingActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active (3-5 days/week)'**
  String get onboardingActivityModerate;

  /// No description provided for @onboardingActivityVery.
  ///
  /// In en, this message translates to:
  /// **'Very Active (6-7 days/week)'**
  String get onboardingActivityVery;

  /// No description provided for @onboardingActivityExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra Active (hard daily exercise or physical job)'**
  String get onboardingActivityExtra;

  /// No description provided for @onboardingGoal.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get onboardingGoal;

  /// No description provided for @onboardingGoalMuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain / Weight Gain'**
  String get onboardingGoalMuscleGain;

  /// No description provided for @onboardingGoalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat Loss'**
  String get onboardingGoalFatLoss;

  /// No description provided for @onboardingGoalMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get onboardingGoalMaintenance;

  /// No description provided for @onboardingGoalRecomp.
  ///
  /// In en, this message translates to:
  /// **'Body Recomposition'**
  String get onboardingGoalRecomp;

  /// No description provided for @onboardingTrainingFreq.
  ///
  /// In en, this message translates to:
  /// **'Training Days Per Week'**
  String get onboardingTrainingFreq;

  /// No description provided for @onboardingUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement Units'**
  String get onboardingUnits;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get onboardingAppearance;

  /// No description provided for @onboardingCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate Energy Needs'**
  String get onboardingCalculate;

  /// No description provided for @onboardingTargetSummary.
  ///
  /// In en, this message translates to:
  /// **'Estimated Daily Energy Needs'**
  String get onboardingTargetSummary;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Estimated with the Mifflin–St Jeor equation. Calorie targets are scientific estimates for guidance, not medical prescriptions.'**
  String get onboardingDisclaimer;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Save and Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// No description provided for @nutritionDailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get nutritionDailySummary;

  /// No description provided for @nutritionLogFood.
  ///
  /// In en, this message translates to:
  /// **'Log Food'**
  String get nutritionLogFood;

  /// No description provided for @nutritionMealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get nutritionMealBreakfast;

  /// No description provided for @nutritionMealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get nutritionMealLunch;

  /// No description provided for @nutritionMealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get nutritionMealDinner;

  /// No description provided for @nutritionMealSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get nutritionMealSnacks;

  /// No description provided for @nutritionSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search foods or Algerian dishes...'**
  String get nutritionSearchPlaceholder;

  /// No description provided for @nutritionCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nutritionCategories;

  /// No description provided for @nutritionCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get nutritionCategoryAll;

  /// No description provided for @nutritionCategoryStaples.
  ///
  /// In en, this message translates to:
  /// **'Staples & Grains'**
  String get nutritionCategoryStaples;

  /// No description provided for @nutritionCategoryProtein.
  ///
  /// In en, this message translates to:
  /// **'Meat & Fish'**
  String get nutritionCategoryProtein;

  /// No description provided for @nutritionCategoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy & Eggs'**
  String get nutritionCategoryDairy;

  /// No description provided for @nutritionCategoryProduce.
  ///
  /// In en, this message translates to:
  /// **'Fruits & Veggies'**
  String get nutritionCategoryProduce;

  /// No description provided for @nutritionCategoryAlgerian.
  ///
  /// In en, this message translates to:
  /// **'Algerian Dishes'**
  String get nutritionCategoryAlgerian;

  /// No description provided for @nutritionCategorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Legumes & Nuts'**
  String get nutritionCategorySnacks;

  /// No description provided for @nutritionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Foods'**
  String get nutritionRecent;

  /// No description provided for @nutritionFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get nutritionFavorites;

  /// No description provided for @nutritionCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Foods'**
  String get nutritionCustom;

  /// No description provided for @nutritionAddCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Food'**
  String get nutritionAddCustomFood;

  /// No description provided for @nutritionRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get nutritionRecipes;

  /// No description provided for @nutritionCreateRecipe.
  ///
  /// In en, this message translates to:
  /// **'Build Recipe'**
  String get nutritionCreateRecipe;

  /// No description provided for @nutritionServingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get nutritionServingSize;

  /// No description provided for @nutritionQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity (grams)'**
  String get nutritionQuantity;

  /// No description provided for @nutritionSelectMeal.
  ///
  /// In en, this message translates to:
  /// **'Select Meal Type'**
  String get nutritionSelectMeal;

  /// No description provided for @nutritionSaveLog.
  ///
  /// In en, this message translates to:
  /// **'Add to Log'**
  String get nutritionSaveLog;

  /// No description provided for @nutritionDeleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get nutritionDeleteLog;

  /// No description provided for @nutritionCaloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Calories (per 100g)'**
  String get nutritionCaloriesPer100g;

  /// No description provided for @nutritionProteinPer100g.
  ///
  /// In en, this message translates to:
  /// **'Protein (per 100g)'**
  String get nutritionProteinPer100g;

  /// No description provided for @nutritionCarbsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Carbs (per 100g)'**
  String get nutritionCarbsPer100g;

  /// No description provided for @nutritionFatPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fat (per 100g)'**
  String get nutritionFatPer100g;

  /// No description provided for @nutritionFiberPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fiber (per 100g)'**
  String get nutritionFiberPer100g;

  /// No description provided for @nutritionFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get nutritionFoodName;

  /// No description provided for @nutritionFoodNameArabic.
  ///
  /// In en, this message translates to:
  /// **'Food Name (Arabic - Optional)'**
  String get nutritionFoodNameArabic;

  /// No description provided for @nutritionState.
  ///
  /// In en, this message translates to:
  /// **'Preparation State (e.g., Raw, Cooked)'**
  String get nutritionState;

  /// No description provided for @nutritionSource.
  ///
  /// In en, this message translates to:
  /// **'Source / Confidence'**
  String get nutritionSource;

  /// No description provided for @nutritionVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get nutritionVerified;

  /// No description provided for @nutritionEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get nutritionEstimated;

  /// No description provided for @nutritionUserAdded.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get nutritionUserAdded;

  /// No description provided for @nutritionNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No food logged for this day yet. Tap \'+\' to start logging!'**
  String get nutritionNoLogs;

  /// No description provided for @nutritionTotalCalories.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String nutritionTotalCalories(int calories);

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Builder'**
  String get recipeTitle;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe Name'**
  String get recipeName;

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'Number of Servings'**
  String get recipeServings;

  /// No description provided for @recipeTotalCookedYield.
  ///
  /// In en, this message translates to:
  /// **'Total Cooked Weight (grams, optional)'**
  String get recipeTotalCookedYield;

  /// No description provided for @recipeYieldHelp.
  ///
  /// In en, this message translates to:
  /// **'Water loss or absorption during cooking changes total weight.'**
  String get recipeYieldHelp;

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get recipeAddIngredient;

  /// No description provided for @recipePerServing.
  ///
  /// In en, this message translates to:
  /// **'Per Serving: {cal} kcal | P: {p}g | C: {c}g | F: {f}g'**
  String recipePerServing(int cal, String p, String c, String f);

  /// No description provided for @recipeSave.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe'**
  String get recipeSave;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @workoutsPrograms.
  ///
  /// In en, this message translates to:
  /// **'Workout Programs'**
  String get workoutsPrograms;

  /// No description provided for @workoutsCreateProgram.
  ///
  /// In en, this message translates to:
  /// **'New Program'**
  String get workoutsCreateProgram;

  /// No description provided for @workoutsProgramName.
  ///
  /// In en, this message translates to:
  /// **'Program Name'**
  String get workoutsProgramName;

  /// No description provided for @workoutsProgramDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get workoutsProgramDesc;

  /// No description provided for @workoutsDays.
  ///
  /// In en, this message translates to:
  /// **'Days: {days}'**
  String workoutsDays(String days);

  /// No description provided for @workoutsExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutsExercises;

  /// No description provided for @workoutsAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get workoutsAddExercise;

  /// No description provided for @workoutsExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get workoutsExerciseLibrary;

  /// No description provided for @workoutsMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group'**
  String get workoutsMuscleGroup;

  /// No description provided for @workoutsEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get workoutsEquipment;

  /// No description provided for @workoutsTargetSets.
  ///
  /// In en, this message translates to:
  /// **'Target Sets: {sets} x {reps} reps'**
  String workoutsTargetSets(int sets, int reps);

  /// No description provided for @workoutsActiveSession.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get workoutsActiveSession;

  /// No description provided for @workoutsRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get workoutsRestTimer;

  /// No description provided for @workoutsRestTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s Rest'**
  String workoutsRestTimeRemaining(int seconds);

  /// No description provided for @workoutsSetHeader.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get workoutsSetHeader;

  /// No description provided for @workoutsWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get workoutsWeightHeader;

  /// No description provided for @workoutsRepsHeader.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workoutsRepsHeader;

  /// No description provided for @workoutsCompletedHeader.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get workoutsCompletedHeader;

  /// No description provided for @workoutsAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get workoutsAddSet;

  /// No description provided for @workoutsSkipExercise.
  ///
  /// In en, this message translates to:
  /// **'Skip Exercise'**
  String get workoutsSkipExercise;

  /// No description provided for @workoutsFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get workoutsFinishWorkout;

  /// No description provided for @workoutsDiscardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout'**
  String get workoutsDiscardWorkout;

  /// No description provided for @workoutsConfirmFinish.
  ///
  /// In en, this message translates to:
  /// **'Do you want to complete and save this workout?'**
  String get workoutsConfirmFinish;

  /// No description provided for @workoutsConfirmDiscard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this session?'**
  String get workoutsConfirmDiscard;

  /// No description provided for @workoutsSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutsSessionCompleted;

  /// No description provided for @workoutsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} mins'**
  String workoutsDuration(int minutes);

  /// No description provided for @workoutsTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume: {volume} kg'**
  String workoutsTotalVolume(String volume);

  /// No description provided for @workoutsTotalSets.
  ///
  /// In en, this message translates to:
  /// **'Completed Sets: {sets}'**
  String workoutsTotalSets(int sets);

  /// No description provided for @workoutsHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutsHistory;

  /// No description provided for @workoutsNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No completed workouts yet. Start your first session!'**
  String get workoutsNoHistory;

  /// No description provided for @workoutsPR.
  ///
  /// In en, this message translates to:
  /// **'Personal Record!'**
  String get workoutsPR;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & Metrics'**
  String get progressTitle;

  /// No description provided for @progressWeightHistory.
  ///
  /// In en, this message translates to:
  /// **'Body Weight Trend'**
  String get progressWeightHistory;

  /// No description provided for @progressAddMetric.
  ///
  /// In en, this message translates to:
  /// **'Log Body Metric'**
  String get progressAddMetric;

  /// No description provided for @progressWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (cm)'**
  String get progressWaist;

  /// No description provided for @progressDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get progressDate;

  /// No description provided for @progressTimeRange1M.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get progressTimeRange1M;

  /// No description provided for @progressTimeRange3M.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get progressTimeRange3M;

  /// No description provided for @progressTimeRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get progressTimeRangeAll;

  /// No description provided for @progressWeeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'7-Day Moving Avg: {avg} kg'**
  String progressWeeklyAverage(String avg);

  /// No description provided for @progressExercisePRs.
  ///
  /// In en, this message translates to:
  /// **'Exercise Personal Records'**
  String get progressExercisePRs;

  /// No description provided for @progressNoMetrics.
  ///
  /// In en, this message translates to:
  /// **'No body measurements logged yet. Track your weight regularly to see trends!'**
  String get progressNoMetrics;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals & Targets'**
  String get profileGoals;

  /// No description provided for @profileEditGoals.
  ///
  /// In en, this message translates to:
  /// **'Adjust Targets'**
  String get profileEditGoals;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileThemeDark;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileLanguageAr.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic)'**
  String get profileLanguageAr;

  /// No description provided for @profileUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get profileUnits;

  /// No description provided for @profileUnitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm)'**
  String get profileUnitsMetric;

  /// No description provided for @profileUnitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb, in)'**
  String get profileUnitsImperial;

  /// No description provided for @profileData.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get profileData;

  /// No description provided for @profileExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export Data (JSON)'**
  String get profileExportJson;

  /// No description provided for @profileResetData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get profileResetData;

  /// No description provided for @profileResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will delete all logged foods, workouts, and measurements.'**
  String get profileResetConfirm;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About Fit Companion'**
  String get profileAbout;

  /// No description provided for @profileAboutText.
  ///
  /// In en, this message translates to:
  /// **'Fit Companion is a private, offline-first fitness and nutrition companion engineered for real-life workout and nutrition tracking.'**
  String get profileAboutText;

  /// No description provided for @profileOfflineStatus.
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Private: Your data is stored strictly on your device.'**
  String get profileOfflineStatus;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get commonSuccess;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get commonKcal;

  /// No description provided for @commonGrams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get commonGrams;

  /// No description provided for @commonKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get commonKg;

  /// No description provided for @commonCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get commonCm;

  /// No description provided for @commonReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get commonReps;

  /// No description provided for @commonSets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get commonSets;

  /// No description provided for @nutritionCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Nutrition Calculator'**
  String get nutritionCalculatorTitle;

  /// No description provided for @nutritionCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate evidence-based energy requirements and macronutrient targets tailored to your body.'**
  String get nutritionCalculatorDesc;

  /// No description provided for @nutritionCalculatorBmr.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate (BMR)'**
  String get nutritionCalculatorBmr;

  /// No description provided for @nutritionCalculatorBmrDesc.
  ///
  /// In en, this message translates to:
  /// **'Energy consumed at complete rest to keep your brain, heart, and vital organs alive.'**
  String get nutritionCalculatorBmrDesc;

  /// No description provided for @nutritionCalculatorTdee.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy Expenditure (TDEE)'**
  String get nutritionCalculatorTdee;

  /// No description provided for @nutritionCalculatorTdeeDesc.
  ///
  /// In en, this message translates to:
  /// **'Resting energy multiplied by your physical activity factor.'**
  String get nutritionCalculatorTdeeDesc;

  /// No description provided for @nutritionCalculatorTarget.
  ///
  /// In en, this message translates to:
  /// **'Personalized Target'**
  String get nutritionCalculatorTarget;

  /// No description provided for @nutritionCalculatorHow.
  ///
  /// In en, this message translates to:
  /// **'How Was This Calculated?'**
  String get nutritionCalculatorHow;

  /// No description provided for @nutritionCalculatorFormula.
  ///
  /// In en, this message translates to:
  /// **'Mifflin–St Jeor Equation'**
  String get nutritionCalculatorFormula;

  /// No description provided for @nutritionCalculatorManualAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust Targets Manually'**
  String get nutritionCalculatorManualAdjust;

  /// No description provided for @nutritionCalculatorReset.
  ///
  /// In en, this message translates to:
  /// **'Restore Recommended Targets'**
  String get nutritionCalculatorReset;

  /// No description provided for @nutritionCalculatorApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Targets to My Profile'**
  String get nutritionCalculatorApply;

  /// No description provided for @nutritionCalculatorConfirm.
  ///
  /// In en, this message translates to:
  /// **'Update your profile targets? Your daily dashboard and diary targets will update immediately.'**
  String get nutritionCalculatorConfirm;

  /// No description provided for @nutritionCalculatorMacroWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Total calories from macros (P×4 + C×4 + F×9) does not match the target calories.'**
  String get nutritionCalculatorMacroWarning;

  /// No description provided for @nutritionTrainingType.
  ///
  /// In en, this message translates to:
  /// **'Training Style'**
  String get nutritionTrainingType;

  /// No description provided for @nutritionTrainingStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength & Hypertrophy'**
  String get nutritionTrainingStrength;

  /// No description provided for @nutritionTrainingCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio & Endurance'**
  String get nutritionTrainingCardio;

  /// No description provided for @nutritionTrainingHybrid.
  ///
  /// In en, this message translates to:
  /// **'Functional & Hybrid'**
  String get nutritionTrainingHybrid;

  /// No description provided for @nutritionTrainingGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Health & Fitness'**
  String get nutritionTrainingGeneral;

  /// No description provided for @academyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Academy'**
  String get academyTitle;

  /// No description provided for @academySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master nutrition and calorie tracking with practical beginner-friendly lessons and quizzes.'**
  String get academySubtitle;

  /// No description provided for @academyLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String academyLesson(int number);

  /// No description provided for @academyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Check'**
  String get academyQuiz;

  /// No description provided for @academyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get academyCompleted;

  /// No description provided for @academyTakeaway.
  ///
  /// In en, this message translates to:
  /// **'Practical Takeaway'**
  String get academyTakeaway;

  /// No description provided for @academyInteractiveTool.
  ///
  /// In en, this message translates to:
  /// **'Interactive Calculator Tool'**
  String get academyInteractiveTool;

  /// No description provided for @academyScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String academyScore(int score);

  /// No description provided for @foodCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Food Calculator'**
  String get foodCalculatorTitle;

  /// No description provided for @foodCalculatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate precise nutrition values based on portion weight and preparation state.'**
  String get foodCalculatorSubtitle;

  /// No description provided for @foodCalculatorServingType.
  ///
  /// In en, this message translates to:
  /// **'Serving & Prep State'**
  String get foodCalculatorServingType;

  /// No description provided for @foodCalculatorFormulaHelp.
  ///
  /// In en, this message translates to:
  /// **'Formula: (Nutrient per 100g × Grams) ÷ 100'**
  String get foodCalculatorFormulaHelp;

  /// No description provided for @foodCalculatorAddToMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Calculated Food'**
  String get foodCalculatorAddToMeal;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @dashboardKcalLeft.
  ///
  /// In en, this message translates to:
  /// **'kcal left'**
  String get dashboardKcalLeft;

  /// No description provided for @dashboardKcalOver.
  ///
  /// In en, this message translates to:
  /// **'kcal over'**
  String get dashboardKcalOver;

  /// No description provided for @dashboardGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get dashboardGoal;

  /// No description provided for @dashboardInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get dashboardInProgress;

  /// No description provided for @dashboardWeekActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly activity'**
  String get dashboardWeekActivity;

  /// No description provided for @dashboardTools.
  ///
  /// In en, this message translates to:
  /// **'Tools & learning'**
  String get dashboardTools;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get commonMl;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get waterTitle;

  /// No description provided for @waterProgress.
  ///
  /// In en, this message translates to:
  /// **'{amount} / {goal} ml'**
  String waterProgress(int amount, int goal);

  /// No description provided for @waterGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Daily water goal reached!'**
  String get waterGoalReached;

  /// No description provided for @waterSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily water goal'**
  String get waterSetGoal;

  /// No description provided for @waterUndo.
  ///
  /// In en, this message translates to:
  /// **'Remove 250 ml'**
  String get waterUndo;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get statsWorkouts;

  /// No description provided for @statsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get statsVolume;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get statsStreak;

  /// No description provided for @statsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get statsTotal;

  /// No description provided for @academyLessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String academyLessonsCount(int count);

  /// No description provided for @calculatorBmrTdee.
  ///
  /// In en, this message translates to:
  /// **'BMR & TDEE'**
  String get calculatorBmrTdee;

  /// No description provided for @portionScaler.
  ///
  /// In en, this message translates to:
  /// **'Portion scaler'**
  String get portionScaler;

  /// No description provided for @workoutsNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active workout session.'**
  String get workoutsNoActive;

  /// No description provided for @workoutsElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get workoutsElapsed;

  /// No description provided for @workoutsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Last time'**
  String get workoutsPrevious;

  /// No description provided for @workoutsRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutsRest;

  /// No description provided for @workoutsSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get workoutsSkip;

  /// No description provided for @workoutsNewPR.
  ///
  /// In en, this message translates to:
  /// **'New personal record! 🏆'**
  String get workoutsNewPR;

  /// No description provided for @workoutsDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get workoutsDeleteSet;

  /// No description provided for @workoutsRestDone.
  ///
  /// In en, this message translates to:
  /// **'Rest is over — next set!'**
  String get workoutsRestDone;

  /// No description provided for @workoutsQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick workout'**
  String get workoutsQuickStart;

  /// No description provided for @workoutsQuickStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Start empty and add exercises as you go'**
  String get workoutsQuickStartDesc;

  /// No description provided for @workoutsEmptySession.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise to start logging sets.'**
  String get workoutsEmptySession;

  /// No description provided for @workoutsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get workoutsStart;

  /// No description provided for @workoutsExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String workoutsExercisesCount(int count);

  /// No description provided for @workoutsNoProgramsYet.
  ///
  /// In en, this message translates to:
  /// **'No programs created yet.'**
  String get workoutsNoProgramsYet;

  /// No description provided for @workoutsSearchExercise.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get workoutsSearchExercise;

  /// No description provided for @sessionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout summary'**
  String get sessionDetailTitle;

  /// No description provided for @sessionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get sessionDelete;

  /// No description provided for @sessionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout from your history? This cannot be undone.'**
  String get sessionDeleteConfirm;

  /// No description provided for @sessionMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sessionMinutes(int minutes);

  /// No description provided for @progressRecentLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent logs'**
  String get progressRecentLogs;

  /// No description provided for @progressNoPRs.
  ///
  /// In en, this message translates to:
  /// **'Complete workout sets to establish your personal strength records!'**
  String get progressNoPRs;

  /// No description provided for @progressEst1RM.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get progressEst1RM;

  /// No description provided for @progressCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get progressCurrent;

  /// No description provided for @progressChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get progressChange;

  /// No description provided for @progressBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get progressBmi;

  /// No description provided for @progressSetFormat.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg × {reps}'**
  String progressSetFormat(String weight, int reps);

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym tools'**
  String get toolsTitle;

  /// No description provided for @tools1RM.
  ///
  /// In en, this message translates to:
  /// **'1RM calculator'**
  String get tools1RM;

  /// No description provided for @tools1RMDesc.
  ///
  /// In en, this message translates to:
  /// **'Estimate your max and training loads'**
  String get tools1RMDesc;

  /// No description provided for @toolsPlates.
  ///
  /// In en, this message translates to:
  /// **'Plate calculator'**
  String get toolsPlates;

  /// No description provided for @toolsPlatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Which plates to load on each side'**
  String get toolsPlatesDesc;

  /// No description provided for @toolsWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get toolsWeightKg;

  /// No description provided for @toolsReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get toolsReps;

  /// No description provided for @toolsTargetKg.
  ///
  /// In en, this message translates to:
  /// **'Target weight (kg)'**
  String get toolsTargetKg;

  /// No description provided for @toolsBarKg.
  ///
  /// In en, this message translates to:
  /// **'Bar (kg)'**
  String get toolsBarKg;

  /// No description provided for @toolsPerSide.
  ///
  /// In en, this message translates to:
  /// **'Per side'**
  String get toolsPerSide;

  /// No description provided for @toolsRemainder.
  ///
  /// In en, this message translates to:
  /// **'Can\'t load exactly — {kg} kg short'**
  String toolsRemainder(String kg);

  /// No description provided for @toolsOnlyBar.
  ///
  /// In en, this message translates to:
  /// **'Just the empty bar'**
  String get toolsOnlyBar;

  /// No description provided for @toolsPercentOf1RM.
  ///
  /// In en, this message translates to:
  /// **'% of 1RM'**
  String get toolsPercentOf1RM;

  /// No description provided for @nutritionMealEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — tap + to add food'**
  String get nutritionMealEmpty;

  /// No description provided for @nutritionMacros.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get nutritionMacros;

  /// No description provided for @mealsCopyYesterdayHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this day. Copy yesterday\'s meals?'**
  String get mealsCopyYesterdayHint;

  /// No description provided for @mealsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get mealsCopy;

  /// No description provided for @mealsCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} items copied'**
  String mealsCopied(int count);

  /// No description provided for @mealsNothingToCopy.
  ///
  /// In en, this message translates to:
  /// **'Nothing to copy'**
  String get mealsNothingToCopy;

  /// No description provided for @mealsCopyFromYesterday.
  ///
  /// In en, this message translates to:
  /// **'Copy from yesterday'**
  String get mealsCopyFromYesterday;

  /// No description provided for @mealsUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add from template'**
  String get mealsUseTemplate;

  /// No description provided for @mealsSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get mealsSaveTemplate;

  /// No description provided for @mealsTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get mealsTemplateName;

  /// No description provided for @mealsTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get mealsTemplateSaved;

  /// No description provided for @mealsTemplates.
  ///
  /// In en, this message translates to:
  /// **'Meal templates'**
  String get mealsTemplates;

  /// No description provided for @mealsNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates yet. Open a meal menu (⋮) and choose \"Save as template\".'**
  String get mealsNoTemplates;

  /// No description provided for @setsSuperset.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get setsSuperset;

  /// No description provided for @setsSupersetWithNext.
  ///
  /// In en, this message translates to:
  /// **'Superset with next exercise'**
  String get setsSupersetWithNext;

  /// No description provided for @setsRemoveSuperset.
  ///
  /// In en, this message translates to:
  /// **'Remove superset'**
  String get setsRemoveSuperset;

  /// No description provided for @setTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set type'**
  String get setTypeTitle;

  /// No description provided for @setTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get setTypeNormal;

  /// No description provided for @setTypeWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get setTypeWarmup;

  /// No description provided for @setTypeDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop set'**
  String get setTypeDrop;

  /// No description provided for @setTypeFailure.
  ///
  /// In en, this message translates to:
  /// **'To failure'**
  String get setTypeFailure;

  /// No description provided for @rpeHelp.
  ///
  /// In en, this message translates to:
  /// **'RPE = how hard the set felt. 10 = no reps left, 8 = 2 reps left in the tank. Warm-up sets don\'t count toward volume or records.'**
  String get rpeHelp;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @overloadIncrease.
  ///
  /// In en, this message translates to:
  /// **'Add {kg} kg today'**
  String overloadIncrease(String kg);

  /// No description provided for @overloadKeep.
  ///
  /// In en, this message translates to:
  /// **'Same weight — beat your reps'**
  String get overloadKeep;

  /// No description provided for @overloadDeload.
  ///
  /// In en, this message translates to:
  /// **'Deload to {kg} kg'**
  String overloadDeload(String kg);

  /// No description provided for @exerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise progress'**
  String get exerciseProgress;

  /// No description provided for @exerciseTopWeight.
  ///
  /// In en, this message translates to:
  /// **'Top weight'**
  String get exerciseTopWeight;

  /// No description provided for @exerciseNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No completed sets for this exercise yet. Finish a workout with it to see your progress chart.'**
  String get exerciseNoHistory;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscles this week'**
  String get heatmapTitle;

  /// No description provided for @heatmapHelp.
  ///
  /// In en, this message translates to:
  /// **'Working sets in the last 7 days. 10–20 sets per muscle per week is the sweet spot for growth (green). Orange = very high volume.'**
  String get heatmapHelp;

  /// No description provided for @muscleChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleBack;

  /// No description provided for @muscleLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscleLegs;

  /// No description provided for @muscleShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleShoulders;

  /// No description provided for @muscleArms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get muscleArms;

  /// No description provided for @muscleCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscleCore;

  /// No description provided for @achTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achTitle;

  /// No description provided for @achSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn badges by training consistently, eating well and hitting new records.'**
  String get achSubtitle;

  /// No description provided for @achNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get achNext;

  /// No description provided for @achUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked'**
  String get achUnlocked;

  /// No description provided for @achFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get achFirstWorkout;

  /// No description provided for @achFirstWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout.'**
  String get achFirstWorkoutDesc;

  /// No description provided for @achWorkouts10.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get achWorkouts10;

  /// No description provided for @achWorkouts50.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get achWorkouts50;

  /// No description provided for @achWorkouts100.
  ///
  /// In en, this message translates to:
  /// **'Iron legend'**
  String get achWorkouts100;

  /// No description provided for @achWorkoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} workouts.'**
  String achWorkoutsDesc(int count);

  /// No description provided for @achStreak3.
  ///
  /// In en, this message translates to:
  /// **'On fire'**
  String get achStreak3;

  /// No description provided for @achStreak7.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable week'**
  String get achStreak7;

  /// No description provided for @achStreak30.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get achStreak30;

  /// No description provided for @achStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Train {count} days in a row.'**
  String achStreakDesc(int count);

  /// No description provided for @achFirstPr.
  ///
  /// In en, this message translates to:
  /// **'Record breaker'**
  String get achFirstPr;

  /// No description provided for @achFirstPrDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your first personal record.'**
  String get achFirstPrDesc;

  /// No description provided for @achPrs25.
  ///
  /// In en, this message translates to:
  /// **'PR hunter'**
  String get achPrs25;

  /// No description provided for @achPrsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set {count} personal records.'**
  String achPrsDesc(int count);

  /// No description provided for @achFood7.
  ///
  /// In en, this message translates to:
  /// **'Mindful eater'**
  String get achFood7;

  /// No description provided for @achFood30.
  ///
  /// In en, this message translates to:
  /// **'Nutrition pro'**
  String get achFood30;

  /// No description provided for @achFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your food on {count} different days.'**
  String achFoodDesc(int count);

  /// No description provided for @achWater7.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get achWater7;

  /// No description provided for @achWaterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach your water goal on {count} days.'**
  String achWaterDesc(int count);

  /// No description provided for @achWeigh10.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get achWeigh10;

  /// No description provided for @achWeighDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your weight {count} times.'**
  String achWeighDesc(int count);

  /// No description provided for @achVolume10t.
  ///
  /// In en, this message translates to:
  /// **'10 tonnes'**
  String get achVolume10t;

  /// No description provided for @achVolume100t.
  ///
  /// In en, this message translates to:
  /// **'100 tonnes'**
  String get achVolume100t;

  /// No description provided for @achVolumeDesc.
  ///
  /// In en, this message translates to:
  /// **'Lift {tonnes} tonnes of total volume.'**
  String achVolumeDesc(String tonnes);

  /// No description provided for @measureTitle.
  ///
  /// In en, this message translates to:
  /// **'Body measurements'**
  String get measureTitle;

  /// No description provided for @measureMore.
  ///
  /// In en, this message translates to:
  /// **'More measurements (optional)'**
  String get measureMore;

  /// No description provided for @measureChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measureChest;

  /// No description provided for @measureArm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get measureArm;

  /// No description provided for @measureThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get measureThigh;

  /// No description provided for @measureHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get measureHips;

  /// No description provided for @measureBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get measureBodyFat;

  /// No description provided for @measureSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurement saved'**
  String get measureSaved;

  /// No description provided for @profileFeatures.
  ///
  /// In en, this message translates to:
  /// **'Tools & sync'**
  String get profileFeatures;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a product barcode'**
  String get scanHint;

  /// No description provided for @scanLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking up {code}…'**
  String scanLooking(String code);

  /// No description provided for @scanOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet — product lookup needs a connection the first time.'**
  String get scanOffline;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get scanNotFound;

  /// No description provided for @scanNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code} is not in the database yet. You can add it as a custom food.'**
  String scanNotFoundBody(String code);

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @scanCameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Allow camera access in the phone settings.'**
  String get scanCameraError;

  /// No description provided for @remTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remTitle;

  /// No description provided for @remSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders that work even when the app is closed.'**
  String get remSubtitle;

  /// No description provided for @remWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get remWaterTitle;

  /// No description provided for @remWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Time for a glass of water 💧'**
  String get remWaterBody;

  /// No description provided for @remMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Log your meal'**
  String get remMealTitle;

  /// No description provided for @remWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout time'**
  String get remWorkoutTitle;

  /// No description provided for @remWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s train today 💪'**
  String get remWorkoutBody;

  /// No description provided for @remWeighTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning weigh-in'**
  String get remWeighTitle;

  /// No description provided for @remWeighBody.
  ///
  /// In en, this message translates to:
  /// **'Weigh yourself before breakfast for the most accurate trend.'**
  String get remWeighBody;

  /// No description provided for @remEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get remEvery;

  /// No description provided for @remHours.
  ///
  /// In en, this message translates to:
  /// **'{h} h'**
  String remHours(int h);

  /// No description provided for @remFromTo.
  ///
  /// In en, this message translates to:
  /// **'From – to'**
  String get remFromTo;

  /// No description provided for @remTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get remTime;

  /// No description provided for @remPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them in the phone settings.'**
  String get remPermissionDenied;

  /// No description provided for @remWatchInfo.
  ///
  /// In en, this message translates to:
  /// **'The rest timer appears as a live countdown notification. If your watch (Wear OS, Galaxy Watch, Mi Band…) shows phone notifications, it shows the timer and vibrates when rest ends.'**
  String get remWatchInfo;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all your data to one file (send it to Google Drive, Telegram, email…) and restore it on any phone.'**
  String get backupSubtitle;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupExport;

  /// No description provided for @backupExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Exports a .json file and opens the share menu'**
  String get backupExportDesc;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backupRestore;

  /// No description provided for @backupRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick a backup file — replaces the data on this phone'**
  String get backupRestoreDesc;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'All current data on this phone will be replaced by the backup. Continue?'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored ✓'**
  String get backupRestored;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Fit Companion backup.'**
  String get backupInvalid;

  /// No description provided for @backupPhotosNote.
  ///
  /// In en, this message translates to:
  /// **'Note: progress photos stay on the phone and are not included in the backup file.'**
  String get backupPhotosNote;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress photos'**
  String get photosTitle;

  /// No description provided for @photosAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get photosAdd;

  /// No description provided for @photosCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photosCamera;

  /// No description provided for @photosGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photosGallery;

  /// No description provided for @photosFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get photosFront;

  /// No description provided for @photosSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get photosSide;

  /// No description provided for @photosBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get photosBack;

  /// No description provided for @photosCompare.
  ///
  /// In en, this message translates to:
  /// **'Before / after'**
  String get photosCompare;

  /// No description provided for @photosBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get photosBefore;

  /// No description provided for @photosAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get photosAfter;

  /// No description provided for @photosEmpty.
  ///
  /// In en, this message translates to:
  /// **'Take a photo every 2–4 weeks in the same light and pose to see your real change.'**
  String get photosEmpty;

  /// No description provided for @photosPrivacy.
  ///
  /// In en, this message translates to:
  /// **'🔒 Photos are private and stored only on this phone. They leave it only if you ask for an AI analysis (you confirm each time).'**
  String get photosPrivacy;

  /// No description provided for @photosDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get photosDelete;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get healthTitle;

  /// No description provided for @healthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Android\'s Health Connect to read your daily steps and save your weight there automatically.'**
  String get healthSubtitle;

  /// No description provided for @healthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health Connect is not available on this phone (needs Android 9+ and not a work profile).'**
  String get healthUnavailable;

  /// No description provided for @healthNeedsInstall.
  ///
  /// In en, this message translates to:
  /// **'Install or update the Health Connect app from Google Play first.'**
  String get healthNeedsInstall;

  /// No description provided for @healthInstall.
  ///
  /// In en, this message translates to:
  /// **'Open Google Play'**
  String get healthInstall;

  /// No description provided for @healthConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get healthConnected;

  /// No description provided for @healthNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get healthNotConnected;

  /// No description provided for @healthWhat.
  ///
  /// In en, this message translates to:
  /// **'Reads: steps • Writes: body weight'**
  String get healthWhat;

  /// No description provided for @healthConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect Health Connect'**
  String get healthConnect;

  /// No description provided for @healthStepsToday.
  ///
  /// In en, this message translates to:
  /// **'Steps today'**
  String get healthStepsToday;

  /// No description provided for @cloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudTitle;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI coach'**
  String get coachTitle;

  /// No description provided for @cloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your data safe in the cloud and move it between phones. Free, with your own account.'**
  String get cloudSubtitle;

  /// No description provided for @cloudUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud is unavailable right now (no internet at app start). Restart the app with internet.'**
  String get cloudUnavailable;

  /// No description provided for @cloudSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get cloudSignIn;

  /// No description provided for @cloudCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get cloudCreateAccount;

  /// No description provided for @cloudEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get cloudEmail;

  /// No description provided for @cloudPassword.
  ///
  /// In en, this message translates to:
  /// **'Password (6+ characters)'**
  String get cloudPassword;

  /// No description provided for @cloudInvalidForm.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and a password of at least 6 characters.'**
  String get cloudInvalidForm;

  /// No description provided for @cloudConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm it, then sign in.'**
  String get cloudConfirmEmail;

  /// No description provided for @cloudSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in ✓'**
  String get cloudSignedIn;

  /// No description provided for @cloudSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get cloudSignOut;

  /// No description provided for @cloudLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get cloudLastSync;

  /// No description provided for @cloudCloudCopy.
  ///
  /// In en, this message translates to:
  /// **'Cloud copy'**
  String get cloudCloudCopy;

  /// No description provided for @cloudRemoteNewer.
  ///
  /// In en, this message translates to:
  /// **'The cloud copy is newer than this phone (uploaded from another device). Download it, or upload to replace it.'**
  String get cloudRemoteNewer;

  /// No description provided for @cloudUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get cloudUpload;

  /// No description provided for @cloudDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get cloudDownload;

  /// No description provided for @cloudUploadOverwrite.
  ///
  /// In en, this message translates to:
  /// **'This replaces the newer cloud copy with this phone\'s data. Continue?'**
  String get cloudUploadOverwrite;

  /// No description provided for @cloudDownloadOverwrite.
  ///
  /// In en, this message translates to:
  /// **'This replaces ALL data on this phone with the cloud copy. Continue?'**
  String get cloudDownloadOverwrite;

  /// No description provided for @cloudUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded to the cloud ✓'**
  String get cloudUploaded;

  /// No description provided for @cloudDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Cloud data restored ✓'**
  String get cloudDownloaded;

  /// No description provided for @cloudAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get cloudAuto;

  /// No description provided for @cloudAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Uploads when you leave the app (never overwrites a newer cloud copy).'**
  String get cloudAutoDesc;

  /// No description provided for @cloudPrivacy.
  ///
  /// In en, this message translates to:
  /// **'🔒 Each account can only read its own data (Row Level Security). Progress photos are never uploaded. Free projects pause after ~1 week without use and wake up on the next sync.'**
  String get cloudPrivacy;

  /// No description provided for @coachTagline.
  ///
  /// In en, this message translates to:
  /// **'Personal advice from your own data'**
  String get coachTagline;

  /// No description provided for @coachIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about training, nutrition or your progress. The coach sees a short summary of your data (averages, goals, best lifts) — never your raw logs. It is not a doctor.'**
  String get coachIntro;

  /// No description provided for @coachHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach…'**
  String get coachHint;

  /// No description provided for @coachClear.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation'**
  String get coachClear;

  /// No description provided for @coachNeedsAccount.
  ///
  /// In en, this message translates to:
  /// **'The AI coach needs a free cloud account (your conversation is saved there).'**
  String get coachNeedsAccount;

  /// No description provided for @coachSuggest1.
  ///
  /// In en, this message translates to:
  /// **'Analyse my last week'**
  String get coachSuggest1;

  /// No description provided for @coachSuggest2.
  ///
  /// In en, this message translates to:
  /// **'How much protein do I need?'**
  String get coachSuggest2;

  /// No description provided for @coachSuggest3.
  ///
  /// In en, this message translates to:
  /// **'Why isn\'t my weight moving?'**
  String get coachSuggest3;

  /// No description provided for @coachSuggest4.
  ///
  /// In en, this message translates to:
  /// **'Suggest an Algerian high-protein dinner'**
  String get coachSuggest4;

  /// No description provided for @coachErrNoKey.
  ///
  /// In en, this message translates to:
  /// **'The coach is not configured yet: the Gemini API key must be added in Supabase (Edge Functions → Secrets → GEMINI_API_KEY).'**
  String get coachErrNoKey;

  /// No description provided for @coachErrLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached (40 messages). Try again tomorrow.'**
  String get coachErrLimit;

  /// No description provided for @coachErrQuota.
  ///
  /// In en, this message translates to:
  /// **'The free Gemini quota is used up for now. Try again later.'**
  String get coachErrQuota;

  /// No description provided for @coachErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'The coach could not answer. Try again.'**
  String get coachErrGeneric;

  /// No description provided for @coachErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to the coach. Check your internet.'**
  String get coachErrNetwork;

  /// No description provided for @coachErrModel.
  ///
  /// In en, this message translates to:
  /// **'The AI model name is not available. Set GEMINI_MODEL in Supabase secrets (e.g. gemini-3.8-flash).'**
  String get coachErrModel;

  /// No description provided for @coachErrBusy.
  ///
  /// In en, this message translates to:
  /// **'The AI servers are busy right now. Wait a few seconds and try again.'**
  String get coachErrBusy;

  /// No description provided for @muscleCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get muscleCardio;

  /// No description provided for @equipBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipBarbell;

  /// No description provided for @equipDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipDumbbell;

  /// No description provided for @equipMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipMachine;

  /// No description provided for @equipCable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equipCable;

  /// No description provided for @equipBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipBodyweight;

  /// No description provided for @equipKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipKettlebell;

  /// No description provided for @equipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipOther;

  /// No description provided for @exerciseCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Add my exercise'**
  String get exerciseCreateCustom;

  /// No description provided for @exerciseCreateCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Create it in seconds'**
  String get exerciseCreateCustomHint;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'No exercise found. Use \"Add my exercise\" above.'**
  String get exerciseNotFound;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// No description provided for @exerciseCompound.
  ///
  /// In en, this message translates to:
  /// **'Compound'**
  String get exerciseCompound;

  /// No description provided for @exerciseIsolation.
  ///
  /// In en, this message translates to:
  /// **'Isolation'**
  String get exerciseIsolation;

  /// No description provided for @exerciseNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes / how to do it (optional)'**
  String get exerciseNotesOptional;

  /// No description provided for @exerciseCreated.
  ///
  /// In en, this message translates to:
  /// **'Exercise added ✓'**
  String get exerciseCreated;

  /// No description provided for @programEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit program'**
  String get programEdit;

  /// No description provided for @programNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your program a name'**
  String get programNameRequired;

  /// No description provided for @programNeedsExercise.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise'**
  String get programNeedsExercise;

  /// No description provided for @programSaved.
  ///
  /// In en, this message translates to:
  /// **'Program saved ✓'**
  String get programSaved;

  /// No description provided for @programNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Upper A, Lower B, Arms & Abs'**
  String get programNameHint;

  /// No description provided for @programReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag ⋮⋮ to reorder'**
  String get programReorderHint;

  /// No description provided for @programEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet. Tap \"Add exercise\" to build your workout.'**
  String get programEmptyHint;

  /// No description provided for @programDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this program? Your workout history is kept.'**
  String get programDeleteConfirm;

  /// No description provided for @programsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your own split'**
  String get programsEmptyTitle;

  /// No description provided for @programsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create one program per training day, e.g. \"Upper A\", \"Lower A\", \"Upper B\", \"Lower B\", \"Arms & Abs\". Add only the exercises you want.'**
  String get programsEmptyBody;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made programs'**
  String get templatesTitle;

  /// No description provided for @templatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PPL, Upper/Lower, Full Body, 5/3/1 — copy one and customise it'**
  String get templatesSubtitle;

  /// No description provided for @templateUse.
  ///
  /// In en, this message translates to:
  /// **'Add to my programs & edit'**
  String get templateUse;

  /// No description provided for @templateCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to your programs — customise it'**
  String get templateCopied;

  /// No description provided for @templateBadge.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateBadge;

  /// No description provided for @foodsMine.
  ///
  /// In en, this message translates to:
  /// **'My foods'**
  String get foodsMine;

  /// No description provided for @foodsSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get foodsSuggestions;

  /// No description provided for @foodsAddMine.
  ///
  /// In en, this message translates to:
  /// **'Add my food'**
  String get foodsAddMine;

  /// No description provided for @foodsMineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your food list is empty'**
  String get foodsMineEmptyTitle;

  /// No description provided for @foodsMineEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add what you really eat: write the name, a short description and the weight — AI calculates calories, protein, carbs and fat for you. Ready-made foods are in \"Suggestions\".'**
  String get foodsMineEmptyBody;

  /// No description provided for @foodsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this food from your list? Past logs are kept.'**
  String get foodsDeleteConfirm;

  /// No description provided for @myFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get myFoodName;

  /// No description provided for @myFoodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken couscous'**
  String get myFoodNameHint;

  /// No description provided for @myFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (ingredients, how it was cooked)'**
  String get myFoodDescription;

  /// No description provided for @myFoodDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150 g cooked couscous, 120 g chicken breast, vegetables, 1 tbsp olive oil'**
  String get myFoodDescriptionHint;

  /// No description provided for @myFoodWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight of the portion'**
  String get myFoodWeight;

  /// No description provided for @myFoodAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Calculate with AI'**
  String get myFoodAnalyze;

  /// No description provided for @myFoodAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get myFoodAnalyzing;

  /// No description provided for @myFoodNeedNameWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter the food name and its weight.'**
  String get myFoodNeedNameWeight;

  /// No description provided for @myFoodNeedValues.
  ///
  /// In en, this message translates to:
  /// **'Calculate with AI or enter the calories manually.'**
  String get myFoodNeedValues;

  /// No description provided for @myFoodNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'AI calculation needs a free account (My account → Cloud sync). You can also type the values yourself.'**
  String get myFoodNeedAccount;

  /// No description provided for @myFoodConfHigh.
  ///
  /// In en, this message translates to:
  /// **'High accuracy'**
  String get myFoodConfHigh;

  /// No description provided for @myFoodConfMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium accuracy'**
  String get myFoodConfMedium;

  /// No description provided for @myFoodConfLow.
  ///
  /// In en, this message translates to:
  /// **'Low accuracy — add details'**
  String get myFoodConfLow;

  /// No description provided for @myFoodPer100.
  ///
  /// In en, this message translates to:
  /// **'Per 100 g'**
  String get myFoodPer100;

  /// No description provided for @myFoodPortionValues.
  ///
  /// In en, this message translates to:
  /// **'Values for {grams} g'**
  String myFoodPortionValues(String grams);

  /// No description provided for @myFoodEditHint.
  ///
  /// In en, this message translates to:
  /// **'You can correct any value before saving. The more details in the description, the more accurate the result.'**
  String get myFoodEditHint;

  /// No description provided for @myFoodLogNow.
  ///
  /// In en, this message translates to:
  /// **'Add it to today\'s meals'**
  String get myFoodLogNow;

  /// No description provided for @myFoodSaveAndLog.
  ///
  /// In en, this message translates to:
  /// **'Save & add to meal'**
  String get myFoodSaveAndLog;

  /// No description provided for @myFoodSaved.
  ///
  /// In en, this message translates to:
  /// **'Food saved to your list ✓'**
  String get myFoodSaved;

  /// No description provided for @myFoodSavedLogged.
  ///
  /// In en, this message translates to:
  /// **'Food saved and added ✓'**
  String get myFoodSavedLogged;

  /// No description provided for @eatenQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you eat it?'**
  String get eatenQuestion;

  /// No description provided for @eatenYes.
  ///
  /// In en, this message translates to:
  /// **'Yes — counts in today\'s totals'**
  String get eatenYes;

  /// No description provided for @eatenPlanned.
  ///
  /// In en, this message translates to:
  /// **'Not yet — saved as planned'**
  String get eatenPlanned;

  /// No description provided for @eatenAtTime.
  ///
  /// In en, this message translates to:
  /// **'Eaten at'**
  String get eatenAtTime;

  /// No description provided for @eatenMark.
  ///
  /// In en, this message translates to:
  /// **'Mark as eaten'**
  String get eatenMark;

  /// No description provided for @eatenUndo.
  ///
  /// In en, this message translates to:
  /// **'Mark as not eaten'**
  String get eatenUndo;

  /// No description provided for @eatenWhen.
  ///
  /// In en, this message translates to:
  /// **'When did you eat it?'**
  String get eatenWhen;

  /// No description provided for @eatenAtShort.
  ///
  /// In en, this message translates to:
  /// **'Eaten at'**
  String get eatenAtShort;

  /// No description provided for @eatenPlannedShort.
  ///
  /// In en, this message translates to:
  /// **'Planned — tap ○ when you eat it'**
  String get eatenPlannedShort;

  /// No description provided for @eatenPlannedKcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal planned, not eaten yet'**
  String eatenPlannedKcal(int kcal);

  /// No description provided for @themesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themes & appearance'**
  String get themesTitle;

  /// No description provided for @themesColors.
  ///
  /// In en, this message translates to:
  /// **'Colour themes'**
  String get themesColors;

  /// No description provided for @themesBackground.
  ///
  /// In en, this message translates to:
  /// **'Animated background'**
  String get themesBackground;

  /// No description provided for @themesAnimated.
  ///
  /// In en, this message translates to:
  /// **'Animated background'**
  String get themesAnimated;

  /// No description provided for @themesAnimatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Smooth moving background behind every screen'**
  String get themesAnimatedDesc;

  /// No description provided for @themesInteractive.
  ///
  /// In en, this message translates to:
  /// **'React to touch'**
  String get themesInteractive;

  /// No description provided for @themesInteractiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Ripples, glow and particles follow your finger'**
  String get themesInteractiveDesc;

  /// No description provided for @themesIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get themesIntensity;

  /// No description provided for @themesEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get themesEffect;

  /// No description provided for @themesBatteryNote.
  ///
  /// In en, this message translates to:
  /// **'The animation runs at 30 fps, pauses when the app is in the background and turns off automatically if \"Remove animations\" is enabled in Android accessibility settings.'**
  String get themesBatteryNote;

  /// No description provided for @fxAuto.
  ///
  /// In en, this message translates to:
  /// **'Theme default'**
  String get fxAuto;

  /// No description provided for @fxNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get fxNone;

  /// No description provided for @fxOrbs.
  ///
  /// In en, this message translates to:
  /// **'Glow orbs'**
  String get fxOrbs;

  /// No description provided for @fxParticles.
  ///
  /// In en, this message translates to:
  /// **'Particles'**
  String get fxParticles;

  /// No description provided for @fxWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get fxWaves;

  /// No description provided for @fxGrid.
  ///
  /// In en, this message translates to:
  /// **'Neon grid'**
  String get fxGrid;

  /// No description provided for @fxAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get fxAurora;

  /// No description provided for @fxBokeh.
  ///
  /// In en, this message translates to:
  /// **'Bokeh'**
  String get fxBokeh;

  /// No description provided for @fxStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get fxStars;

  /// No description provided for @shapeSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp corners'**
  String get shapeSharp;

  /// No description provided for @shapeSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft corners'**
  String get shapeSoft;

  /// No description provided for @shapeRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get shapeRounded;

  /// No description provided for @shapePill.
  ///
  /// In en, this message translates to:
  /// **'Pill shapes'**
  String get shapePill;

  /// No description provided for @aboutDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get aboutDevelopedBy;

  /// No description provided for @aboutDeveloperName.
  ///
  /// In en, this message translates to:
  /// **'Mahdi Hafiane'**
  String get aboutDeveloperName;

  /// No description provided for @scanAiEstimating.
  ///
  /// In en, this message translates to:
  /// **'Found \"{name}\" — AI is calculating its nutrition…'**
  String scanAiEstimating(String name);

  /// No description provided for @scanNotFoundAi.
  ///
  /// In en, this message translates to:
  /// **'Barcode {code} is not in the online database. Take a photo of the package (ideally the nutrition table) and AI will read the product name and its values.'**
  String scanNotFoundAi(String code);

  /// No description provided for @scanPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo of product'**
  String get scanPhotoLabel;

  /// No description provided for @scanManual.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanManual;

  /// No description provided for @scanReadingLabel.
  ///
  /// In en, this message translates to:
  /// **'AI is reading the product…'**
  String get scanReadingLabel;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal photo (AI)'**
  String get photoTitle;

  /// No description provided for @photoHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your plate, meal or product: AI identifies the foods and calculates calories, protein, carbs and fat.'**
  String get photoHint;

  /// No description provided for @photoAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get photoAnalyzing;

  /// No description provided for @photoNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the AI (optional)'**
  String get photoNote;

  /// No description provided for @photoNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. fried in olive oil, 2 eggs, big portion'**
  String get photoNoteHint;

  /// No description provided for @photoNotFood.
  ///
  /// In en, this message translates to:
  /// **'No food detected in this photo. Try another angle with the whole plate visible.'**
  String get photoNotFood;

  /// No description provided for @photoResults.
  ///
  /// In en, this message translates to:
  /// **'Detected foods'**
  String get photoResults;

  /// No description provided for @photoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'To make it better'**
  String get photoSuggestions;

  /// No description provided for @photoLogged.
  ///
  /// In en, this message translates to:
  /// **'{count} items added to your meal ✓'**
  String photoLogged(int count);

  /// No description provided for @coachAttach.
  ///
  /// In en, this message translates to:
  /// **'Send photo or video'**
  String get coachAttach;

  /// No description provided for @coachTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get coachTakePhoto;

  /// No description provided for @coachPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo from gallery'**
  String get coachPickPhoto;

  /// No description provided for @coachRecordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record a video (max 60 s)'**
  String get coachRecordVideo;

  /// No description provided for @coachPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Video from gallery'**
  String get coachPickVideo;

  /// No description provided for @coachPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo attached'**
  String get coachPhotoAttached;

  /// No description provided for @coachVideoAttached.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get coachVideoAttached;

  /// No description provided for @coachUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get coachUploading;

  /// No description provided for @coachAnalyzingVideo.
  ///
  /// In en, this message translates to:
  /// **'Analysing the video (can take up to a minute)…'**
  String get coachAnalyzingVideo;

  /// No description provided for @coachErrMediaBig.
  ///
  /// In en, this message translates to:
  /// **'File too large (max 40 MB). Send a shorter video.'**
  String get coachErrMediaBig;

  /// No description provided for @coachErrUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Check your internet and try again.'**
  String get coachErrUpload;

  /// No description provided for @coachErrMediaType.
  ///
  /// In en, this message translates to:
  /// **'This file type could not be analysed. Try another photo or an MP4 video.'**
  String get coachErrMediaType;

  /// No description provided for @photosDate.
  ///
  /// In en, this message translates to:
  /// **'Date of the photo'**
  String get photosDate;

  /// No description provided for @photosLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get photosLastWeek;

  /// No description provided for @photos2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get photos2Weeks;

  /// No description provided for @photosLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get photosLastMonth;

  /// No description provided for @photosPose.
  ///
  /// In en, this message translates to:
  /// **'Pose'**
  String get photosPose;

  /// No description provided for @photosNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 photos in the same pose to compare them and get an AI analysis.'**
  String get photosNeedTwo;

  /// No description provided for @photosDaysApart.
  ///
  /// In en, this message translates to:
  /// **'{days} days between the photos'**
  String photosDaysApart(int days);

  /// No description provided for @photosAiAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyse my progress with AI'**
  String get photosAiAnalyze;

  /// No description provided for @photosAiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Send these 2 photos for analysis?'**
  String get photosAiConsentTitle;

  /// No description provided for @photosAiConsent.
  ///
  /// In en, this message translates to:
  /// **'Your photos are private and stay on this phone. For this analysis only, the 2 selected photos are sent securely to Google Gemini (via your account). They are not saved on our server.'**
  String get photosAiConsent;

  /// No description provided for @photosHomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add body photos to see your real transformation'**
  String get photosHomeEmpty;

  /// No description provided for @photosHomeLast.
  ///
  /// In en, this message translates to:
  /// **'Last photo {days} days ago'**
  String photosHomeLast(int days);

  /// No description provided for @photosHomeCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare before / after and get an AI progress analysis'**
  String get photosHomeCompare;

  /// No description provided for @aiProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'AI progress analysis'**
  String get aiProgressTitle;

  /// No description provided for @aiMuscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle gain'**
  String get aiMuscle;

  /// No description provided for @aiFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get aiFat;

  /// No description provided for @aiGainClear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get aiGainClear;

  /// No description provided for @aiGainSlight.
  ///
  /// In en, this message translates to:
  /// **'slight'**
  String get aiGainSlight;

  /// No description provided for @aiGainNone.
  ///
  /// In en, this message translates to:
  /// **'not visible'**
  String get aiGainNone;

  /// No description provided for @aiUnclear.
  ///
  /// In en, this message translates to:
  /// **'unclear'**
  String get aiUnclear;

  /// No description provided for @aiFatLess.
  ///
  /// In en, this message translates to:
  /// **'lower'**
  String get aiFatLess;

  /// No description provided for @aiFatSame.
  ///
  /// In en, this message translates to:
  /// **'same'**
  String get aiFatSame;

  /// No description provided for @aiFatMore.
  ///
  /// In en, this message translates to:
  /// **'higher'**
  String get aiFatMore;

  /// No description provided for @aiNotComparable.
  ///
  /// In en, this message translates to:
  /// **'The photos are hard to compare (different light, pose or distance).'**
  String get aiNotComparable;

  /// No description provided for @aiAreas.
  ///
  /// In en, this message translates to:
  /// **'By muscle group'**
  String get aiAreas;

  /// No description provided for @aiTips.
  ///
  /// In en, this message translates to:
  /// **'How to progress faster'**
  String get aiTips;

  /// No description provided for @profileAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get profileAthlete;

  /// No description provided for @profileYears.
  ///
  /// In en, this message translates to:
  /// **'{age} y'**
  String profileYears(int age);

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get profilePreferences;

  /// No description provided for @tdeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your real maintenance calories'**
  String get tdeeTitle;

  /// No description provided for @tdeeNeedData.
  ///
  /// In en, this message translates to:
  /// **'Log your meals and weigh in for ~2 weeks and the app will calculate your real TDEE.'**
  String get tdeeNeedData;

  /// No description provided for @tdeePerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal / day'**
  String get tdeePerDay;

  /// No description provided for @tdeeExplain.
  ///
  /// In en, this message translates to:
  /// **'You ate {avg} kcal on average and your weight changed {change} kg/week ({days} days logged).'**
  String tdeeExplain(int avg, String change, int days);

  /// No description provided for @tdeeSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggested target: {target} kcal (now {current})'**
  String tdeeSuggest(int target, int current);

  /// No description provided for @tdeeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get tdeeApply;

  /// No description provided for @tdeeApplied.
  ///
  /// In en, this message translates to:
  /// **'Calorie target updated'**
  String get tdeeApplied;

  /// No description provided for @tdeeOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Your calorie target matches your real TDEE'**
  String get tdeeOnTrack;

  /// No description provided for @fatigueFresh.
  ///
  /// In en, this message translates to:
  /// **'Recovery looks good'**
  String get fatigueFresh;

  /// No description provided for @fatigueFreshBody.
  ///
  /// In en, this message translates to:
  /// **'Your strength is stable or rising. Keep pushing!'**
  String get fatigueFreshBody;

  /// No description provided for @fatigueWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch your recovery'**
  String get fatigueWatch;

  /// No description provided for @fatigueWatchBody.
  ///
  /// In en, this message translates to:
  /// **'Some fatigue signs. Sleep well, eat enough and don\'t add volume this week.'**
  String get fatigueWatchBody;

  /// No description provided for @fatigueDeload.
  ///
  /// In en, this message translates to:
  /// **'Time for a deload week'**
  String get fatigueDeload;

  /// No description provided for @fatigueDeloadBody.
  ///
  /// In en, this message translates to:
  /// **'Cut weights by ~40% and sets by half for one week, then come back stronger.'**
  String get fatigueDeloadBody;

  /// No description provided for @fatigueReasonDeclining.
  ///
  /// In en, this message translates to:
  /// **'{n} exercises got weaker 2 sessions in a row'**
  String fatigueReasonDeclining(int n);

  /// No description provided for @fatigueReasonRpe.
  ///
  /// In en, this message translates to:
  /// **'Very high effort (RPE ≥ 9) in the last 2 weeks'**
  String get fatigueReasonRpe;

  /// No description provided for @fatigueReasonWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} hard weeks in a row without a break'**
  String fatigueReasonWeeks(int weeks);

  /// No description provided for @noteSkipped.
  ///
  /// In en, this message translates to:
  /// **'You skipped a set — go back and finish it?'**
  String get noteSkipped;

  /// No description provided for @noteWeightDropping.
  ///
  /// In en, this message translates to:
  /// **'Your top weight dropped 2 sessions in a row. Rest well before this one.'**
  String get noteWeightDropping;

  /// No description provided for @noteMissedReps.
  ///
  /// In en, this message translates to:
  /// **'Last time you missed the target reps. Keep the same weight today.'**
  String get noteMissedReps;

  /// No description provided for @noteCloseToPr.
  ///
  /// In en, this message translates to:
  /// **'Only {kg} kg from your record — go for it! 🏆'**
  String noteCloseToPr(String kg);

  /// No description provided for @chTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges & levels'**
  String get chTitle;

  /// No description provided for @chWeekly.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get chWeekly;

  /// No description provided for @chMonthly.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get chMonthly;

  /// No description provided for @chWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Complete {n} workouts'**
  String chWorkouts(int n);

  /// No description provided for @chProtein.
  ///
  /// In en, this message translates to:
  /// **'Hit your protein goal {n} days'**
  String chProtein(int n);

  /// No description provided for @chWater.
  ///
  /// In en, this message translates to:
  /// **'Reach your water goal {n} days'**
  String chWater(int n);

  /// No description provided for @chLog.
  ///
  /// In en, this message translates to:
  /// **'Log your food {n} days'**
  String chLog(int n);

  /// No description provided for @chPrs.
  ///
  /// In en, this message translates to:
  /// **'Break {n} personal records'**
  String chPrs(int n);

  /// No description provided for @chVolume.
  ///
  /// In en, this message translates to:
  /// **'Lift {t} tonnes in total'**
  String chVolume(String t);

  /// No description provided for @chWeigh.
  ///
  /// In en, this message translates to:
  /// **'Weigh in {n} times'**
  String chWeigh(int n);

  /// No description provided for @chDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get chDone;

  /// No description provided for @chDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{n} days left'**
  String chDaysLeft(int n);

  /// No description provided for @chCompleted.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed'**
  String get chCompleted;

  /// No description provided for @xpToNext.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to level {level}'**
  String xpToNext(int xp, int level);

  /// No description provided for @xpHowTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your XP comes from'**
  String get xpHowTitle;

  /// No description provided for @xpWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts (50 each)'**
  String get xpWorkouts;

  /// No description provided for @xpPrs.
  ///
  /// In en, this message translates to:
  /// **'Personal records (30 each)'**
  String get xpPrs;

  /// No description provided for @xpFood.
  ///
  /// In en, this message translates to:
  /// **'Days with food logged (10)'**
  String get xpFood;

  /// No description provided for @xpWater.
  ///
  /// In en, this message translates to:
  /// **'Water goal days (10)'**
  String get xpWater;

  /// No description provided for @xpWeigh.
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins (5)'**
  String get xpWeigh;

  /// No description provided for @xpChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get xpChallenges;

  /// No description provided for @lvlBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get lvlBeginner;

  /// No description provided for @lvlRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get lvlRookie;

  /// No description provided for @lvlAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get lvlAthlete;

  /// No description provided for @lvlWarrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get lvlWarrior;

  /// No description provided for @lvlBeast.
  ///
  /// In en, this message translates to:
  /// **'Beast'**
  String get lvlBeast;

  /// No description provided for @lvlLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get lvlLegend;

  /// No description provided for @aiToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI tools'**
  String get aiToolsTitle;

  /// No description provided for @aiSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get aiSignIn;

  /// No description provided for @aiGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get aiGenerate;

  /// No description provided for @aiRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate again'**
  String get aiRegenerate;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'The AI is working on it… (up to a minute)'**
  String get aiThinking;

  /// No description provided for @aiKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get aiKcal;

  /// No description provided for @aiReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly AI report'**
  String get aiReportTitle;

  /// No description provided for @aiReportIntro.
  ///
  /// In en, this message translates to:
  /// **'A coach-style review of your week: training, food, weight, sleep, with goals for next week.'**
  String get aiReportIntro;

  /// No description provided for @aiReportRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me every Friday evening'**
  String get aiReportRemind;

  /// No description provided for @aiReportNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weekly report is ready 📊'**
  String get aiReportNotifTitle;

  /// No description provided for @aiReportNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Open Fit Companion to see how your week went.'**
  String get aiReportNotifBody;

  /// No description provided for @aiWins.
  ///
  /// In en, this message translates to:
  /// **'What went well'**
  String get aiWins;

  /// No description provided for @aiImprove.
  ///
  /// In en, this message translates to:
  /// **'To improve'**
  String get aiImprove;

  /// No description provided for @aiNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Goals for next week'**
  String get aiNextWeek;

  /// No description provided for @aiProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'AI program builder'**
  String get aiProgramTitle;

  /// No description provided for @aiProgramDays.
  ///
  /// In en, this message translates to:
  /// **'{n} training days per week'**
  String aiProgramDays(int n);

  /// No description provided for @aiProgramGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get aiProgramGoal;

  /// No description provided for @aiProgramEquipment.
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get aiProgramEquipment;

  /// No description provided for @aiProgramNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get aiProgramNotes;

  /// No description provided for @aiProgramNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. knee pain, 45 min max, focus on arms'**
  String get aiProgramNotesHint;

  /// No description provided for @aiProgramSave.
  ///
  /// In en, this message translates to:
  /// **'Save to my programs'**
  String get aiProgramSave;

  /// No description provided for @aiProgramSaved.
  ///
  /// In en, this message translates to:
  /// **'Program saved to your workouts'**
  String get aiProgramSaved;

  /// No description provided for @aiGoalStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get aiGoalStrength;

  /// No description provided for @aiGoalMuscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get aiGoalMuscle;

  /// No description provided for @aiGoalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat loss'**
  String get aiGoalFatLoss;

  /// No description provided for @aiGoalEndurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get aiGoalEndurance;

  /// No description provided for @aiEqBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get aiEqBarbell;

  /// No description provided for @aiEqDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get aiEqDumbbell;

  /// No description provided for @aiEqCable.
  ///
  /// In en, this message translates to:
  /// **'Cables'**
  String get aiEqCable;

  /// No description provided for @aiEqMachine.
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get aiEqMachine;

  /// No description provided for @aiEqBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get aiEqBodyweight;

  /// No description provided for @aiMealTitle.
  ///
  /// In en, this message translates to:
  /// **'AI meal plan'**
  String get aiMealTitle;

  /// No description provided for @aiMealIntro.
  ///
  /// In en, this message translates to:
  /// **'A full day of meals that hits your calories and macros, with local foods and a shopping list.'**
  String get aiMealIntro;

  /// No description provided for @aiMealRequest.
  ///
  /// In en, this message translates to:
  /// **'Preferences (optional)'**
  String get aiMealRequest;

  /// No description provided for @aiMealRequestHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. cheap, no fish, 4 meals, I work until 17:00'**
  String get aiMealRequestHint;

  /// No description provided for @aiMealAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to today'**
  String get aiMealAdd;

  /// No description provided for @aiMealAddedShort.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get aiMealAddedShort;

  /// No description provided for @aiMealAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to today as planned (tick it when you eat it)'**
  String get aiMealAdded;

  /// No description provided for @aiShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get aiShopping;

  /// No description provided for @aiVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Log food by voice'**
  String get aiVoiceTitle;

  /// No description provided for @aiVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Say what you ate, e.g. \"two eggs, a piece of kesra and a coffee with milk\". Darija, Arabic, French or English.'**
  String get aiVoiceHint;

  /// No description provided for @aiVoiceTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get aiVoiceTap;

  /// No description provided for @aiVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening… tap to stop'**
  String get aiVoiceListening;

  /// No description provided for @aiVoiceNoMic.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed'**
  String get aiVoiceNoMic;

  /// No description provided for @aiVoiceNothing.
  ///
  /// In en, this message translates to:
  /// **'No food was recognised. Try again.'**
  String get aiVoiceNothing;

  /// No description provided for @aiVoiceLog.
  ///
  /// In en, this message translates to:
  /// **'Log {n} items'**
  String aiVoiceLog(int n);

  /// No description provided for @aiVoiceLogged.
  ///
  /// In en, this message translates to:
  /// **'{n} items logged'**
  String aiVoiceLogged(int n);

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly leaderboard with your friends'**
  String get friendsSubtitle;

  /// No description provided for @friendsNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your cloud account to add friends and compare progress.'**
  String get friendsNeedAccount;

  /// No description provided for @friendsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get friendsRetry;

  /// No description provided for @friendsMyCode.
  ///
  /// In en, this message translates to:
  /// **'My friend code'**
  String get friendsMyCode;

  /// No description provided for @friendsMyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Share it — only friends see your stats'**
  String get friendsMyCodeHint;

  /// No description provided for @friendsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get friendsCopy;

  /// No description provided for @friendsCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get friendsCopied;

  /// No description provided for @friendsInvite.
  ///
  /// In en, this message translates to:
  /// **'Train with me on Fit Companion! My friend code: {code}'**
  String friendsInvite(String code);

  /// No description provided for @friendsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendsAdd;

  /// No description provided for @friendsCode.
  ///
  /// In en, this message translates to:
  /// **'Friend code'**
  String get friendsCode;

  /// No description provided for @friendsAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String friendsAdded(String name);

  /// No description provided for @friendsCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user with this code'**
  String get friendsCodeNotFound;

  /// No description provided for @friendsOwnCode.
  ///
  /// In en, this message translates to:
  /// **'This is your own code'**
  String get friendsOwnCode;

  /// No description provided for @friendsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get friendsRemove;

  /// No description provided for @friendsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your friends?'**
  String friendsRemoveConfirm(String name);

  /// No description provided for @friendsRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a friend to remove them'**
  String get friendsRemoveHint;

  /// No description provided for @friendsSortVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get friendsSortVolume;

  /// No description provided for @friendsSortWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get friendsSortWorkouts;

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Share your code to start competing!'**
  String get friendsEmpty;

  /// No description provided for @friendsYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get friendsYou;

  /// No description provided for @friendsLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String friendsLevel(int level);

  /// No description provided for @sleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep & performance'**
  String get sleepTitle;

  /// No description provided for @sleepConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect Health Connect to read your sleep (from your watch or sleep app) and see how it affects your workouts.'**
  String get sleepConnect;

  /// No description provided for @sleepConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect sleep data'**
  String get sleepConnectButton;

  /// No description provided for @sleepAvg.
  ///
  /// In en, this message translates to:
  /// **'Average {hours} h per night ({nights} nights this week)'**
  String sleepAvg(String hours, int nights);

  /// No description provided for @sleepNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Train more on tracked nights to see the effect on your performance.'**
  String get sleepNeedMore;

  /// No description provided for @sleepBetter.
  ///
  /// In en, this message translates to:
  /// **'You lift {pct}% more volume after 7 h+ of sleep'**
  String sleepBetter(String pct);

  /// No description provided for @sleepNoEffect.
  ///
  /// In en, this message translates to:
  /// **'No clear effect of short nights on your volume yet'**
  String get sleepNoEffect;

  /// No description provided for @sleepTip.
  ///
  /// In en, this message translates to:
  /// **'Aim for 7–9 h: muscle is built while you sleep.'**
  String get sleepTip;

  /// No description provided for @exerciseWatchHow.
  ///
  /// In en, this message translates to:
  /// **'Watch how'**
  String get exerciseWatchHow;

  /// No description provided for @exerciseVideoError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the video'**
  String get exerciseVideoError;

  /// No description provided for @exerciseOpenYoutube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get exerciseOpenYoutube;

  /// No description provided for @exerciseAnotherVideo.
  ///
  /// In en, this message translates to:
  /// **'Another video'**
  String get exerciseAnotherVideo;

  /// No description provided for @exerciseVideoSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in once to load the demo video inside the app.'**
  String get exerciseVideoSignIn;

  /// No description provided for @exerciseVideoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The demo video isn\'t available right now.'**
  String get exerciseVideoUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
