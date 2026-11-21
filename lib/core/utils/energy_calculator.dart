enum Sex { male, female }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

enum FitnessGoal {
  muscleGain,
  fatLoss,
  maintenance,
  recomposition,
}

enum TrainingType {
  strengthHypertrophy,
  cardioEndurance,
  functionalHybrid,
  generalFitness,
}

class EnergyCalculationBreakdown {
  final double bmr;
  final String bmrFormulaExplanation;
  final double activityMultiplier;
  final String activityExplanation;
  final double tdee;
  final String goalAdjustmentExplanation;
  final int recommendedCalories;
  final double recommendedProteinGrams;
  final double recommendedCarbsGrams;
  final double recommendedFatGrams;
  final String proteinLogicExplanation;
  final String fatLogicExplanation;
  final String carbsLogicExplanation;
  final List<String> warnings;

  const EnergyCalculationBreakdown({
    required this.bmr,
    required this.bmrFormulaExplanation,
    required this.activityMultiplier,
    required this.activityExplanation,
    required this.tdee,
    required this.goalAdjustmentExplanation,
    required this.recommendedCalories,
    required this.recommendedProteinGrams,
    required this.recommendedCarbsGrams,
    required this.recommendedFatGrams,
    required this.proteinLogicExplanation,
    required this.fatLogicExplanation,
    required this.carbsLogicExplanation,
    this.warnings = const [],
  });
}

class MacroTargets {
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double bmr;
  final double tdee;
  final List<String> warnings;
  final EnergyCalculationBreakdown? breakdown;

  const MacroTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.bmr,
    required this.tdee,
    this.warnings = const [],
    this.breakdown,
  });

  Map<String, dynamic> toMap() => {
    'calories': calories,
    'proteinGrams': proteinGrams,
    'carbsGrams': carbsGrams,
    'fatGrams': fatGrams,
    'bmr': bmr,
    'tdee': tdee,
    'warnings': warnings,
  };
}

class EnergyCalculator {
  EnergyCalculator._();

