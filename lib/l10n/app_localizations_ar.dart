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
  String get navProfile => 'الملف الشخصي';

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
}
