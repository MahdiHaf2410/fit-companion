class AcademyQuizQuestion {
  final String questionEn;
  final String questionAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctOptionIndex;
  final String explanationEn;
  final String explanationAr;

  const AcademyQuizQuestion({
    required this.questionEn,
    required this.questionAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctOptionIndex,
    required this.explanationEn,
    required this.explanationAr,
  });
}

class AcademyLesson {
  final String id;
  final int number;
  final String titleEn;
  final String titleAr;
  final String categoryEn;
  final String categoryAr;
  final String explanationEn;
  final String explanationAr;
  final String workedExampleEn;
  final String workedExampleAr;
  final String takeawayEn;
  final String takeawayAr;
  final AcademyQuizQuestion quiz;

  const AcademyLesson({
    required this.id,
    required this.number,
    required this.titleEn,
    required this.titleAr,
    required this.categoryEn,
    required this.categoryAr,
    required this.explanationEn,
    required this.explanationAr,
    required this.workedExampleEn,
    required this.workedExampleAr,
    required this.takeawayEn,
    required this.takeawayAr,
    required this.quiz,
  });
}

class AcademyCatalog {
  AcademyCatalog._();

  static List<AcademyLesson> get lessons => [
    // Lesson 1: What calories are
    const AcademyLesson(
      id: 'lesson_1_calories',
      number: 1,
      titleEn: 'What Are Calories?',
      titleAr: 'ما هي السعرات الحرارية؟',
      categoryEn: 'Energy Basics',
      categoryAr: 'أساسيات الطاقة',
      explanationEn:
          'A calorie (specifically a kilocalorie or kcal) is a unit of energy. Just like a car needs fuel to drive, your body uses calories from food to stay alive, breathe, pump blood, walk, and exercise. If you take in more energy than your body burns, the excess is stored as tissue (fat or muscle). If you take in less than you burn, your body taps into its stored reserves.',
      explanationAr:
          'السعرة الحرارية (كيلو كالوري) هي وحدة قياس الطاقة. مثلما تحتاج السيارة إلى الوقود لتعمل، يحتاج جسمك إلى السعرات من الطعام للبقاء على قيد الحياة، والتنفس، وضخ الدم، والحركة، والتمارين. إذا استهلكت طاقة أكبر مما يحرق جسمك، يتم تخزين الفائض كأنسجة (دهون أو عضلات)، وإذا استهلكت أقل، يلجأ جسمك إلى مخازنه الداخلية.',
      workedExampleEn:
          'If your body burns 2,200 kcal daily and you consume 2,200 kcal from food, your weight stays stable. If you consume 2,700 kcal daily, you have a +500 kcal surplus.',
      workedExampleAr:
          'إذا كان جسمك يحرق 2200 سعرة يومياً وتناولت 2200 سعرة من الطعام، يظل وزنك ثابتاً. إذا تناولت 2700 سعرة يومياً، يكون لديك فائض قدره +500 سعرة.',
      takeawayEn: 'Calories determine whether you gain, lose, or maintain weight over time.',
      takeawayAr: 'السعرات الحرارية هي التي تحدد زيادة الوزن أو نقصانه أو ثباته مع مرور الوقت.',
      quiz: AcademyQuizQuestion(
        questionEn: 'What happens when you consume fewer calories than your body burns over time?',
        questionAr: 'ماذا يحدث عندما تستهلك سعرات أقل مما يحرقه جسمك على مدار الوقت؟',
        optionsEn: ['You gain body fat', 'Your body uses stored energy and you lose weight', 'Nothing changes', 'Your metabolism immediately stops'],
        optionsAr: ['يزيد وزنك دهوناً', 'يستخدم جسمك الطاقة المخزنة وينخفض وزنك', 'لا يتغير أي شيء', 'يتوقف الحرق تماماً فوراً'],
        correctOptionIndex: 1,
        explanationEn: 'When energy intake is below expenditure, your body mobilizes stored fat and glycogen to cover the deficit.',
        explanationAr: 'عندما تكون السعرات المستهلكة أقل من المحروقة، يلجأ الجسم إلى تفكيك الدهون المخزنة والجليكوجين لتعويض النقص.',
      ),
    ),

    // Lesson 2: BMR vs TDEE
    const AcademyLesson(
      id: 'lesson_2_bmr_vs_tdee',
      number: 2,
      titleEn: 'BMR vs. TDEE: How Your Body Burns Energy',
      titleAr: 'معدل الأيض الأساسي مقابل الاحتياج الكلي للطاقة',
      categoryEn: 'Energy Basics',
      categoryAr: 'أساسيات الطاقة',
      explanationEn:
          'Basal Metabolic Rate (BMR) is the energy your body burns just staying awake and alive in bed (brain, heart, liver, lungs). Total Daily Energy Expenditure (TDEE) is BMR plus daily physical movements (walking, working, NEAT), digestion of food (TEF), and workouts.',
      explanationAr:
          'معدل الأيض الأساسي (BMR) هو الطاقة التي يحرقها جسمك للبقاء حياً فقط في حالة الراحة التامة (الدماغ، القلب، الكبد، الرئتان). أما الاحتياج اليومي الكلي (TDEE) فهو BMR مضافاً إليه كل حركاتك اليومية (المشي، العمل)، وهضم الطعام، والتمارين الرياضية.',
      workedExampleEn:
          'A 75kg male may have a BMR of 1,750 kcal. With moderate daily activity and lifting 4 days/week (multiplier 1.55x), his TDEE is: 1,750 × 1.55 = 2,712 kcal.',
      workedExampleAr:
          'شاب وزنه 75 كغ قد يبلغ معدل أيضه الأساسي 1750 سعرة. مع نشاط معتدل وتمرين 4 أيام بالأسبوع (معامل 1.55)، فإن احتياجه الكلي هو: 1750 × 1.55 = 2712 سعرة.',
      takeawayEn: 'Never set calorie targets below your resting BMR without medical supervision.',
      takeawayAr: 'لا تحدد أبداً هدفاً يومياً يقل عن معدل أيضك الأساسي (BMR) دون إشراف طبي.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Which is always higher for an active person: BMR or TDEE?',
        questionAr: 'أيهما أعلى دائماً للشخص الذي يتحرك ويتمرن: BMR أم TDEE؟',
        optionsEn: ['BMR is higher', 'TDEE is higher because it includes movement and workouts', 'They are always identical', 'It depends on the time of day'],
        optionsAr: ['BMR أعلى', 'TDEE أعلى لأنه يشمل الحركة والتمارين اليومية', 'كلاهما متطابق دائماً', 'يعتمد على وقت اليوم'],
        correctOptionIndex: 1,
        explanationEn: 'TDEE includes BMR plus all physical activity and digestion, so it is always higher.',
        explanationAr: 'الاحتياج الكلي (TDEE) يشمل الأيض الأساسي مضافاً إليه كل النشاط الحركي والتمارين والهضم، ولذلك فهو أعلى دائماً.',
      ),
    ),