  /// Calculates Basal Metabolic Rate (BMR) using Mifflin–St Jeor formula:
  /// Men:   (10 × weight_kg) + (6.25 × height_cm) - (5 × age) + 5
  /// Women: (10 × weight_kg) + (6.25 × height_cm) - (5 × age) - 161
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) {
      throw ArgumentError('Weight, height, and age must be strictly positive.');
    }

    final double base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);
    return sex == Sex.male ? base + 5.0 : base - 161.0;
  }

  /// Returns standard physical activity multiplier for TDEE calculation
  static double getActivityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) = BMR * Activity Multiplier
  static double calculateTdee({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
    required ActivityLevel activityLevel,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
    );
    return bmr * getActivityMultiplier(activityLevel);
  }

  /// Computes target calories and macronutrients with evidence-based rules, safety limits, and detailed breakdown.
  static MacroTargets calculateTarget({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
    required ActivityLevel activityLevel,
    required FitnessGoal goal,
    TrainingType trainingType = TrainingType.strengthHypertrophy,
  }) {
    final bmr = calculateBmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
    );
    final actMultiplier = getActivityMultiplier(activityLevel);
    final tdee = bmr * actMultiplier;

    double calorieAdjustmentFactor;
    double proteinPerKg;
    double fatPerKg;
    String goalExplanation;

    switch (goal) {
      case FitnessGoal.muscleGain:
        // +12% surplus for controlled lean muscle accrual without excessive fat gain
        calorieAdjustmentFactor = 1.12;
        proteinPerKg = trainingType == TrainingType.strengthHypertrophy ? 2.0 : 1.8;
        fatPerKg = 0.9;
        goalExplanation = 'Lean Muscle Gain: +12% energy surplus (~+${((tdee * 0.12)).round()} kcal) to fuel muscle protein synthesis while minimizing fat accumulation.';
        break;
      case FitnessGoal.fatLoss:
        // -20% moderate sustainable deficit
        calorieAdjustmentFactor = 0.80;
        proteinPerKg = 2.2; // elevated protein preserves lean muscle tissue in caloric deficit
        fatPerKg = 0.8;
        goalExplanation = 'Sustainable Fat Loss: -20% deficit (~-${((tdee * 0.20)).round()} kcal) targeting body fat oxidation while preserving lean muscle mass.';
        break;
      case FitnessGoal.maintenance:
        calorieAdjustmentFactor = 1.0;
        proteinPerKg = 1.8;
        fatPerKg = 0.9;
        goalExplanation = 'Energy Balance (Maintenance): Calorie intake matches TDEE to stabilize current weight and maintain metabolic performance.';
        break;
      case FitnessGoal.recomposition:
        // -5% slight deficit with high protein
        calorieAdjustmentFactor = 0.95;
        proteinPerKg = 2.2;
        fatPerKg = 0.85;
        goalExplanation = 'Body Recomposition: Slight -5% deficit with elevated protein intake (2.2g/kg) and progressive overload training to simultaneously build muscle and reduce body fat.';
        break;
    }

    double rawTargetCalories = tdee * calorieAdjustmentFactor;
    final List<String> warnings = [];

    // Safe lower bounds (1200 kcal for females, 1500 kcal for males)
    final double minSafeCalories = (sex == Sex.female) ? 1200.0 : 1500.0;
    if (rawTargetCalories < minSafeCalories) {
      warnings.add(
        'Calorie target was raised to the safe clinical floor of ${minSafeCalories.toInt()} kcal to prevent metabolic slowdown and micronutrient deficiencies.',
      );
      rawTargetCalories = minSafeCalories;
    }

    if (rawTargetCalories > 4500.0) {
      warnings.add(
        'Calorie target exceeds 4500 kcal. Please verify your weight and activity level inputs.',
      );
    }

    final int targetCalories = rawTargetCalories.round();

    // Protein: 4 kcal per gram
    double proteinGrams = (weightKg * proteinPerKg).clamp(45.0, 280.0);
    double proteinCalories = proteinGrams * 4.0;

    // Fat: 9 kcal per gram, ensure minimum 20% of total calories
    double fatGrams = (weightKg * fatPerKg).clamp(30.0, 160.0);
    double fatCalories = fatGrams * 9.0;
    if (fatCalories < (targetCalories * 0.20)) {
      fatCalories = targetCalories * 0.20;
      fatGrams = fatCalories / 9.0;
    }

    // Carbs: remaining energy divided by 4 kcal per gram
    double remainingCalories = targetCalories - proteinCalories - fatCalories;
    if (remainingCalories < (targetCalories * 0.15)) {
      remainingCalories = targetCalories * 0.15;
    }
    double carbsGrams = remainingCalories / 4.0;

    final breakdown = EnergyCalculationBreakdown(
      bmr: double.parse(bmr.toStringAsFixed(1)),
      bmrFormulaExplanation: 'Mifflin-St Jeor formula based on ${weightKg.toStringAsFixed(1)} kg, ${heightCm.toStringAsFixed(0)} cm, $age yrs, and ${sex == Sex.male ? "Male (+5)" : "Female (-161)"}.',
      activityMultiplier: actMultiplier,
      activityExplanation: 'Multiplier: ${actMultiplier}x reflecting your reported daily activity and workout frequency.',
      tdee: double.parse(tdee.toStringAsFixed(1)),
      goalAdjustmentExplanation: goalExplanation,
      recommendedCalories: targetCalories,
      recommendedProteinGrams: double.parse(proteinGrams.toStringAsFixed(1)),
      recommendedCarbsGrams: double.parse(carbsGrams.toStringAsFixed(1)),
      recommendedFatGrams: double.parse(fatGrams.toStringAsFixed(1)),
      proteinLogicExplanation: '${proteinGrams.toStringAsFixed(0)}g (${proteinPerKg}g/kg bodyweight, ${proteinCalories.round()} kcal): essential for muscle repair and recovery.',
      fatLogicExplanation: '${fatGrams.toStringAsFixed(0)}g (${(fatCalories / targetCalories * 100).round()}% of calories, ${fatCalories.round()} kcal): vital for hormone production and vitamin absorption.',
      carbsLogicExplanation: '${carbsGrams.toStringAsFixed(0)}g (${remainingCalories.round()} kcal): primary energy source to fuel high-intensity training sessions and glycogen storage.',
      warnings: warnings,
    );

    return MacroTargets(
      calories: targetCalories,
      proteinGrams: double.parse(proteinGrams.toStringAsFixed(1)),
      carbsGrams: double.parse(carbsGrams.toStringAsFixed(1)),
      fatGrams: double.parse(fatGrams.toStringAsFixed(1)),
      bmr: double.parse(bmr.toStringAsFixed(1)),
      tdee: double.parse(tdee.toStringAsFixed(1)),
      warnings: warnings,
      breakdown: breakdown,
    );
  }

  /// Calculates nutrient amount based on 100g basis: (nutrient_per_100g * quantity_g) / 100
  static double calculateNutrient({
    required double nutrientPer100g,
    required double quantityGrams,
  }) {
    if (quantityGrams <= 0 || nutrientPer100g < 0) return 0.0;
    final value = (nutrientPer100g * quantityGrams) / 100.0;
    return double.parse(value.toStringAsFixed(1));
  }

  /// Validates whether manual macronutrient grams match total calorie target within 8% tolerance
  static bool isMacroSumConsistent({
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    if (calories <= 0) return false;
    final sum = (proteinG * 4.0) + (carbsG * 4.0) + (fatG * 9.0);
    return (sum - calories).abs() <= (calories * 0.08);
  }
}
