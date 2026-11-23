// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رفيق اللياقة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navNutrition => 'التغذية';

  @override
  String get navWorkouts => 'التمارين';

  @override
  String get navProgress => 'التقدم';

  @override
  String get navProfile => 'حسابي';

  @override
  String get dashboardTitle => 'نظرة عامة يومية';

  @override
  String get dashboardNutritionCard => 'التغذية اليومية';

  @override
  String get dashboardCalories => 'السعرات الحرارية';

  @override
  String dashboardCalorieTarget(int target) {
    return 'الهدف: $target سعرة';
  }

  @override
  String get dashboardConsumed => 'المستهلك';

  @override
  String get dashboardRemaining => 'المتبقي';

  @override
  String get dashboardOverLimit => 'تجاوز بـ';

  @override
  String get dashboardProtein => 'بروتين';

  @override
  String get dashboardCarbs => 'كربوهيدرات';

  @override
  String get dashboardFat => 'دهون';

  @override
  String dashboardGrams(String amount, String target) {
    return '$amountغ / $targetغ';
  }

  @override
  String get dashboardTodayWorkout => 'تمرين اليوم';

  @override
  String get dashboardNoWorkoutToday => 'لا يوجد تمرين مجدول لهذا اليوم';

  @override
  String get dashboardStartWorkout => 'بدء التمرين';

  @override
  String get dashboardResumeWorkout => 'استئناف التمرين';

  @override
  String get dashboardWorkoutCompleted => 'تم إكمال تمرين اليوم بنجاح!';

  @override
  String get dashboardBodyProgress => 'تطور الجسم';

  @override
  String dashboardLatestWeight(String weight) {
    return 'آخر وزن: $weight كغ';
  }

  @override
  String get dashboardNoWeightYet => 'لم يتم تسجيل أي وزن بعد';

  @override
  String get dashboardQuickActions => 'إجراءات سريعة';

  @override
  String get dashboardActionAddFood => 'تسجيل وجبة';

  @override
  String get dashboardActionStartWorkout => 'تمرين';

  @override
  String get dashboardActionLogWeight => 'تسجيل الوزن';

  @override
  String get dashboardActionBuildRecipe => 'وصفة جديدة';

  @override
  String dashboardEstimatedTarget(int target) {
    return 'الهدف اليومي التقديري: $target سعرة';
  }

  @override
  String get dashboardCalculatorCard => 'حاسبة الاحتياج الشخصي';

  @override
  String get dashboardCalculatorDesc =>
      'احسب احتياجك من السعرات والمغذيات بدقة وفق معادلة ميفلين - سانت جور.';

  @override
  String get dashboardAcademyCard => 'أكاديمية التغذية';

  @override
  String get dashboardAcademyDesc =>
      '14 درساً عملياً مع اختبارات قصيرة وأدوات تفاعلية.';

  @override
  String get onboardingTitle => 'مرحباً بك في رفيق اللياقة';

  @override
  String get onboardingSubtitle =>
      'رفيقك الشخصي للياقة والتغذية دون الحاجة إلى إنترنت';

  @override
  String get onboardingName => 'الاسم المستعار (اختياري)';

  @override
  String get onboardingAge => 'العمر';

  @override
  String get onboardingSex => 'الجنس';

  @override
  String get onboardingSexMale => 'ذكر';

  @override
  String get onboardingSexFemale => 'أنثى';

  @override
  String get onboardingHeight => 'الطول (سم)';

  @override
  String get onboardingWeight => 'الوزن الحالي (كغ)';

  @override
  String get onboardingActivity => 'مستوى النشاط البدني';

  @override
  String get onboardingActivitySedentary => 'خامل (قليل أو بدون نشاط)';

  @override
  String get onboardingActivityLight => 'نشاط خفيف (تمارين 1-3 أيام/أسبوع)';

  @override
  String get onboardingActivityModerate => 'نشاط معتدل (تمارين 3-5 أيام/أسبوع)';

  @override
  String get onboardingActivityVery => 'نشيط جداً (تمارين 6-7 أيام/أسبوع)';

  @override
  String get onboardingActivityExtra =>
      'نشاط فائق (تمارين شاقة أو عمل بدني مجهد)';

  @override
  String get onboardingGoal => 'الهدف الرياضي';

  @override
  String get onboardingGoalMuscleGain => 'بناء العضلات / زيادة الوزن';

  @override
  String get onboardingGoalFatLoss => 'خسارة الدهون';

  @override
  String get onboardingGoalMaintenance => 'المحافظة على الوزن';

  @override
  String get onboardingGoalRecomp => 'إعادة تشكيل الجسم';

  @override
  String get onboardingTrainingFreq => 'أيام التمرين في الأسبوع';

  @override
  String get onboardingUnits => 'وحدات القياس';

  @override
  String get onboardingLanguage => 'اللغة';

  @override
  String get onboardingAppearance => 'المظهر';

  @override
  String get onboardingCalculate => 'حساب الاحتياجات اليومية';

  @override
  String get onboardingTargetSummary => 'الاحتياج اليومي التقديري من الطاقة';

  @override
  String get onboardingDisclaimer =>
      'تم الحساب باستخدام معادلة ميفلين-سانت جور المعتمدة. السعرات المقدرة هي أرقام إرشادية علمية وليست وصفة طبية.';

  @override
  String get onboardingGetStarted => 'حفظ والبدء الآن';

  @override
  String get nutritionTitle => 'التغذية';

  @override
  String get nutritionDailySummary => 'ملخص اليوم';

  @override
  String get nutritionLogFood => 'تسجيل طعام';

  @override
  String get nutritionMealBreakfast => 'الفطور';

  @override
  String get nutritionMealLunch => 'الغداء';

  @override
  String get nutritionMealDinner => 'العشاء';

  @override
  String get nutritionMealSnacks => 'وجبات خفيفة';

  @override
  String get nutritionSearchPlaceholder => 'ابحث عن طعام أو أطباق جزائرية...';

  @override
  String get nutritionCategories => 'التصنيفات';

  @override
  String get nutritionCategoryAll => 'الكل';

  @override
  String get nutritionCategoryStaples => 'حبوب ونشويات';

  @override
  String get nutritionCategoryProtein => 'لحوم وأسماك';

  @override
  String get nutritionCategoryDairy => 'ألبان وبيض';

  @override
  String get nutritionCategoryProduce => 'فواكه وخضار';

  @override
  String get nutritionCategoryAlgerian => 'أطباق جزائرية';

  @override
  String get nutritionCategorySnacks => 'بقوليات ومكسرات';

  @override
  String get nutritionRecent => 'الأطعمة الأخيرة';

  @override
  String get nutritionFavorites => 'المفضلة';

  @override
  String get nutritionCustom => 'أطعمة مخصصة';

  @override
  String get nutritionAddCustomFood => 'إضافة طعام مخصص';

  @override
  String get nutritionRecipes => 'الوصفات';

  @override
  String get nutritionCreateRecipe => 'إنشاء وصفة';

  @override
  String get nutritionServingSize => 'حجم الحصة';

  @override
  String get nutritionQuantity => 'الكمية (بالغرام)';

  @override
  String get nutritionSelectMeal => 'اختر الوجبة';

  @override
  String get nutritionSaveLog => 'إضافة إلى السجل';

  @override
  String get nutritionDeleteLog => 'حذف الإدخال';

  @override
  String get nutritionCaloriesPer100g => 'السعرات (لكل 100غ)';

  @override
  String get nutritionProteinPer100g => 'البروتين (لكل 100غ)';

  @override
  String get nutritionCarbsPer100g => 'الكربوهيدرات (لكل 100غ)';

  @override
  String get nutritionFatPer100g => 'الدهون (لكل 100غ)';

  @override
  String get nutritionFiberPer100g => 'الألياف (لكل 100غ)';

  @override
  String get nutritionFoodName => 'اسم الطعام';

  @override
  String get nutritionFoodNameArabic => 'اسم الطعام بالعربية';

  @override
  String get nutritionState => 'حالة التحضير (مثلاً: ناضج، غير مطبوخ)';

  @override
  String get nutritionSource => 'المصدر / درجة الموثوقية';

  @override
  String get nutritionVerified => 'موثوق';

  @override
  String get nutritionEstimated => 'تقديري';

  @override
  String get nutritionUserAdded => 'مخصص';

  @override
  String get nutritionNoLogs => 'لم تسجل أي طعام اليوم بعد. اضغط \'+\' للبدء!';

  @override
  String nutritionTotalCalories(int calories) {
    return '$calories سعرة';
  }

  @override
  String get recipeTitle => 'منشئ الوصفات';

  @override
  String get recipeName => 'اسم الوصفة';

  @override
  String get recipeServings => 'عدد الحصص';

  @override
  String get recipeTotalCookedYield => 'الوزن الكلي بعد الطهي (غرام، اختياري)';

  @override
  String get recipeYieldHelp =>
      'فقدان أو امتصاص الماء أثناء الطهي يغير الوزن الكلي.';

  @override
  String get recipeIngredients => 'المكونات';

  @override
  String get recipeAddIngredient => 'إضافة مكوّن';

  @override
  String recipePerServing(int cal, String p, String c, String f) {
    return 'لكل حصة: $cal سعرة | ب: $pغ | ك: $cغ | د: $fغ';
  }

  @override
  String get recipeSave => 'حفظ الوصفة';

  @override
  String get workoutsTitle => 'التمارين';

  @override
  String get workoutsPrograms => 'برامج التدريب';

  @override
  String get workoutsCreateProgram => 'برنامج جديد';

  @override
  String get workoutsProgramName => 'اسم البرنامج';

  @override
  String get workoutsProgramDesc => 'الوصف';

  @override
  String workoutsDays(String days) {
    return 'الأيام: $days';
  }

  @override
  String get workoutsExercises => 'التمارين';

  @override
  String get workoutsAddExercise => 'إضافة تمرين';

  @override
  String get workoutsExerciseLibrary => 'مكتبة التمارين';

  @override
  String get workoutsMuscleGroup => 'العضلة المستهدفة';

  @override
  String get workoutsEquipment => 'الأداة / الجهاز';

  @override
  String workoutsTargetSets(int sets, int reps) {
    return 'المجموعات المستهدفة: $sets × $reps تكرار';
  }

  @override
  String get workoutsActiveSession => 'التمرين الجاري';

  @override
  String get workoutsRestTimer => 'مؤقت الراحة';

  @override
  String workoutsRestTimeRemaining(int seconds) {
    return 'متبقي $seconds ثانية راحة';
  }

  @override
  String get workoutsSetHeader => 'المجموعة';

  @override
  String get workoutsWeightHeader => 'كغ';

  @override
  String get workoutsRepsHeader => 'تكرارات';

  @override
  String get workoutsCompletedHeader => 'تم';

  @override
  String get workoutsAddSet => 'إضافة جولة';

  @override
  String get workoutsSkipExercise => 'تخطي التمرين';

  @override
  String get workoutsFinishWorkout => 'إنهاء التمرين';

  @override
  String get workoutsDiscardWorkout => 'إلغاء التمرين';

  @override
  String get workoutsConfirmFinish => 'هل ترغب في إنهاء وحفظ جلسة التمرين هذه؟';

  @override
  String get workoutsConfirmDiscard =>
      'هل أنت متأكد من إلغاء جلسة التمرين دون حفظ؟';

  @override
  String get workoutsSessionCompleted => 'ملخص التمرين';

  @override
  String workoutsDuration(int minutes) {
    return 'المدة: $minutes دقيقة';
  }

  @override
  String workoutsTotalVolume(String volume) {
    return 'الحجم الإجمالي: $volume كغ';
  }

  @override
  String workoutsTotalSets(int sets) {
    return 'الجولات المكتملة: $sets';
  }

  @override
  String get workoutsHistory => 'سجل التمارين';

  @override
  String get workoutsNoHistory =>
      'لا توجد تمارين مكتملة بعد. ابدأ جلستك الأولى!';

  @override
  String get workoutsPR => 'رقم قياسي جديد!';

  @override
  String get progressTitle => 'التقدم والمقاييس';

  @override
  String get progressWeightHistory => 'مسار وزن الجسم';

  @override
  String get progressAddMetric => 'تسجيل قياس جديد';

  @override
  String get progressWaist => 'محيط الخصر (سم)';

  @override
  String get progressDate => 'التاريخ';

  @override
  String get progressTimeRange1M => 'شهر واحد';

  @override
  String get progressTimeRange3M => '3 أشهر';

  @override
  String get progressTimeRangeAll => 'كل الأوقات';

  @override
  String progressWeeklyAverage(String avg) {
    return 'المتوسط الأسبوعي المتحرك: $avg كغ';
  }

  @override
  String get progressExercisePRs => 'الأرقام القياسية في التمارين';

  @override
  String get progressNoMetrics =>
      'لم يتم تسجيل أي قياسات بعد. سجّل وزنك بانتظام لمتابعة التطور!';

  @override
  String get profileTitle => 'الملف والإعدادات';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileGoals => 'الأهداف والاحتياجات';

  @override
  String get profileEditGoals => 'تعديل الأهداف';

  @override
  String get profileAppearance => 'المظهر';

  @override
  String get profileThemeSystem => 'افتراضي النظام';

  @override
  String get profileThemeLight => 'الوضع الفاتح';

  @override
  String get profileThemeDark => 'الوضع الداكن';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileLanguageAr => 'العربية';

  @override
  String get profileUnits => 'الوحدات';

  @override
  String get profileUnitsMetric => 'متري (كغ، سم)';

  @override
  String get profileUnitsImperial => 'إمبراطوري (باوند، إنش)';

  @override
  String get profileData => 'البيانات والخصوصية';

  @override
  String get profileExportJson => 'تصدير البيانات (JSON)';

  @override
  String get profileResetData => 'مسح جميع البيانات';

  @override
  String get profileResetConfirm =>
      'هل أنت متأكد تماماً؟ سيؤدي ذلك إلى حذف كافة الوجبات والتمارين والقياسات المخزنة.';

  @override
  String get profileAbout => 'عن رفيق اللياقة';

  @override
  String get profileAboutText =>
      'رفيق اللياقة هو تطبيق شخصي لتتبع التمارين والتغذية يعمل بشكل كامل ومستقل دون إنترنت وبأعلى درجات الخصوصية.';

  @override
  String get profileOfflineStatus =>
      'يعمل محلياً بالكامل 100%: تُحفظ بياناتك حصراً على جهازك.';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonDone => 'تم';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonFilter => 'تصفية';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonError => 'حدث خطأ ما';

  @override
  String get commonSuccess => 'تمت العملية بنجاح';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonLoading => 'جارِ التحميل...';

  @override
  String get commonKcal => 'سعرة';

  @override
  String get commonGrams => 'غ';

  @override
  String get commonKg => 'كغ';

  @override
  String get commonCm => 'سم';

  @override
  String get commonReps => 'تكرارات';

  @override
  String get commonSets => 'جولات';

  @override
  String get nutritionCalculatorTitle => 'حاسبة الاحتياجات الغذائية';

  @override
  String get nutritionCalculatorDesc =>
      'احسب احتياجك اليومي من السعرات والمغذيات بدقة وفق معادلات علمية معتمدة ومخصصة لجسمك.';

  @override
  String get nutritionCalculatorBmr => 'معدل الأيض الأساسي (BMR)';

  @override
  String get nutritionCalculatorBmrDesc =>
      'السعرات التي يستهلكها جسمك أثناء الراحة التامة للحفاظ على وظائف الأعضاء الحيوية.';

  @override
  String get nutritionCalculatorTdee => 'الاحتياج اليومي الكلي للطاقة (TDEE)';

  @override
  String get nutritionCalculatorTdeeDesc =>
      'معدل الأيض الأساسي مضروباً في معامل نشاطك البدني والتمارين.';

  @override
  String get nutritionCalculatorTarget => 'الهدف اليومي المقترح';

  @override
  String get nutritionCalculatorHow => 'كيف تم حساب هذه الاحتياجات؟';

  @override
  String get nutritionCalculatorFormula => 'معادلة ميفلين - سانت جور';

  @override
  String get nutritionCalculatorManualAdjust => 'تعديل الأهداف يدوياً';

  @override
  String get nutritionCalculatorReset => 'استعادة القيم الموصى بها';

  @override
  String get nutritionCalculatorApply => 'تطبيق الأهداف على ملفي الشخصي';

  @override
  String get nutritionCalculatorConfirm =>
      'هل ترغب في تحديث أهدافك اليومية؟ سيتم تطبيق هذه القيم فوراً على لوحة التحكم وسجل التغذية.';

  @override
  String get nutritionCalculatorMacroWarning =>
      'تنبيه: مجموع سعرات المغذيات (بروتين×4 + كربوهيدرات×4 + دهون×9) لا يطابق إجمالي السعرات المستهدفة.';

  @override
  String get nutritionTrainingType => 'نوع التدريب الأساسي';

  @override
  String get nutritionTrainingStrength => 'بناء الأجسام والقوة (هايبرتروفي)';

  @override
  String get nutritionTrainingCardio => 'تمارين هوائية وتحمل (كارديو)';

  @override
  String get nutritionTrainingHybrid => 'تمارين وظيفية وهجينة';

  @override
  String get nutritionTrainingGeneral => 'صحة عامة ولياقة خفيفة';

  @override
  String get academyTitle => 'أكاديمية التغذية';

  @override
  String get academySubtitle =>
      'تعلّم أسرار التغذية وحساب السعرات خطوة بخطوة مع دروس مبسطة وتمارين تفاعلية.';

  @override
  String academyLesson(int number) {
    return 'الدرس $number';
  }

  @override
  String get academyQuiz => 'اختبار الفهم';

  @override
  String get academyCompleted => 'مكتمل';

  @override
  String get academyTakeaway => 'خلاصة عملية';

  @override
  String get academyInteractiveTool => 'أداة حساب تفاعلية';

  @override
  String academyScore(int score) {
    return 'النتيجة: $score%';
  }

  @override
  String get foodCalculatorTitle => 'الحاسبة الذكية للأطعمة';

  @override
  String get foodCalculatorSubtitle =>
      'احسب القيم الغذائية الدقيقة بناءً على وزن الحصة وحالة التحضير (مطبوخ / نيء).';

  @override
  String get foodCalculatorServingType => 'الحصة وحالة التحضير';

  @override
  String get foodCalculatorFormulaHelp =>
      'المعادلة: (القيمة لكل 100غ × عدد الغرامات) ÷ 100';

  @override
  String get foodCalculatorAddToMeal => 'تسجيل الطعام المحسوب';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'نهارك سعيد';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get dashboardKcalLeft => 'سعرة متبقية';

  @override
  String get dashboardKcalOver => 'سعرة زائدة';

  @override
  String get dashboardGoal => 'الهدف';

  @override
  String get dashboardInProgress => 'قيد التنفيذ';

  @override
  String get dashboardWeekActivity => 'نشاط الأسبوع';

  @override
  String get dashboardTools => 'الأدوات والتعلّم';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonMl => 'مل';

  @override
  String get commonToday => 'اليوم';

  @override
  String get waterTitle => 'شرب الماء';

  @override
  String waterProgress(int amount, int goal) {
    return '$amount / $goal مل';
  }

  @override
  String get waterGoalReached => 'وصلت لهدف الماء اليومي!';

  @override
  String get waterSetGoal => 'هدف الماء اليومي';

  @override
  String get waterUndo => 'إزالة 250 مل';

  @override
  String get statsThisWeek => 'هذا الأسبوع';

  @override
  String get statsWorkouts => 'تمارين';

  @override
  String get statsVolume => 'الحجم';

  @override
  String get statsStreak => 'أيام متتالية';

  @override
  String get statsTotal => 'مجموع الحصص';

  @override
  String academyLessonsCount(int count) {
    return '$count درساً';
  }

  @override
  String get calculatorBmrTdee => 'الأيض والطاقة';

  @override
  String get portionScaler => 'حاسبة الحصص';

  @override
  String get workoutsNoActive => 'لا توجد حصة تدريب نشطة.';

  @override
  String get workoutsElapsed => 'المدة';

  @override
  String get workoutsPrevious => 'المرة السابقة';

  @override
  String get workoutsRest => 'راحة';

  @override
  String get workoutsSkip => 'تخطي';

  @override
  String get workoutsNewPR => 'رقم قياسي شخصي جديد! 🏆';

  @override
  String get workoutsDeleteSet => 'حذف المجموعة';

  @override
  String get workoutsRestDone => 'انتهت الراحة — المجموعة التالية!';

  @override
  String get workoutsQuickStart => 'تمرين سريع';

  @override
  String get workoutsQuickStartDesc =>
      'ابدأ فارغاً وأضف التمارين أثناء التدريب';

  @override
  String get workoutsEmptySession => 'أضف أول تمرين لبدء تسجيل المجموعات.';

  @override
  String get workoutsStart => 'ابدأ';

  @override
  String workoutsExercisesCount(int count) {
    return '$count تمارين';
  }

  @override
  String get workoutsNoProgramsYet => 'لم يتم إنشاء أي برنامج بعد.';

  @override
  String get workoutsSearchExercise => 'ابحث عن تمرين';

  @override
  String get sessionDetailTitle => 'ملخص التمرين';

  @override
  String get sessionDelete => 'حذف التمرين';

  @override
  String get sessionDeleteConfirm =>
      'حذف هذا التمرين من السجل؟ لا يمكن التراجع عن ذلك.';

  @override
  String sessionMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get progressRecentLogs => 'آخر التسجيلات';

  @override
  String get progressNoPRs =>
      'أكمل مجموعات التمرين لتسجيل أرقامك القياسية في القوة!';

  @override
  String get progressEst1RM => '1RM تقديري';

  @override
  String get progressCurrent => 'الحالي';

  @override
  String get progressChange => 'التغيّر';

  @override
  String get progressBmi => 'مؤشر الكتلة';

  @override
  String progressSetFormat(String weight, int reps) {
    return '$weight كغ × $reps';
  }

  @override
  String get toolsTitle => 'أدوات الجيم';

  @override
  String get tools1RM => 'حاسبة 1RM';

  @override
  String get tools1RMDesc => 'قدّر أقصى وزن لك وأوزان التدريب';

  @override
  String get toolsPlates => 'حاسبة الأقراص';

  @override
  String get toolsPlatesDesc => 'الأقراص المطلوبة على كل جهة من البار';

  @override
  String get toolsWeightKg => 'الوزن (كغ)';

  @override
  String get toolsReps => 'التكرارات';

  @override
  String get toolsTargetKg => 'الوزن المستهدف (كغ)';

  @override
  String get toolsBarKg => 'البار (كغ)';

  @override
  String get toolsPerSide => 'لكل جهة';

  @override
  String toolsRemainder(String kg) {
    return 'لا يمكن التحميل بدقة — ينقص $kg كغ';
  }

  @override
  String get toolsOnlyBar => 'البار فارغ فقط';

  @override
  String get toolsPercentOf1RM => '% من 1RM';

  @override
  String get nutritionMealEmpty => 'لا شيء مسجّل بعد — اضغط + لإضافة طعام';

  @override
  String get nutritionMacros => 'المغذيات الكبرى';

  @override
  String get mealsCopyYesterdayHint =>
      'لا شيء مسجّل في هذا اليوم. نسخ وجبات الأمس؟';

  @override
  String get mealsCopy => 'نسخ';

  @override
  String mealsCopied(int count) {
    return 'تم نسخ $count عنصر';
  }

  @override
  String get mealsNothingToCopy => 'لا يوجد شيء للنسخ';

  @override
  String get mealsCopyFromYesterday => 'نسخ من الأمس';

  @override
  String get mealsUseTemplate => 'إضافة من قالب';

  @override
  String get mealsSaveTemplate => 'حفظ كقالب';

  @override
  String get mealsTemplateName => 'اسم القالب';

  @override
  String get mealsTemplateSaved => 'تم حفظ القالب';

  @override
  String get mealsTemplates => 'قوالب الوجبات';

  @override
  String get mealsNoTemplates =>
      'لا توجد قوالب بعد. افتح قائمة الوجبة (⋮) واختر \"حفظ كقالب\".';

  @override
  String get setsSuperset => 'سوبرسيت';

  @override
  String get setsSupersetWithNext => 'سوبرسيت مع التمرين التالي';

  @override
  String get setsRemoveSuperset => 'إلغاء السوبرسيت';

  @override
  String get setTypeTitle => 'نوع المجموعة';

  @override
  String get setTypeNormal => 'عادية';

  @override
  String get setTypeWarmup => 'إحماء';

  @override
  String get setTypeDrop => 'دروب سيت';

  @override
  String get setTypeFailure => 'حتى الفشل';

  @override
  String get rpeHelp =>
      'RPE = مدى صعوبة المجموعة. 10 = لم يتبقَّ أي تكرار، 8 = بقي تكراران. مجموعات الإحماء لا تُحسب في الحجم ولا في الأرقام القياسية.';

  @override
  String get commonClear => 'مسح';

  @override
  String overloadIncrease(String kg) {
    return 'زِد $kg كغ اليوم';
  }

  @override
  String get overloadKeep => 'نفس الوزن — حاول تزيد التكرارات';

  @override
  String overloadDeload(String kg) {
    return 'خفّف إلى $kg كغ';
  }

  @override
  String get exerciseProgress => 'تطور التمرين';

  @override
  String get exerciseTopWeight => 'أعلى وزن';

  @override
  String get exerciseNoHistory =>
      'لا توجد مجموعات مكتملة لهذا التمرين بعد. أكمل تمريناً يحتويه لرؤية مخطط تطورك.';

  @override
  String get heatmapTitle => 'العضلات هذا الأسبوع';

  @override
  String get heatmapHelp =>
      'المجموعات الفعّالة خلال آخر 7 أيام. من 10 إلى 20 مجموعة لكل عضلة أسبوعياً هو النطاق المثالي للنمو (أخضر). البرتقالي = حجم مرتفع جداً.';

  @override
  String get muscleChest => 'الصدر';

  @override
  String get muscleBack => 'الظهر';

  @override
  String get muscleLegs => 'الأرجل';

  @override
  String get muscleShoulders => 'الأكتاف';

  @override
  String get muscleArms => 'الذراعان';

  @override
  String get muscleCore => 'البطن والجذع';

  @override
  String get achTitle => 'الإنجازات';

  @override
  String get achSubtitle =>
      'اربح الشارات بالتمرين المنتظم والأكل الجيد وتحطيم أرقامك.';

  @override
  String get achNext => 'التالي';

  @override
  String get achUnlocked => 'إنجاز جديد';

  @override
  String get achFirstWorkout => 'الخطوة الأولى';

  @override
  String get achFirstWorkoutDesc => 'أكمل أول تمرين لك.';

  @override
  String get achWorkouts10 => 'منتظم';

  @override
  String get achWorkouts50 => 'مثابر';

  @override
  String get achWorkouts100 => 'أسطورة الحديد';

  @override
  String achWorkoutsDesc(int count) {
    return 'أكمل $count تمريناً.';
  }

  @override
  String get achStreak3 => 'مشتعل';

  @override
  String get achStreak7 => 'أسبوع لا يتوقف';

  @override
  String get achStreak30 => 'آلة';

  @override
  String achStreakDesc(int count) {
    return 'تمرّن $count أيام متتالية.';
  }

  @override
  String get achFirstPr => 'محطّم الأرقام';

  @override
  String get achFirstPrDesc => 'سجّل أول رقم قياسي شخصي.';

  @override
  String get achPrs25 => 'صائد الأرقام';

  @override
  String achPrsDesc(int count) {
    return 'سجّل $count رقماً قياسياً.';
  }

  @override
  String get achFood7 => 'آكل واعٍ';

  @override
  String get achFood30 => 'محترف التغذية';

  @override
  String achFoodDesc(int count) {
    return 'سجّل طعامك في $count أيام مختلفة.';
  }

  @override
  String get achWater7 => 'مرتوٍ';

  @override
  String achWaterDesc(int count) {
    return 'حقّق هدف الماء في $count أيام.';
  }

  @override
  String get achWeigh10 => 'متابع';

  @override
  String achWeighDesc(int count) {
    return 'سجّل وزنك $count مرات.';
  }

  @override
  String get achVolume10t => '10 أطنان';

  @override
  String get achVolume100t => '100 طن';

  @override
  String achVolumeDesc(String tonnes) {
    return 'ارفع $tonnes طن من الحجم الإجمالي.';
  }

  @override
  String get measureTitle => 'قياسات الجسم';

  @override
  String get measureMore => 'قياسات إضافية (اختياري)';

  @override
  String get measureChest => 'الصدر';

  @override
  String get measureArm => 'الذراع';

  @override
  String get measureThigh => 'الفخذ';

  @override
  String get measureHips => 'الورك';

  @override
  String get measureBodyFat => 'نسبة الدهون';

  @override
  String get measureSaved => 'تم حفظ القياس';

  @override
  String get profileFeatures => 'الأدوات والمزامنة';

  @override
  String get scanTitle => 'مسح الباركود';

  @override
  String get scanHint => 'وجّه الكاميرا نحو باركود المنتج';

  @override
  String scanLooking(String code) {
    return 'جارٍ البحث عن $code…';
  }

  @override
  String get scanOffline =>
      'لا يوجد إنترنت — البحث عن المنتج يحتاج اتصالاً في المرة الأولى.';

  @override
  String get scanNotFound => 'المنتج غير موجود';

  @override
  String scanNotFoundBody(String code) {
    return 'الباركود $code غير موجود في قاعدة البيانات. يمكنك إضافته كطعام مخصص.';
  }

  @override
  String get scanAgain => 'مسح مرة أخرى';

  @override
  String get scanCameraError =>
      'الكاميرا غير متاحة. اسمح بالوصول للكاميرا من إعدادات الهاتف.';

  @override
  String get remTitle => 'التذكيرات';

  @override
  String get remSubtitle => 'تذكيرات ذكية تعمل حتى والتطبيق مغلق.';

  @override
  String get remWaterTitle => 'اشرب الماء';

  @override
  String get remWaterBody => 'حان وقت كأس ماء 💧';

  @override
  String get remMealTitle => 'سجّل وجبتك';

  @override
  String get remWorkoutTitle => 'وقت التمرين';

  @override
  String get remWorkoutBody => 'هيا نتمرن اليوم 💪';

  @override
  String get remWeighTitle => 'وزن الصباح';

  @override
  String get remWeighBody => 'زِن نفسك قبل الفطور لأدق متابعة.';

  @override
  String get remEvery => 'كل';

  @override
  String remHours(int h) {
    return '$h ساعة';
  }

  @override
  String get remFromTo => 'من – إلى';

  @override
  String get remTime => 'الوقت';

  @override
  String get remPermissionDenied =>
      'الإشعارات محظورة. فعّلها من إعدادات الهاتف.';

  @override
  String get remWatchInfo =>
      'مؤقت الراحة يظهر كإشعار عدّ تنازلي مباشر. إذا كانت ساعتك (Wear OS أو Galaxy Watch أو Mi Band…) تعرض إشعارات الهاتف، فستعرض المؤقت وتهتز عند انتهاء الراحة.';

  @override
  String get backupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupSubtitle =>
      'احفظ كل بياناتك في ملف واحد (أرسله إلى Google Drive أو Telegram أو البريد…) واستعده على أي هاتف.';

  @override
  String get backupExport => 'إنشاء نسخة احتياطية';

  @override
  String get backupExportDesc => 'يصدّر ملف .json ويفتح قائمة المشاركة';

  @override
  String get backupRestore => 'استعادة نسخة';

  @override
  String get backupRestoreDesc =>
      'اختر ملف النسخة — يستبدل البيانات الموجودة على هذا الهاتف';

  @override
  String get backupRestoreConfirm =>
      'سيتم استبدال كل البيانات الحالية على هذا الهاتف بالنسخة الاحتياطية. متابعة؟';

  @override
  String get backupRestored => 'تمت الاستعادة ✓';

  @override
  String get backupInvalid => 'هذا الملف ليس نسخة احتياطية من Fit Companion.';

  @override
  String get backupPhotosNote =>
      'ملاحظة: صور التقدم تبقى على الهاتف ولا تُضمَّن في ملف النسخة.';

  @override
  String get photosTitle => 'صور التقدم';

  @override
  String get photosAdd => 'إضافة صورة';

  @override
  String get photosCamera => 'التقاط صورة';

  @override
  String get photosGallery => 'اختيار من المعرض';

  @override
  String get photosFront => 'أمامي';

  @override
  String get photosSide => 'جانبي';

  @override
  String get photosBack => 'خلفي';

  @override
  String get photosCompare => 'قبل / بعد';

  @override
  String get photosBefore => 'قبل';

  @override
  String get photosAfter => 'بعد';

  @override
  String get photosEmpty =>
      'التقط صورة كل 2–4 أسابيع بنفس الإضاءة والوضعية لترى تغيّرك الحقيقي.';

  @override
  String get photosPrivacy =>
      '🔒 الصور خاصة وتُحفظ على هذا الهاتف فقط. لا تخرج منه إلا إذا طلبت تحليلاً بالذكاء الاصطناعي (تؤكد في كل مرة).';

  @override
  String get photosDelete => 'حذف هذه الصورة؟';

  @override
  String get healthTitle => 'Health Connect';

  @override
  String get healthSubtitle =>
      'اربط Health Connect في أندرويد لقراءة خطواتك اليومية وحفظ وزنك هناك تلقائياً.';

  @override
  String get healthUnavailable =>
      'Health Connect غير متاح على هذا الهاتف (يحتاج أندرويد 9+ وليس ملف عمل).';

  @override
  String get healthNeedsInstall =>
      'ثبّت أو حدّث تطبيق Health Connect من Google Play أولاً.';

  @override
  String get healthInstall => 'فتح Google Play';

  @override
  String get healthConnected => 'متصل';

  @override
  String get healthNotConnected => 'غير متصل';

  @override
  String get healthWhat => 'يقرأ: الخطوات • يكتب: وزن الجسم';

  @override
  String get healthConnect => 'ربط Health Connect';

  @override
  String get healthStepsToday => 'خطوات اليوم';

  @override
  String get cloudTitle => 'المزامنة السحابية';

  @override
  String get coachTitle => 'المدرب الذكي';

  @override
  String get cloudSubtitle =>
      'احفظ بياناتك بأمان في السحابة وانقلها بين الهواتف. مجاني، بحسابك الخاص.';

  @override
  String get cloudUnavailable =>
      'السحابة غير متاحة الآن (لا إنترنت عند فتح التطبيق). أعد فتح التطبيق مع الإنترنت.';

  @override
  String get cloudSignIn => 'تسجيل الدخول';

  @override
  String get cloudCreateAccount => 'إنشاء حساب';

  @override
  String get cloudEmail => 'البريد الإلكتروني';

  @override
  String get cloudPassword => 'كلمة المرور (6 أحرف على الأقل)';

  @override
  String get cloudInvalidForm =>
      'أدخل بريداً صحيحاً وكلمة مرور من 6 أحرف على الأقل.';

  @override
  String get cloudConfirmEmail =>
      'تم إنشاء الحساب. افتح بريدك لتأكيده ثم سجّل الدخول.';

  @override
  String get cloudSignedIn => 'تم تسجيل الدخول ✓';

  @override
  String get cloudSignOut => 'تسجيل الخروج';

  @override
  String get cloudLastSync => 'آخر مزامنة';

  @override
  String get cloudCloudCopy => 'النسخة السحابية';

  @override
  String get cloudRemoteNewer =>
      'النسخة السحابية أحدث من هذا الهاتف (رُفعت من جهاز آخر). نزّلها، أو ارفع بياناتك لاستبدالها.';

  @override
  String get cloudUpload => 'رفع';

  @override
  String get cloudDownload => 'تنزيل';

  @override
  String get cloudUploadOverwrite =>
      'سيتم استبدال النسخة السحابية الأحدث ببيانات هذا الهاتف. متابعة؟';

  @override
  String get cloudDownloadOverwrite =>
      'سيتم استبدال كل بيانات هذا الهاتف بالنسخة السحابية. متابعة؟';

  @override
  String get cloudUploaded => 'تم الرفع إلى السحابة ✓';

  @override
  String get cloudDownloaded => 'تمت استعادة البيانات من السحابة ✓';

  @override
  String get cloudAuto => 'نسخ احتياطي تلقائي';

  @override
  String get cloudAutoDesc =>
      'يرفع عند الخروج من التطبيق (ولا يستبدل نسخة سحابية أحدث أبداً).';

  @override
  String get cloudPrivacy =>
      '🔒 كل حساب يقرأ بياناته فقط (Row Level Security). صور التقدم لا تُرفع أبداً. المشاريع المجانية تتوقف مؤقتاً بعد أسبوع تقريباً دون استعمال وتعود عند المزامنة التالية.';

  @override
  String get coachTagline => 'نصائح شخصية مبنية على بياناتك';

  @override
  String get coachIntro =>
      'اسأل عن التمرين أو التغذية أو تقدمك. المدرب يرى ملخصاً قصيراً لبياناتك (المتوسطات، الأهداف، أفضل الأرقام) وليس سجلاتك الكاملة. وهو ليس طبيباً.';

  @override
  String get coachHint => 'اسأل مدربك…';

  @override
  String get coachClear => 'مسح المحادثة';

  @override
  String get coachNeedsAccount =>
      'المدرب الذكي يحتاج حساباً سحابياً مجانياً (تُحفظ المحادثة فيه).';

  @override
  String get coachSuggest1 => 'حلّل أسبوعي الماضي';

  @override
  String get coachSuggest2 => 'كم أحتاج من البروتين؟';

  @override
  String get coachSuggest3 => 'لماذا وزني لا يتغير؟';

  @override
  String get coachSuggest4 => 'اقترح عشاء جزائري غني بالبروتين';

  @override
  String get coachErrNoKey =>
      'المدرب غير مُعدّ بعد: يجب إضافة مفتاح Gemini في Supabase (Edge Functions → Secrets → GEMINI_API_KEY).';

  @override
  String get coachErrLimit => 'وصلت للحد اليومي (40 رسالة). حاول غداً.';

  @override
  String get coachErrQuota => 'انتهت حصة Gemini المجانية حالياً. حاول لاحقاً.';

  @override
  String get coachErrGeneric => 'لم يتمكن المدرب من الرد. حاول مرة أخرى.';

  @override
  String get coachErrNetwork => 'لا يوجد اتصال بالمدرب. تحقق من الإنترنت.';

  @override
  String get coachErrModel =>
      'اسم نموذج الذكاء الاصطناعي غير متاح. اضبط GEMINI_MODEL في أسرار Supabase (مثلاً gemini-3.8-flash).';

  @override
  String get coachErrBusy =>
      'خوادم الذكاء الاصطناعي مشغولة حالياً. انتظر بضع ثوانٍ وحاول مرة أخرى.';

  @override
  String get muscleCardio => 'كارديو';

  @override
  String get equipBarbell => 'بار';

  @override
  String get equipDumbbell => 'دمبل';

  @override
  String get equipMachine => 'آلة';

  @override
  String get equipCable => 'كابل';

  @override
  String get equipBodyweight => 'وزن الجسم';

  @override
  String get equipKettlebell => 'كيتلبل';

  @override
  String get equipOther => 'أخرى';

  @override
  String get exerciseCreateCustom => 'إضافة تمرين خاص بي';

  @override
  String get exerciseCreateCustomHint => 'لم تجده؟ أنشئه في ثوانٍ';

  @override
  String get exerciseNotFound =>
      'لا يوجد تمرين بهذا الاسم. استعمل \"إضافة تمرين خاص بي\" في الأعلى.';

  @override
  String get exerciseName => 'اسم التمرين';

  @override
  String get exerciseCompound => 'مركّب';

  @override
  String get exerciseIsolation => 'عزل';

  @override
  String get exerciseNotesOptional => 'ملاحظات / طريقة الأداء (اختياري)';

  @override
  String get exerciseCreated => 'تمت إضافة التمرين ✓';

  @override
  String get programEdit => 'تعديل البرنامج';

  @override
  String get programNameRequired => 'أعطِ برنامجك اسماً';

  @override
  String get programNeedsExercise => 'أضف تمريناً واحداً على الأقل';

  @override
  String get programSaved => 'تم حفظ البرنامج ✓';

  @override
  String get programNameHint => 'مثال: Upper A، Lower B، ذراعين وبطن';

  @override
  String get programReorderHint => 'اسحب ⋮⋮ لإعادة الترتيب';

  @override
  String get programEmptyHint =>
      'لا توجد تمارين بعد. اضغط \"إضافة تمرين\" لبناء حصتك.';

  @override
  String get programDeleteConfirm =>
      'حذف هذا البرنامج؟ سجل تمارينك يبقى محفوظاً.';

  @override
  String get programsEmptyTitle => 'ابنِ برنامجك الخاص';

  @override
  String get programsEmptyBody =>
      'أنشئ برنامجاً لكل يوم تدريب، مثلاً \"Upper A\" و\"Lower A\" و\"Upper B\" و\"Lower B\" و\"ذراعين وبطن\". أضف فقط التمارين التي تريدها.';

  @override
  String get templatesTitle => 'برامج جاهزة';

  @override
  String get templatesSubtitle =>
      'PPL و Upper/Lower و Full Body و 5/3/1 — انسخ واحداً وعدّله كما تريد';

  @override
  String get templateUse => 'أضف إلى برامجي وعدّله';

  @override
  String get templateCopied => 'تم النسخ إلى برامجك — عدّله كما تريد';

  @override
  String get templateBadge => 'قالب جاهز';

  @override
  String get foodsMine => 'أكلاتي';

  @override
  String get foodsSuggestions => 'اقتراحات';

  @override
  String get foodsAddMine => 'إضافة أكلة خاصة بي';

  @override
  String get foodsMineEmptyTitle => 'قائمة أكلاتك فارغة';

  @override
  String get foodsMineEmptyBody =>
      'أضف ما تأكله فعلاً: اكتب الاسم ووصفاً قصيراً والوزن — والذكاء الاصطناعي يحسب السعرات والبروتين والكربوهيدرات والدهون. الأكلات الجاهزة موجودة في \"اقتراحات\".';

  @override
  String get foodsDeleteConfirm =>
      'حذف هذه الأكلة من قائمتك؟ السجلات السابقة تبقى.';

  @override
  String get myFoodName => 'اسم الأكلة';

  @override
  String get myFoodNameHint => 'مثال: كسكس بالدجاج';

  @override
  String get myFoodDescription => 'الوصف (المكونات، طريقة الطهي)';

  @override
  String get myFoodDescriptionHint =>
      'مثال: 150غ كسكس مطبوخ، 120غ صدر دجاج، خضر، ملعقة زيت زيتون';

  @override
  String get myFoodWeight => 'وزن الحصة';

  @override
  String get myFoodAnalyze => 'احسب بالذكاء الاصطناعي';

  @override
  String get myFoodAnalyzing => 'جارٍ التحليل…';

  @override
  String get myFoodNeedNameWeight => 'أدخل اسم الأكلة ووزنها.';

  @override
  String get myFoodNeedValues =>
      'احسب بالذكاء الاصطناعي أو أدخل السعرات يدوياً.';

  @override
  String get myFoodNeedAccount =>
      'الحساب بالذكاء الاصطناعي يحتاج حساباً مجانياً (حسابي → المزامنة السحابية). يمكنك أيضاً كتابة القيم بنفسك.';

  @override
  String get myFoodConfHigh => 'دقة عالية';

  @override
  String get myFoodConfMedium => 'دقة متوسطة';

  @override
  String get myFoodConfLow => 'دقة منخفضة — أضف تفاصيل';

  @override
  String get myFoodPer100 => 'لكل 100غ';

  @override
  String myFoodPortionValues(String grams) {
    return 'القيم لـ $grams غ';
  }

  @override
  String get myFoodEditHint =>
      'يمكنك تصحيح أي قيمة قبل الحفظ. كلما زادت تفاصيل الوصف كانت النتيجة أدق.';

  @override
  String get myFoodLogNow => 'أضفها إلى وجبات اليوم';

  @override
  String get myFoodSaveAndLog => 'حفظ وإضافة للوجبة';

  @override
  String get myFoodSaved => 'تم حفظ الأكلة في قائمتك ✓';

  @override
  String get myFoodSavedLogged => 'تم حفظ الأكلة وإضافتها ✓';

  @override
  String get eatenQuestion => 'هل أكلتها؟';

  @override
  String get eatenYes => 'نعم — تُحسب في مجموع اليوم';

  @override
  String get eatenPlanned => 'ليس بعد — تُحفظ كمخطط لها';

  @override
  String get eatenAtTime => 'وقت الأكل';

  @override
  String get eatenMark => 'تعليم كمأكولة';

  @override
  String get eatenUndo => 'إلغاء — لم آكلها';

  @override
  String get eatenWhen => 'متى أكلتها؟';

  @override
  String get eatenAtShort => 'أُكلت على';

  @override
  String get eatenPlannedShort => 'مخطط لها — اضغط ○ عند أكلها';

  @override
  String eatenPlannedKcal(int kcal) {
    return '$kcal سعرة مخطط لها لم تؤكل بعد';
  }

  @override
  String get themesTitle => 'الثيمات والمظهر';

  @override
  String get themesColors => 'ثيمات الألوان';

  @override
  String get themesBackground => 'الخلفية المتحركة';

  @override
  String get themesAnimated => 'خلفية متحركة';

  @override
  String get themesAnimatedDesc => 'خلفية تتحرك بنعومة خلف كل الشاشات';

  @override
  String get themesInteractive => 'تتفاعل مع اللمس';

  @override
  String get themesInteractiveDesc => 'تموجات وإضاءة وجزيئات تتبع إصبعك';

  @override
  String get themesIntensity => 'الشدة';

  @override
  String get themesEffect => 'التأثير';

  @override
  String get themesBatteryNote =>
      'الحركة تعمل بـ 30 إطاراً في الثانية، وتتوقف عندما يكون التطبيق في الخلفية، وتنطفئ تلقائياً إذا فعّلت \"إزالة الرسوم المتحركة\" في إعدادات إمكانية الوصول.';

  @override
  String get fxAuto => 'افتراضي الثيم';

  @override
  String get fxNone => 'بدون';

  @override
  String get fxOrbs => 'كرات مضيئة';

  @override
  String get fxParticles => 'جزيئات';

  @override
  String get fxWaves => 'أمواج';

  @override
  String get fxGrid => 'شبكة نيون';

  @override
  String get fxAurora => 'شفق';

  @override
  String get fxBokeh => 'فقاعات';

  @override
  String get fxStars => 'نجوم';

  @override
  String get shapeSharp => 'زوايا حادة';

  @override
  String get shapeSoft => 'زوايا ناعمة';

  @override
  String get shapeRounded => 'دائري';

  @override
  String get shapePill => 'كبسولي';

  @override
  String get aboutDevelopedBy => 'تم تطويره من طرف المطور';

  @override
  String get aboutDeveloperName => 'حفيان المهدي';

  @override
  String scanAiEstimating(String name) {
    return 'تم العثور على \"$name\" — الذكاء الاصطناعي يحسب قيمه الغذائية…';
  }

  @override
  String scanNotFoundAi(String code) {
    return 'الباركود $code غير موجود في قاعدة البيانات. صوّر العلبة (ويُفضّل جدول القيم الغذائية) وسيقرأ الذكاء الاصطناعي اسم المنتج وقيمه.';
  }

  @override
  String get scanPhotoLabel => 'صوّر المنتج';

  @override
  String get scanManual => 'إدخال يدوي';

  @override
  String get scanReadingLabel => 'الذكاء الاصطناعي يقرأ المنتج…';

  @override
  String get photoTitle => 'صورة الوجبة (AI)';

  @override
  String get photoHint =>
      'صوّر طبقك أو وجبتك أو المنتج: الذكاء الاصطناعي يتعرف على الأكل ويحسب السعرات والبروتين والكربوهيدرات والدهون.';

  @override
  String get photoAnalyzing => 'جارٍ التحليل…';

  @override
  String get photoNote => 'ملاحظة للذكاء الاصطناعي (اختياري)';

  @override
  String get photoNoteHint => 'مثال: مقلي بزيت الزيتون، بيضتان، حصة كبيرة';

  @override
  String get photoNotFood =>
      'لم يتم التعرف على أكل في الصورة. جرّب زاوية أخرى يظهر فيها الطبق كاملاً.';

  @override
  String get photoResults => 'الأكلات المكتشفة';

  @override
  String get photoSuggestions => 'لتصبح أفضل';

  @override
  String photoLogged(int count) {
    return 'تمت إضافة $count عناصر إلى وجبتك ✓';
  }

  @override
  String get coachAttach => 'إرسال صورة أو فيديو';

  @override
  String get coachTakePhoto => 'التقاط صورة';

  @override
  String get coachPickPhoto => 'صورة من المعرض';

  @override
  String get coachRecordVideo => 'تسجيل فيديو (60 ثانية كحد أقصى)';

  @override
  String get coachPickVideo => 'فيديو من المعرض';

  @override
  String get coachPhotoAttached => 'صورة مرفقة';

  @override
  String get coachVideoAttached => 'فيديو';

  @override
  String get coachUploading => 'جارٍ الرفع…';

  @override
  String get coachAnalyzingVideo => 'جارٍ تحليل الفيديو (قد يستغرق دقيقة)…';

  @override
  String get coachErrMediaBig =>
      'الملف كبير جداً (40 ميغا كحد أقصى). أرسل فيديو أقصر.';

  @override
  String get coachErrUpload => 'فشل الرفع. تحقق من الإنترنت وحاول مجدداً.';

  @override
  String get coachErrMediaType =>
      'تعذر تحليل هذا النوع من الملفات. جرّب صورة أخرى أو فيديو MP4.';

  @override
  String get photosDate => 'تاريخ الصورة';

  @override
  String get photosLastWeek => 'الأسبوع الماضي';

  @override
  String get photos2Weeks => 'قبل أسبوعين';

  @override
  String get photosLastMonth => 'الشهر الماضي';

  @override
  String get photosPose => 'الوضعية';

  @override
  String get photosNeedTwo =>
      'أضف صورتين على الأقل بنفس الوضعية لمقارنتهما والحصول على تحليل بالذكاء الاصطناعي.';

  @override
  String photosDaysApart(int days) {
    return '$days يوماً بين الصورتين';
  }

  @override
  String get photosAiAnalyze => 'حلّل تقدّمي بالذكاء الاصطناعي';

  @override
  String get photosAiConsentTitle => 'إرسال هاتين الصورتين للتحليل؟';

  @override
  String get photosAiConsent =>
      'صورك خاصة وتبقى على هذا الهاتف. من أجل هذا التحليل فقط، تُرسل الصورتان المختارتان بأمان إلى Google Gemini (عبر حسابك). ولا تُحفظان في خادمنا.';

  @override
  String get photosHomeEmpty => 'أضف صور جسمك لترى تحوّلك الحقيقي';

  @override
  String photosHomeLast(int days) {
    return 'آخر صورة قبل $days يوماً';
  }

  @override
  String get photosHomeCompare =>
      'قارن قبل / بعد واحصل على تحليل لتقدمك بالذكاء الاصطناعي';

  @override
  String get aiProgressTitle => 'تحليل التقدم بالذكاء الاصطناعي';

  @override
  String get aiMuscle => 'زيادة العضلات';

  @override
  String get aiFat => 'الدهون';

  @override
  String get aiGainClear => 'واضحة';

  @override
  String get aiGainSlight => 'طفيفة';

  @override
  String get aiGainNone => 'غير ظاهرة';

  @override
  String get aiUnclear => 'غير واضح';

  @override
  String get aiFatLess => 'أقل';

  @override
  String get aiFatSame => 'نفسها';

  @override
  String get aiFatMore => 'أكثر';

  @override
  String get aiNotComparable =>
      'يصعب مقارنة الصورتين (إضاءة أو وضعية أو مسافة مختلفة).';

  @override
  String get aiAreas => 'حسب العضلة';

  @override
  String get aiTips => 'كيف تتطور أسرع';

  @override
  String get profileAthlete => 'رياضي';

  @override
  String profileYears(int age) {
    return '$age سنة';
  }

  @override
  String get profilePreferences => 'تفضيلات التطبيق';

  @override
  String get tdeeTitle => 'سعراتك الحقيقية للثبات';

  @override
  String get tdeeNeedData =>
      'سجّل وجباتك ووزنك لمدة أسبوعين تقريباً وسيحسب التطبيق سعراتك الحقيقية (TDEE).';

  @override
  String get tdeePerDay => 'سعرة / يوم';

  @override
  String tdeeExplain(int avg, String change, int days) {
    return 'أكلت $avg سعرة في المتوسط ووزنك تغيّر $change كغ/أسبوع ($days يوم مسجّل).';
  }

  @override
  String tdeeSuggest(int target, int current) {
    return 'الهدف المقترح: $target سعرة (حالياً $current)';
  }

  @override
  String get tdeeApply => 'طبّق';

  @override
  String get tdeeApplied => 'تم تحديث هدف السعرات';

  @override
  String get tdeeOnTrack => 'هدف سعراتك متوافق مع سعراتك الحقيقية';

  @override
  String get fatigueFresh => 'الاستشفاء جيد';

  @override
  String get fatigueFreshBody => 'قوتك ثابتة أو في تحسن. واصل!';

  @override
  String get fatigueWatch => 'انتبه للاستشفاء';

  @override
  String get fatigueWatchBody =>
      'هناك علامات تعب. نم جيداً، كُل كفاية ولا تزد الحجم هذا الأسبوع.';

  @override
  String get fatigueDeload => 'حان وقت أسبوع تخفيف (Deload)';

  @override
  String get fatigueDeloadBody =>
      'خفّف الأوزان بحوالي 40% والمجموعات للنصف لمدة أسبوع، ثم ارجع أقوى.';

  @override
  String fatigueReasonDeclining(int n) {
    return '$n تمارين ضعفت حصتين متتاليتين';
  }

  @override
  String get fatigueReasonRpe => 'مجهود عالٍ جداً (RPE ≥ 9) آخر أسبوعين';

  @override
  String fatigueReasonWeeks(int weeks) {
    return '$weeks أسابيع صعبة متتالية بدون راحة';
  }

  @override
  String get noteSkipped => 'تجاوزت مجموعة — ترجع تكملها؟';

  @override
  String get noteWeightDropping =>
      'وزنك الأعلى نقص حصتين متتاليتين. ارتح مليح قبل هذا التمرين.';

  @override
  String get noteMissedReps =>
      'المرة الماضية ما وصلتش للتكرارات المطلوبة. خلي نفس الوزن اليوم.';

  @override
  String noteCloseToPr(String kg) {
    return 'باقي $kg كغ فقط على رقمك القياسي — روح عليه! 🏆';
  }

  @override
  String get chTitle => 'التحديات والمستويات';

  @override
  String get chWeekly => 'هذا الأسبوع';

  @override
  String get chMonthly => 'هذا الشهر';

  @override
  String chWorkouts(int n) {
    return 'أكمل $n حصص تمرين';
  }

  @override
  String chProtein(int n) {
    return 'حقق هدف البروتين $n أيام';
  }

  @override
  String chWater(int n) {
    return 'حقق هدف الماء $n أيام';
  }

  @override
  String chLog(int n) {
    return 'سجّل أكلك $n أيام';
  }

  @override
  String chPrs(int n) {
    return 'حطّم $n أرقام قياسية';
  }

  @override
  String chVolume(String t) {
    return 'ارفع $t طن في المجموع';
  }

  @override
  String chWeigh(int n) {
    return 'سجّل وزنك $n مرات';
  }

  @override
  String get chDone => 'مكتمل';

  @override
  String chDaysLeft(int n) {
    return 'باقي $n أيام';
  }

  @override
  String get chCompleted => 'تحدٍّ مكتمل';

  @override
  String xpToNext(int xp, int level) {
    return '$xp XP للمستوى $level';
  }

  @override
  String get xpHowTitle => 'من أين تأتي نقاطك';

  @override
  String get xpWorkouts => 'الحصص (50 لكل حصة)';

  @override
  String get xpPrs => 'الأرقام القياسية (30 لكل رقم)';

  @override
  String get xpFood => 'أيام تسجيل الأكل (10)';

  @override
  String get xpWater => 'أيام هدف الماء (10)';

  @override
  String get xpWeigh => 'تسجيلات الوزن (5)';

  @override
  String get xpChallenges => 'التحديات';

  @override
  String get lvlBeginner => 'مبتدئ';

  @override
  String get lvlRookie => 'صاعد';

  @override
  String get lvlAthlete => 'رياضي';

  @override
  String get lvlWarrior => 'محارب';

  @override
  String get lvlBeast => 'وحش';

  @override
  String get lvlLegend => 'أسطورة';

  @override
  String get aiToolsTitle => 'أدوات الذكاء الاصطناعي';

  @override
  String get aiSignIn => 'تسجيل الدخول';

  @override
  String get aiGenerate => 'أنشئ';

  @override
  String get aiRegenerate => 'أنشئ من جديد';

  @override
  String get aiThinking =>
      'الذكاء الاصطناعي راهو يحضّر. كي تكون السيرفرات مشغولة يقدر ياخذ حتى دقيقتين.';

  @override
  String get aiKcal => 'سعرة';

  @override
  String get aiReportTitle => 'التقرير الأسبوعي';

  @override
  String get aiReportIntro =>
      'مراجعة أسبوعك كأنها من مدرب: التمرين، الأكل، الوزن، النوم، مع أهداف للأسبوع القادم.';

  @override
  String get aiReportRemind => 'ذكّرني كل جمعة مساءً';

  @override
  String get aiReportNotifTitle => 'تقريرك الأسبوعي جاهز 📊';

  @override
  String get aiReportNotifBody => 'افتح Fit Companion وشوف كيفاش داز أسبوعك.';

  @override
  String get aiWins => 'ما نجح';

  @override
  String get aiImprove => 'للتحسين';

  @override
  String get aiNextWeek => 'أهداف الأسبوع القادم';

  @override
  String get aiProgramTitle => 'بناء برنامج بالذكاء الاصطناعي';

  @override
  String aiProgramDays(int n) {
    return '$n أيام تمرين في الأسبوع';
  }

  @override
  String get aiProgramGoal => 'الهدف';

  @override
  String get aiProgramEquipment => 'المعدات المتوفرة';

  @override
  String get aiProgramNotes => 'ملاحظات (اختياري)';

  @override
  String get aiProgramNotesHint =>
      'مثلاً: ألم في الركبة، 45 دقيقة كحد أقصى، تركيز على الذراعين';

  @override
  String get aiProgramSave => 'احفظ في برامجي';

  @override
  String get aiProgramSaved => 'تم حفظ البرنامج في تمارينك';

  @override
  String get aiGoalStrength => 'قوة';

  @override
  String get aiGoalMuscle => 'عضلات';

  @override
  String get aiGoalFatLoss => 'حرق الدهون';

  @override
  String get aiGoalEndurance => 'تحمّل';

  @override
  String get aiEqBarbell => 'بار';

  @override
  String get aiEqDumbbell => 'دمبل';

  @override
  String get aiEqCable => 'كابل';

  @override
  String get aiEqMachine => 'آلات';

  @override
  String get aiEqBodyweight => 'وزن الجسم';

  @override
  String get aiMealTitle => 'خطة وجبات بالذكاء الاصطناعي';

  @override
  String get aiMealIntro =>
      'يوم كامل من الوجبات يطابق سعراتك وماكروزك، بأكل محلي وقائمة مشتريات.';

  @override
  String get aiMealRequest => 'تفضيلات (اختياري)';

  @override
  String get aiMealRequestHint =>
      'مثلاً: رخيص، بلا حوت، 4 وجبات، نخدم حتى 17:00';

  @override
  String get aiMealAdd => 'أضف لليوم';

  @override
  String get aiMealAddedShort => 'تمت الإضافة';

  @override
  String get aiMealAdded => 'أضيفت لليوم كمخطط (علّمها عندما تأكلها)';

  @override
  String get aiShopping => 'قائمة المشتريات';

  @override
  String get aiVoiceTitle => 'سجّل الأكل بالصوت';

  @override
  String get aiVoiceHint =>
      'قول واش كليت، مثلاً: \"زوج بيضات، طرف كسرة وقهوة بالحليب\". بالدارجة، العربية، الفرنسية أو الإنجليزية.';

  @override
  String get aiVoiceTap => 'اضغط للتسجيل';

  @override
  String get aiVoiceListening => 'نسمع… اضغط للإيقاف';

  @override
  String get aiVoiceNoMic => 'يلزم إذن الميكروفون';

  @override
  String get aiVoiceNothing => 'ما تعرفناش على حتى أكلة. عاود.';

  @override
  String aiVoiceLog(int n) {
    return 'سجّل $n عناصر';
  }

  @override
  String aiVoiceLogged(int n) {
    return 'تم تسجيل $n عناصر';
  }

  @override
  String get shareAction => 'مشاركة';

  @override
  String get friendsTitle => 'الأصدقاء';

  @override
  String get friendsSubtitle => 'ترتيب أسبوعي مع أصدقائك';

  @override
  String get friendsNeedAccount =>
      'سجّل الدخول لحسابك السحابي باش تضيف أصدقاء وتقارن التقدم.';

  @override
  String get friendsRetry => 'إعادة المحاولة';

  @override
  String get friendsMyCode => 'رمز الصداقة تاعي';

  @override
  String get friendsMyCodeHint => 'شاركه — غير الأصدقاء يشوفو إحصائياتك';

  @override
  String get friendsCopy => 'نسخ';

  @override
  String get friendsCopied => 'تم نسخ الرمز';

  @override
  String friendsInvite(String code) {
    return 'تمرّن معايا في Fit Companion! رمز الصداقة تاعي: $code';
  }

  @override
  String get friendsAdd => 'أضف صديق';

  @override
  String get friendsCode => 'رمز الصديق';

  @override
  String friendsAdded(String name) {
    return 'تمت إضافة $name';
  }

  @override
  String get friendsCodeNotFound => 'ما كاين حتى مستخدم بهاذ الرمز';

  @override
  String get friendsOwnCode => 'هذا رمزك أنت';

  @override
  String get friendsRemove => 'حذف الصديق';

  @override
  String friendsRemoveConfirm(String name) {
    return 'تحذف $name من أصدقائك؟';
  }

  @override
  String get friendsRemoveHint => 'اضغط مطولاً على صديق لحذفه';

  @override
  String get friendsSortVolume => 'الحجم';

  @override
  String get friendsSortWorkouts => 'الحصص';

  @override
  String get friendsEmpty => 'ما عندك حتى صديق. شارك رمزك وابدأ المنافسة!';

  @override
  String get friendsYou => 'أنت';

  @override
  String friendsLevel(int level) {
    return 'المستوى $level';
  }

  @override
  String get sleepTitle => 'النوم والأداء';

  @override
  String get sleepConnect =>
      'اربط Health Connect لقراءة نومك (من الساعة أو تطبيق النوم) وشوف تأثيره على تمارينك.';

  @override
  String get sleepConnectButton => 'اربط بيانات النوم';

  @override
  String sleepAvg(String hours, int nights) {
    return 'متوسط $hours ساعة في الليلة ($nights ليالي هذا الأسبوع)';
  }

  @override
  String get sleepNeedMore =>
      'تمرّن أكثر في الليالي المسجلة باش تشوف التأثير على أدائك.';

  @override
  String sleepBetter(String pct) {
    return 'ترفع حجم أكثر بـ $pct% بعد نوم 7 ساعات أو أكثر';
  }

  @override
  String get sleepNoEffect =>
      'ما كاينش تأثير واضح لليالي القصيرة على حجمك حتى الآن';

  @override
  String get sleepTip => 'حاول تنام 7–9 ساعات: العضلات تتبنى وأنت راقد.';

  @override
  String get exerciseWatchHow => 'شاهد طريقة الأداء';

  @override
  String get exerciseVideoError => 'تعذّر فتح الفيديو';

  @override
  String get exerciseOpenYoutube => 'افتح في YouTube';

  @override
  String get exerciseAnotherVideo => 'فيديو آخر';

  @override
  String get exerciseVideoSignIn =>
      'سجّل الدخول مرة وحدة باش يتحمّل الفيديو داخل التطبيق.';

  @override
  String get exerciseVideoUnavailable => 'فيديو الشرح غير متوفر حالياً.';

  @override
  String get equipBand => 'مطاط';

  @override
  String get cloudEmailConfirmedSignedIn =>
      'تم تأكيد الإيميل ✓ راك مسجّل الدخول.';

  @override
  String get cloudEmailConfirmedSignIn =>
      'تم تأكيد الإيميل ✓ درك سجّل الدخول بالإيميل وكلمة السر.';

  @override
  String get cloudErrInvalidCredentials =>
      'الإيميل ولا كلمة السر غالطين. ما عندكش حساب؟ أنشئ حساب أولاً.';

  @override
  String get cloudErrNotConfirmed =>
      'الإيميل تاعك مازال ما تأكدش. افتح الرابط اللي بعثناهولك (شوف حتى في spam).';

  @override
  String get cloudErrExists => 'هاذ الإيميل عندو حساب من قبل. سجّل الدخول.';

  @override
  String get cloudErrRateLimit => 'تبعثو بزاف إيميلات. استنى شوية دقايق وعاود.';

  @override
  String get cloudErrWeakPassword =>
      'كلمة السر ضعيفة. استعمل 6 حروف على الأقل.';

  @override
  String get cloudErrNetwork => 'ما كاينش اتصال بالسيرفر. شوف الإنترنت.';

  @override
  String get cloudResend => 'عاود ابعث';

  @override
  String get cloudResent => 'تبعث إيميل التأكيد من جديد';

  @override
  String get cloudCreateAccountAction => 'أنشئ حساب';

  @override
  String get remTestButton => 'ابعث إشعار تجريبي';

  @override
  String get remTestTitle => 'الإشعارات تخدم ✓';

  @override
  String get remTestBody => 'التذكيرات تاعك راح توصلك هكذا.';

  @override
  String get remTestHint =>
      'إذا التذكيرات تتأخر ولا ما توصلش، خلّي التطبيق يخدم في الخلفية: الإعدادات ← التطبيقات ← Fit Companion ← البطارية ← بلا قيود (في Xiaomi فعّل حتى التشغيل التلقائي Autostart).';
}
