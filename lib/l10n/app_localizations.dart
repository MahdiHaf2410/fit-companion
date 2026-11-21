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