    // Lesson 3: The Big Three: Protein, Carbs, and Fats
    const AcademyLesson(
      id: 'lesson_3_macronutrients',
      number: 3,
      titleEn: 'The Big Three: Protein, Carbs, and Fats',
      titleAr: 'المغذيات الكبرى الثلاث: البروتين، الكربوهيدرات، والدهون',
      categoryEn: 'Macronutrients',
      categoryAr: 'المغذيات الكبرى',
      explanationEn:
          'All food calories come from three macronutrients:\n• Protein builds and repairs muscles, enzymes, and skin.\n• Carbohydrates provide fast, efficient energy for high-intensity gym training and brain function.\n• Fats produce vital hormones (like testosterone), support cell membranes, and absorb fat-soluble vitamins (A, D, E, K).',
      explanationAr:
          'كل سعرات الأطعمة تأتي من ثلاثة مغذيات رئيسية:\n• البروتين: يبني ويصلح الأنسجة العضلية والإنزيمات.\n• الكربوهيدرات: تمنح الطاقة الأساسية للتمارين الشاقة ووظائف المخ.\n• الدهون: حيوية لإفراز الهرمونات (مثل التستوستيرون)، وصحة الخلايا، وامتصاص الفيتامينات (A, D, E, K).',
      workedExampleEn:
          '100g of cooked chicken breast contains ~31g protein, 0g carbs, and 3.6g fat.',
      workedExampleAr:
          '100غ من صدر الدجاج المشوي يحتوي على ~31غ بروتين، 0غ كربوهيدرات، و 3.6غ دهون.',
      takeawayEn: 'A balanced diet needs all three: protein for muscle, carbs for performance, fats for hormonal health.',
      takeawayAr: 'يحتاج جسمك إلى الثلاثة معاً: بروتين للبناء العضلي، كربوهيدرات للأداء، ودهون للتوازن الهرموني.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Which macronutrient is primarily responsible for muscle tissue repair and growth?',
        questionAr: 'أي من المغذيات مسؤول بالدرجة الأولى عن بناء العضلات واستشفائها؟',
        optionsEn: ['Carbohydrates', 'Protein', 'Saturated Fat', 'Water'],
        optionsAr: ['الكربوهيدرات', 'البروتين', 'الدهون المشبعة', 'الماء'],
        correctOptionIndex: 1,
        explanationEn: 'Protein provides the essential amino acids needed for muscle protein synthesis.',
        explanationAr: 'يمد البروتين الجسم بالأحماض الأمينية الأساسية اللازمة لعملية البناء والاستشفاء العضلي.',
      ),
    ),

    // Lesson 4: The 4 / 4 / 9 Rule
    const AcademyLesson(
      id: 'lesson_4_caloric_density',
      number: 4,
      titleEn: 'The 4 / 4 / 9 Rule of Energy Density',
      titleAr: 'قاعدة 4 / 4 / 9 لكثافة الطاقة',
      categoryEn: 'Macronutrients',
      categoryAr: 'المغذيات الكبرى',
      explanationEn:
          'Each macronutrient yields a specific amount of energy per gram:\n• 1g Protein = 4 kcal\n• 1g Carbohydrates = 4 kcal\n• 1g Dietary Fat = 9 kcal\nThis is why fats are much more calorie-dense than proteins or carbohydrates. A single tablespoon of olive oil (14g) is ~124 kcal!',
      explanationAr:
          'يمد كل غرام من المغذيات الجسم بكمية طاقة محددة:\n• 1غ بروتين = 4 سعرات\n• 1غ كربوهيدرات = 4 سعرات\n• 1غ دهون = 9 سعرات\nهذا يوضح لماذا الدهون أعلى كثافة بالسعرات. فملعقة طعام واحدة من زيت الزيتون (14غ) تمنحك قرابة 124 سعرة!',
      workedExampleEn:
          'A meal with 40g protein, 60g carbs, and 15g fat yields: (40 × 4) + (60 × 4) + (15 × 9) = 160 + 240 + 135 = 535 kcal.',
      workedExampleAr:
          'وجبة بها 40غ بروتين، 60غ كربوهيدرات، و 15غ دهون تعطي: (40 × 4) + (60 × 4) + (15 × 9) = 160 + 240 + 135 = 535 سعرة.',
      takeawayEn: 'Remember 4-4-9: Fat is more than twice as calorie-dense as protein and carbohydrates.',
      takeawayAr: 'تذكر قاعدة 4-4-9: الدهون تملك أكثر من ضِعف كثافة السعرات مقارنة بالبروتين والنشويات.',
      quiz: AcademyQuizQuestion(
        questionEn: 'How many calories are in 10 grams of dietary fat?',
        questionAr: 'كم سعرة حرارية توجد في 10 غرامات من الدهون؟',
        optionsEn: ['40 kcal', '90 kcal', '45 kcal', '100 kcal'],
        optionsAr: ['40 سعرة', '90 سعرة', '45 سعرة', '100 سعرة'],
        correctOptionIndex: 1,
        explanationEn: '10g of fat multiplied by 9 kcal per gram equals 90 kcal.',
        explanationAr: '10 غرامات من الدهون مضروبة في 9 سعرات لكل غرام تساوي 90 سعرة.',
      ),
    ),

    // Lesson 5: Calculating Nutrition from Quantities
    const AcademyLesson(
      id: 'lesson_5_quantity_scaling',
      number: 5,
      titleEn: 'Calculating Nutrition from Food Weights',
      titleAr: 'حساب القيم الغذائية من وزن الطعام',
      categoryEn: 'Food Tracking',
      categoryAr: 'تتبع الأطعمة',
      explanationEn:
          'Standard nutrition labels and databases list nutrient values per 100 grams. To calculate the nutrient in any portion:\nNutrient = (Value per 100g × Your Portioned Grams) ÷ 100\nThis straightforward proportional equation ensures absolute accuracy for any custom portion.',
      explanationAr:
          'تُكتب القيم الغذائية في الجداول العالمية لكل 100 غرام. لحساب القيمة في أي كمية تتناولها:\nالقيمة = (القيمة لكل 100غ × عدد الغرامات) ÷ 100\nهذه المعادلة النسبية البسيطة تضمن الدقة التامة لأي وزن.',
      workedExampleEn:
          'Cooked white rice has 28g carbs per 100g. If you eat 180g of rice:\n(28 × 180) ÷ 100 = 50.4g of carbohydrates.',
      workedExampleAr:
          'الأرز المطبوخ به 28غ كربوهيدرات لكل 100غ. إذا تناولت 180غ من الأرز:\n(28 × 180) ÷ 100 = 50.4غ كربوهيدرات.',
      takeawayEn: 'Always weigh portions in grams using a kitchen scale for dependable progress tracking.',
      takeawayAr: 'زن طعامك بالغرام باستخدام ميزان المطبخ لضمان دقة السجل وتحقيق أهدافك.',
      quiz: AcademyQuizQuestion(
        questionEn: 'If a food has 20g of protein per 100g, how much protein is in 250g of that food?',
        questionAr: 'إذا كان طعام يحتوي على 20غ بروتين لكل 100غ، فكم غرام بروتين في 250غ من هذا الطعام؟',
        optionsEn: ['40g', '50g', '20g', '60g'],
        optionsAr: ['40غ', '50غ', '20غ', '60غ'],
        correctOptionIndex: 1,
        explanationEn: '(20g × 250) ÷ 100 = 50g of protein.',
        explanationAr: '(20 × 250) ÷ 100 = 50 غرام بروتين.',
      ),
    ),

    // Lesson 6: Reading Nutrition Labels
    const AcademyLesson(
      id: 'lesson_6_reading_labels',
      number: 6,
      titleEn: 'How to Read Nutrition Facts Labels',
      titleAr: 'كيف تقرأ البطاقة الغذائية للمنتجات',
      categoryEn: 'Food Tracking',
      categoryAr: 'تتبع الأطعمة',
      explanationEn:
          'When looking at food packaging:\n1. Check the serving size vs. 100g column.\n2. Look at total calories.\n3. Note protein, total carbs (and sugars), and total fat (and saturated fat).\n4. Always verify whether the values are for the product raw/dry or prepared.',
      explanationAr:
          'عند قراءة ملصق المنتجات الغذائية:\n1. قارن بين عمود الحصة الواحدة وعمود 100غ.\n2. انظر إلى إجمالي السعرات.\n3. تحقق من غرامات البروتين، الكربوهيدرات (ومنها السكريات)، والدهون.\n4. تأكد هل الأرقام للمنتج جافاً أم بعد التحضير.',
      workedExampleEn:
          'A pack of Algerian Candia milk shows 48 kcal and 3.3g protein per 100ml. A 250ml glass gives: 48 × 2.5 = 120 kcal and 8.25g protein.',
      workedExampleAr:
          'علبة حليب كانديا جزائري تبيّن 48 سعرة و 3.3غ بروتين لكل 100 مل. كوب 250 مل يمنحك: 48 × 2.5 = 120 سعرة و 8.25غ بروتين.',
      takeawayEn: 'Manufacturers often highlight small serving sizes. Compare using the 100g column whenever possible.',
      takeawayAr: 'غالباً ما تضع الشركات حصصاً صغيرة للترويج. اعتمد دائماً على عمود 100غ للمقارنة الدقيقة.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Why should you check the 100g column on a food label?',
        questionAr: 'لماذا يُفضل الاعتماد على عمود 100غ في الملصق الغذائي؟',
        optionsEn: ['Because it is easier to scale accurately to your weighed portion', 'Because it has fewer calories', 'Because it only applies to drinks', 'Because it is mandatory by law'],
        optionsAr: ['لأنه يسهل حساب أي كمية تزنها بدقة وتناسب', 'لأن سعراته أقل', 'لأنه يخص المشروبات فقط', 'لأنه قانوني فقط'],
        correctOptionIndex: 0,
        explanationEn: 'The 100g basis allows you to calculate exact nutrition for any custom weighed amount.',
        explanationAr: 'قاعدة 100غ تسمح لك بحساب القيمة الغذائية لأي وزن تضعه على الميزان بكل سهولة.',
      ),
    ),

    // Lesson 7: Raw vs. Cooked Weights
    const AcademyLesson(
      id: 'lesson_7_raw_vs_cooked',
      number: 7,
      titleEn: 'Raw vs. Cooked Weights: The Water Factor',
      titleAr: 'الوزن نيء مقابل مطبوخ: تأثير امتصاص وفقدان الماء',
      categoryEn: 'Food Tracking',
      categoryAr: 'تتبع الأطعمة',
      explanationEn:
          'Cooking changes the weight of food significantly by absorbing or evaporating water. Water contains 0 calories, but it alters nutrient density:\n• Grains (Rice, Oats, Pasta, Couscous) absorb water and become heavier (100g dry rice becomes ~260g cooked rice).\n• Meats (Chicken, Beef) lose water during grilling and become lighter (200g raw chicken becomes ~150g cooked).\nAlways match the database entry (raw vs. cooked) to how you weighed the food!',
      explanationAr:
          'يغير الطهي وزن الطعام بشكل كبير بسبب امتصاص الماء أو تبخره. الماء يحتوي على 0 سعرة، لكنه يغير الكثافة الغذائية:\n• الحبوب (الأرز، الشوفان، الكسكسي) تمتص الماء ويزيد وزنها (100غ أرز نيء يصبح ~260غ مطبوخ).\n• اللحوم والدجاج تفقد الماء بالشي وتصبح أخف (200غ صدر دجاج نيء يصبح ~150غ مشوي).\nاحرص دائماً على اختيار بند التغذية المطابق لحالة وزنك (نيء أو مطبوخ)!',
      workedExampleEn:
          '100g of RAW chicken breast has ~120 kcal (31g per cooked 100g). If you weigh 150g of cooked chicken, select "Chicken Breast Cooked" (165 kcal/100g = 247 kcal), NOT raw!',
      workedExampleAr:
          '100غ صدر دجاج نيء يحتوي ~120 سعرة. إذا وزنت 150غ دجاج بعد الشوي، اختر في التطبيق "صدر دجاج مشوي/مطبوخ" (165 سعرة/100غ) وليس النيء!',
      takeawayEn: 'Never log cooked meat with raw values or dry pasta with cooked values.',
      takeawayAr: 'لا تسجل اللحم المطبوخ بقيم النيء، ولا تسجل المعكرونة الجافة بقيم المطبوخة.',
      quiz: AcademyQuizQuestion(
        questionEn: 'What happens to dry oats and rice when cooked in boiling water?',
        questionAr: 'ماذا يحدث للأرز والشوفان الجاف عند طهيه في الماء المغلي؟',
        optionsEn: ['They absorb water, becoming heavier with fewer calories per 100g', 'They lose weight and gain calories', 'The calories triple', 'Nothing changes'],
        optionsAr: ['يمتص الماء ويزيد وزنه وتقل سعراته لكل 100غ', 'ينقص وزنه وتتضاعف سعراته', 'تتضاعف السعرات ثلاث مرات', 'لا يتغير وزنه أبداً'],
        correctOptionIndex: 0,
        explanationEn: 'Water adds zero calories but increases weight, lowering caloric density per 100g.',
        explanationAr: 'الماء يزيد الوزن دون إضافة سعرات، مما يقلل كثافة السعرات لكل 100غ في الطعام المطبوخ.',
      ),
    ),

    // Lesson 8: Estimating Portions When You Can't Weigh
    const AcademyLesson(
      id: 'lesson_8_portion_estimation',
      number: 8,
      titleEn: 'Estimating Portions When Eating Out',
      titleAr: 'تقدير الحصص باليد عند غياب الميزان',
      categoryEn: 'Food Tracking',
      categoryAr: 'تتبع الأطعمة',
      explanationEn:
          'When dining outside or at family dinners without a scale, use hand references:\n• Palm of your hand = ~100-120g of cooked lean meat or fish (~25-30g protein).\n• Cupped hand = ~1 cup of cooked rice, couscous, or pasta (~150-180g).\n• Fist = ~1 medium fruit or cup of vegetables.\n• Thumb tip = ~1 tablespoon (14g) of olive oil or butter.',
      explanationAr:
          'عند الأكل خارج المنزل أو في الولائم العائلية دون ميزان، استعن بيدك للتقدير:\n• كف اليد (بدون الأصابع) = ~100-120غ لحم أو دجاج مطبوخ (~25-30غ بروتين).\n• راحة اليد المقعرة = ~كوب أرز أو كسكسي مطبوخ (~150-180غ).\n• قبضة اليد = ~حبة فاكهة متوسطة أو كوب خضار.\n• عقلة الإبهام = ~ملعقة طعام (14غ) زيت زيتون أو زبدة.',
      workedExampleEn:
          'At an Algerian family lunch with Couscous: 1 palm-sized chicken piece (~120g) + 2 cupped hands of couscous with veg (~300g) = ~500 kcal.',
      workedExampleAr:
          'في وليمة عائلية: قطعة دجاج بحجم كف اليد (~120غ) + غرفتان بكف اليد كسكسي بالمرق (~300غ) = ~500 سعرة.',
      takeawayEn: 'Consistency beats perfection: An educated hand estimate is infinitely better than skipping logging.',
      takeawayAr: 'الاستمرار أهم من الكمال: التقدير الذكي باليد أفضل بكثير من ترك التسجيل.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Approximately how much cooked chicken breast does the palm of an average adult hand represent?',
        questionAr: 'كم غراماً تقريباً يمثل كف يد الشخص البالغ من صدر الدجاج المطبوخ؟',
        optionsEn: ['Around 100-120 grams (~25-30g protein)', 'Around 300 grams', 'Around 20 grams', 'Around 500 grams'],
        optionsAr: ['حوالي 100 إلى 120 غرام (~25-30غ بروتين)', 'حوالي 300 غرام', 'حوالي 20 غرام فقط', 'حوالي 500 غرام'],
        correctOptionIndex: 0,
        explanationEn: 'A palm-sized piece of cooked lean meat provides roughly 100-120g of cooked food.',
        explanationAr: 'كف يد الشخص البالغ يمثل ما يقارب 100-120 غرام من اللحم المطبوخ الصافي.',
      ),
    ),

    // Lesson 9: How to Calculate Complete Recipes
    const AcademyLesson(
      id: 'lesson_9_recipe_building',
      number: 9,
      titleEn: 'How to Calculate Complete Recipes',
      titleAr: 'كيف تحسب وصفات الطعام المتكاملة',
      categoryEn: 'Cooking & Recipes',
      categoryAr: 'الطبخ والوصفات',
      explanationEn:
          'To calculate a multi-ingredient dish (like Algerian Chorba Frik or Lentils):\n1. Weigh and sum the calories and macros of all raw ingredients (meat, freekeh, oil, vegetables).\n2. Note the total number of servings or the final cooked weight.\n3. Divide total calories by the number of servings to get nutrition per portion.',
      explanationAr:
          'لحساب وصفة مركبة (مثل شربة فريك جزائرية أو شطيطحة عدس):\n1. زن واجمع سعرات ومغذيات المكونات كلها (اللحم، الفريك، الزيت، الخضار).\n2. حدد عدد الحصص الناتجة أو زن القدر كاملاً بعد الطهي.\n3. قسّم إجمالي السعرات على عدد الحصص لمعرفة قيمة الحصة الواحدة.',
      workedExampleEn:
          'A pot of Chorba made with 300g beef (600 kcal) + 150g freekeh (500 kcal) + 2 tbsp oil (240 kcal) + veg (100 kcal) = 1,440 kcal total. Divided into 4 bowls = 360 kcal per bowl.',
      workedExampleAr:
          'قدر شوربة به 300غ لحم (600 سعرة) + 150غ فريك (500 سعرة) + ملعقتين زيت (240 سعرة) + خضار (100 سعرة) = 1440 سعرة إجمالية. مقسمة على 4 صحون = 360 سعرة للصحن.',
      takeawayEn: 'Cooking oil added to sauces must always be counted — it is the most common hidden calorie source.',
      takeawayAr: 'احسب دائماً زيت الطهي المضاف للمرق — فهو المصدر الأول للسعرات الخفية غير المحسوبة.',
      quiz: AcademyQuizQuestion(
        questionEn: 'If a whole family pot has 1,800 kcal and you divide it into 3 equal portions, how many calories are in your plate?',
        questionAr: 'إذا كان إجمالي قدر الطعام 1800 سعرة وقسمته إلى 3 حصص متساوية، كم سعرة في طبقك؟',
        optionsEn: ['600 kcal', '900 kcal', '300 kcal', '1,200 kcal'],
        optionsAr: ['600 سعرة', '900 سعرة', '300 سعرة', '1200 سعرة'],
        correctOptionIndex: 0,
        explanationEn: '1,800 kcal divided by 3 equal servings equals 600 kcal per serving.',
        explanationAr: '1800 سعرة مقسمة على 3 حصص متساوية تساوي 600 سعرة لكل حصة.',
      ),
    ),

    // Lesson 10: Estimating Daily Calorie Needs
    const AcademyLesson(
      id: 'lesson_10_estimating_needs',
      number: 10,
      titleEn: 'Estimating Daily Energy Needs Accurately',
      titleAr: 'تقدير الاحتياج اليومي للطاقة بدقة',
      categoryEn: 'Goal Planning',
      categoryAr: 'تخطيط الأهداف',
      explanationEn:
          'The scientific gold standard for estimating resting energy is the Mifflin–St Jeor equation. It accounts for your weight, height, age, and sex.\nThen an activity factor is applied (1.2x sedentary up to 1.9x extremely active).\nRemember: this is a scientific starting estimate, not a laboratory measurement. Real-world feedback will guide fine adjustments.',
      explanationAr:
          'المعيار العلمي الذهبي لتقدير الطاقة الأساسية هو معادلة ميفلين-سانت جور، حيث تأخذ بالاعتبار وزنك، طولك، عمرك، وجنسك.\nثم يُضرب الناتج في معامل النشاط الحركي (من 1.2 للخامل حتى 1.9 للنشيط جداً).\nتذكر: هذه بداية تقديرية علمية مدروسة، وتعديلها يتم بناءً على نتائج الميزان الحقيقية.',
      workedExampleEn:
          'For a 30-year-old female, 60kg, 165cm:\nBMR = (10 × 60) + (6.25 × 165) - (5 × 30) - 161 = 1,320 kcal. If lightly active (1.375x): TDEE = 1,815 kcal.',
      workedExampleAr:
          'لأنثى عمرها 30 سنة، وزن 60 كغ، وطول 165 سم:\nBMR = (10 × 60) + (6.25 × 165) - (5 × 30) - 161 = 1320 سعرة. مع نشاط خفيف (1.375): TDEE = 1815 سعرة.',
      takeawayEn: 'Formulas give an initial estimate. Track for 2-3 weeks and observe your weight trend to calibrate.',
      takeawayAr: 'المعادلات تعطيك نقطة انطلاق ممتازة. تابع وزنك لأسبوعين أو ثلاثة لمعايرتها بدقة.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Why do formulas require age, sex, height, and weight instead of just weight?',
        questionAr: 'لماذا تتطلب المعادلات الطبية العمر والجنس والطول والوزن معاً بدلاً من الوزن فقط؟',
        optionsEn: ['Because height, age, and biological sex heavily influence metabolic organ mass', 'Just for verification', 'Height determines fat percentage directly', 'It makes no difference'],
        optionsAr: ['لأن الطول والعمر والجنس تؤثر جوهرياً على كتلة الأعضاء الحيوية ومعدل الحرق', 'لمجرد التأكد فقط', 'لأن الطول يحدد نسبة الدهون مباشرة', 'لا يوجد أي فرق علمي'],
        correctOptionIndex: 0,
        explanationEn: 'Metabolic rate depends on body surface area, organ size, age-related cellular activity, and biological lean mass differences.',
        explanationAr: 'معدل الحرق يرتبط بمسطح الجسم وحجم الأعضاء الحيوية ونشاط الخلايا وفروق الكتلة العضلية الحيوية.',
      ),
    ),

    // Lesson 11: Choosing Calorie Targets for Goals
    const AcademyLesson(
      id: 'lesson_11_calorie_targets_goals',
      number: 11,
      titleEn: 'Choosing Targets for Fat Loss vs. Muscle Gain',
      titleAr: 'اختيار عجز السعرات لخسارة الدهون وفائض البناء',
      categoryEn: 'Goal Planning',
      categoryAr: 'تخطيط الأهداف',
      explanationEn:
          '• Fat Loss: Aim for a moderate 15-20% deficit (~300-500 kcal below TDEE). Never crash diet below 1,200 kcal (women) or 1,500 kcal (men).\n• Muscle Gain: Aim for a controlled 10-15% surplus (~250-350 kcal above TDEE) combined with progressive resistance training.\n• Maintenance: Eat at your TDEE to stabilize weight.',
      explanationAr:
          '• خسارة الدهون: استهدف عجزاً معتدلاً ومستداماً بنسبة 15-20% (~300 إلى 500 سعرة تحت TDEE). تجنب الحميات القاسية تحت 1200 سعرة للإناث أو 1500 للذكور.\n• بناء العضلات: استهدف فائضاً مدروساً بنسبة 10-15% (~250 إلى 350 سعرة فوق TDEE) مع تمارين المقاومة.\n• المحافظة: تناول سعرات مساوية لـ TDEE لتثبيت الوزن.',
      workedExampleEn:
          'If TDEE is 2,400 kcal:\n• Fat Loss target = 2,400 × 0.80 = 1,920 kcal\n• Muscle Gain target = 2,400 × 1.12 = 2,688 kcal.',
      workedExampleAr:
          'إذا كان احتياجك 2400 سعرة:\n• هدف خسارة الدهون = 2400 × 0.80 = 1920 سعرة\n• هدف زيادة العضلات = 2400 × 1.12 = 2688 سعرة.',
      takeawayEn: 'Aggressive deficits cause muscle loss and fatigue. Sustainable moderate deficits win the long game.',
      takeawayAr: 'العجز القاسي يسبب هدم العضلات والإرهاق. العجز المعتدل والمستمر هو سر النجاح الحقيقي.',
      quiz: AcademyQuizQuestion(
        questionEn: 'What is the recommended sustainable deficit percentage for fat loss without muscle wasting?',
        questionAr: 'ما هي نسبة العجز الموصى بها علمياً لخسارة الدهون دون فقدان العضلات؟',
        optionsEn: ['15% to 20% below TDEE', '60% below TDEE', 'Zero deficit', '50% below BMR'],
        optionsAr: ['15% إلى 20% تحت TDEE', '60% تحت TDEE', 'بدون أي عجز', '50% تحت BMR'],
        correctOptionIndex: 0,
        explanationEn: 'A 15-20% deficit provides safe, steady fat loss while preserving metabolic health and strength.',
        explanationAr: 'عجز 15-20% يوفر خسارة دهون ثابتة وآمنة مع الحفاظ على الكتلة العضلية وصحة الأيض.',
      ),
    ),

    // Lesson 12: Interpreting Weight Trends & Moving Averages
    const AcademyLesson(
      id: 'lesson_12_weight_trends',
      number: 12,
      titleEn: 'Interpreting Daily Fluctuation & Moving Averages',
      titleAr: 'تفسير تقلبات الميزان والمتوسط الأسبوعي',
      categoryEn: 'Progress Tracking',
      categoryAr: 'متابعة التقدم',
      explanationEn:
          'Your scale weight fluctuates by 1-2 kg every day due to water retention, sodium, bowel contents, and muscle glycogen. 1g of stored glycogen holds ~3g of water! Do NOT panic when the scale jumps up after a salty or carb-heavy dinner. The 7-day moving average eliminates this noise and reveals true fat/muscle trends.',
      explanationAr:
          'يتذبذب وزن الميزان بمقدار 1 إلى 2 كغ يومياً لأسباب طبيعية: احتباس السوائل، الأملاح، محتوى الجهاز الهضمي، ومخازن الجليكوجين. كل 1غ جليكوجين يخزن معه ~3غ ماء! لا تقلق إذا زاد الميزان فجأة بعد وجبة مالحة أو غنية بالنشويات. المتوسط المتحرك لـ 7 أيام يزيل هذا التذبذب ويكشف المسار الحقيقي.',
      workedExampleEn:
          'Daily weights: Mon 78.0, Tue 78.8 (ate pizza), Wed 78.4, Thu 77.8. The weekly average moves from 78.5 to 78.0 kg: true fat loss is happening despite the Tuesday spike!',
      workedExampleAr:
          'أوزانك اليومية: الإثنين 78.0، الثلاثاء 78.8 (بسبب بيتزا مالحة)، الأربعاء 78.4، الخميس 77.8. انخفض المتوسط الأسبوعي من 78.5 إلى 78.0 كغ: خسارة الدهون مستمرة رغم قفزة الثلاثاء!',
      takeawayEn: 'Never judge progress by a single morning weigh-in. Follow the 7-day trend line.',
      takeawayAr: 'لا تحكم على نجاحك من قياس يوم واحد. راقب دائماً خط المتوسط الأسبوعي في شاشة التقدم.',
      quiz: AcademyQuizQuestion(
        questionEn: 'Why might your weight increase by 1kg the morning after a high-sodium or carb-rich dinner?',
        questionAr: 'لماذا قد يزيد وزنك بمقدار 1 كغ في صباح اليوم التالي لوجبة غنية بالأملاح والنشويات؟',
        optionsEn: ['Temporary water retention binding to glycogen and sodium', 'You gained 1kg of pure body fat overnight', 'Your scale is broken', 'Your muscle mass doubled'],
        optionsAr: ['احتباس ماء مؤقت مرتبط بالجليكوجين والصوديوم', 'اكتسبت 1 كغ من الدهون الصافية في ليلة واحدة', 'الميزان معطل حتماً', 'تضاعفت عضلاتك'],
        correctOptionIndex: 0,
        explanationEn: 'Gaining 1kg of pure fat requires a 7,700 kcal surplus. Overnight spikes are almost entirely water retention.',
        explanationAr: 'اكتساب 1 كغ دهون يحتاج فائضاً هائلاً قدره 7700 سعرة. الزيادة المفاجئة بين يوم وليلة هي ماء محتبس فقط.',
      ),
    ),

    // Lesson 13: Why Estimates Vary Between Brands and Dishes
    const AcademyLesson(
      id: 'lesson_13_variance_in_nutrition',
      number: 13,
      titleEn: 'Why Nutrition Estimates Vary Between Sources',
      titleAr: 'لماذا تختلف قيم الأطعمة بين المنتجات والمطاعم',
      categoryEn: 'Food Tracking',
      categoryAr: 'تتبع الأطعمة',
      explanationEn:
          'No two apples or plates of Couscous are identical. Factors creating variations:\n• Soil quality, ripeness, and water content in crops.\n• Cuts of meat: fatty ribeye vs. lean sirloin.\n• Cooking method: frying in oil vs. grilling/steaming.\n• Cultural recipes: Algerian Mahjouba with 1 tbsp oil vs. 3 tbsp oil will differ by 200+ kcal!\nAim for consistency rather than microscopic lab precision.',
      explanationAr:
          'لا توجد تفاحتان أو صحنان كسكسي متطابقان بنسبة 100%. أسباب الاختلاف الطبيعي:\n• نوعية التربة ودرجة نضج الفواكه ونسبة الماء.\n• نوعية قطع اللحم (لحم دهني مقابل لحم هبر أحمر).\n• طريقة الطهي: القلي بالزيت مقابل الشوي أو البخار.\n• الوصفات المنزلية: محجوبة بملعقة زيت تختلف بـ 200 سعرة عن محجوبة بـ 3 ملاعق!\nركز على الاستمرارية والتقارب الصحيح بدلاً من الهوس بالدقة المجهرية.',
      workedExampleEn:
          '100g of commercial white bread can vary from 240 to 275 kcal depending on oil and sugar additions. Checking the exact package label gives the truest number.',
      workedExampleAr:
          '100غ خبز أبيض قد يتراوح بين 240 و 275 سعرة حسب الزيت والسكر المضاف. قراءة ملصق العلبة يوفر لك الرقم الأدق لعلامتك التجارية.',
      takeawayEn: 'Log with verified staples when possible, and estimate home recipes with reasonable ingredient breakdowns.',
      takeawayAr: 'استخدم الأطعمة الموثوقة للمكونات الأساسية، وفكك الوصفات المنزلية إلى مكوناتها الأصلية.',
      quiz: AcademyQuizQuestion(
        questionEn: 'What is usually the biggest source of calorie difference between two homemade meals with the same name?',
        questionAr: 'ما هو أكبر سبب لاختلاف السعرات بين طبقين من نفس الوجبة المنزلية؟',
        optionsEn: ['The amount of cooking oil, butter, and sauce added', 'The spices used', 'The temperature of the oven', 'The color of the plate'],
        optionsAr: ['كمية زيت الطهي والزبدة والدهون المضافة للمرق', 'نوعية البهارات والتوابل', 'درجة حرارة الفرن', 'لون الصحن المستخدم'],
        correctOptionIndex: 0,
        explanationEn: 'At 9 kcal/gram, cooking oils and fats have the largest impact on total meal energy.',
        explanationAr: 'الزيوت والدهون تملك 9 سعرات لكل غرام، لذا فإن إضافة ملعقة أو اثنتين يغير سعرات الطبق بشكل جذري.',
      ),
    ),

    // Lesson 14: How to Use Fit Companion Effectively
    const AcademyLesson(
      id: 'lesson_14_using_fit_companion',
      number: 14,
      titleEn: 'Mastering Fit Companion for Lifelong Fitness',
      titleAr: 'كيف تستخدم رفيق اللياقة باحترافية واستدامة',
      categoryEn: 'App Mastery',
      categoryAr: 'احتراف التطبيق',
      explanationEn:
          'Put it all together:\n1. Use the Personal Nutrition Calculator to set your initial targets.\n2. Use the Smart Food Calculator to scale meals accurately in grams.\n3. Build your staple Algerian meals in the Recipe Builder.\n4. Log workouts continuously with the active session rest timer.\n5. Check your 7-day moving weight average every week to calibrate.',
      explanationAr:
          'اجمع كل ما تعلمته:\n1. استخدم حاسبة التغذية لتحديد أهدافك الأولية بدقة.\n2. استخدم الحاسبة الذكية لوزن وتسجيل أطعمتك بالغرام.\n3. ركب أطباقك الجزائرية المفضلة في منشئ الوصفات.\n4. سجّل تمارينك في الجلسة المباشرة مع مؤقت الراحة.\n5. راقب خط المتوسط الأسبوعي للوزن أسبوعياً لتعديل خطتك بنجاح.',
      workedExampleEn:
          'If your weekly average weight drops by 0.5kg/week on 2,000 kcal, your fat loss deficit is perfect! Keep going without changing anything.',
      workedExampleAr:
          'إذا كان متوسط وزنك ينخفض بمعدل 0.5 كغ أسبوعياً وأنت تتناول 2000 سعرة، فإن خطتك ممتازة تماماً! استمر دون أي تغيير.',
      takeawayEn: 'Fitness is a marathon of consistency. Fit Companion works 100% offline and stays private on your phone.',
      takeawayAr: 'اللياقة رحلة استمرارية. رفيق اللياقة يعمل محلياً 100% بدون إنترنت ويحفظ خصوصيتك التامة.',
      quiz: AcademyQuizQuestion(
        questionEn: 'How often should you adjust your calorie target based on weight changes?',
        questionAr: 'كم مرة يجب أن تعدل هدف السعرات بناءً على تغيرات الميزان؟',
        optionsEn: ['Every 2 to 3 weeks after reviewing the 7-day average trend', 'Every single day the scale changes', 'Never in your life', 'Every hour'],
        optionsAr: ['كل أسبوعين إلى 3 أسابيع بعد مراجعة اتجاه المتوسط الأسبوعي', 'كل يوم بمجرد تغير رقم الميزان', 'لا تعدلها أبداً', 'كل ساعة'],
        correctOptionIndex: 0,
        explanationEn: 'Adjusting targets requires observing multi-week trend lines to confirm genuine tissue changes.',
        explanationAr: 'تعديل السعرات يحتاج متابعة اتجاه الوزن لعدة أسابيع متتالية للتأكد من حقيقة تغير الكتلة العضلية أو الدهنية.',
      ),
    ),
  ];
}
