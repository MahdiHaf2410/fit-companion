import 'package:flutter_test/flutter_test.dart';
import 'package:fit_companion/core/utils/energy_calculator.dart';

void main() {
  group('EnergyCalculator - Mifflin-St Jeor Equation', () {
    test('Calculates male BMR accurately', () {
      // 80 kg, 180 cm, 25 years old, male:
      // (10 * 80) + (6.25 * 180) - (5 * 25) + 5 = 800 + 1125 - 125 + 5 = 1805
      final bmr = EnergyCalculator.calculateBmr(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 25,
        sex: Sex.male,
      );
      expect(bmr, equals(1805.0));
    });

    test('Calculates female BMR accurately', () {
      // 60 kg, 165 cm, 30 years old, female:
      // (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      final bmr = EnergyCalculator.calculateBmr(
        weightKg: 60.0,
        heightCm: 165.0,
        age: 30,
        sex: Sex.female,
      );
      expect(bmr, equals(1320.25));
    });

    test('Throws ArgumentError for zero or negative inputs', () {
      expect(
        () => EnergyCalculator.calculateBmr(
          weightKg: -70.0,
          heightCm: 175.0,
          age: 25,
          sex: Sex.male,
        ),
        throwsArgumentError,
      );

      expect(
        () => EnergyCalculator.calculateBmr(
          weightKg: 70.0,
          heightCm: 0,
          age: 25,
          sex: Sex.male,
        ),
        throwsArgumentError,
      );
    });

    test('Calculates TDEE with activity multiplier', () {
      // BMR 1805 * 1.55 (moderately active) = 2797.75
      final tdee = EnergyCalculator.calculateTdee(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 25,
        sex: Sex.male,
        activityLevel: ActivityLevel.moderatelyActive,
      );
      expect(tdee, equals(2797.75));
    });

    test('Calculates target with muscle gain surplus', () {
      final targets = EnergyCalculator.calculateTarget(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 25,
        sex: Sex.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goal: FitnessGoal.muscleGain,
      );
      // TDEE is ~2798, surplus ~12% = ~3134
      expect(targets.calories, greaterThan(2798));
      expect(targets.proteinGrams, equals(160.0)); // 80kg * 2.0g
      expect(targets.fatGrams, greaterThanOrEqualTo(72.0)); // 80kg * 0.9g
      expect(targets.carbsGrams, greaterThan(0));
    });

    test('Enforces clinical floor for severe deficit calculation', () {
      // Very light female aiming for extreme fat loss
      final targets = EnergyCalculator.calculateTarget(
        weightKg: 42.0,
        heightCm: 150.0,
        age: 40,
        sex: Sex.female,
        activityLevel: ActivityLevel.sedentary,
        goal: FitnessGoal.fatLoss,
      );
      // Floor is 1200 kcal
      expect(targets.calories, equals(1200));
      expect(targets.warnings, isNotEmpty);
    });

    test('Calculates nutrient by 100g basis accurately', () {
      // 150g chicken breast (31g protein per 100g) => 46.5g
      final protein = EnergyCalculator.calculateNutrient(
        nutrientPer100g: 31.0,
        quantityGrams: 150.0,
      );
      expect(protein, equals(46.5));

      // 0 grams yields 0.0
      expect(
        EnergyCalculator.calculateNutrient(nutrientPer100g: 20.0, quantityGrams: 0.0),
        equals(0.0),
      );
    });

    test('Detailed breakdown provides transparent mathematical steps', () {
      final targets = EnergyCalculator.calculateTarget(
        weightKg: 75.0,
        heightCm: 175.0,
        age: 26,
        sex: Sex.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goal: FitnessGoal.muscleGain,
        trainingType: TrainingType.strengthHypertrophy,
      );
      final breakdown = targets.breakdown!;

      expect(breakdown.bmr, greaterThan(1600));
      expect(breakdown.tdee, greaterThan(breakdown.bmr));
      expect(breakdown.recommendedCalories, greaterThan(breakdown.tdee));
      expect(breakdown.recommendedCalories, equals(targets.calories));
      expect(breakdown.recommendedProteinGrams, equals(targets.proteinGrams));
      expect(breakdown.recommendedCarbsGrams, equals(targets.carbsGrams));
      expect(breakdown.recommendedFatGrams, equals(targets.fatGrams));

      // Consistency check using EnergyCalculator.isMacroSumConsistent
      final isConsistent = EnergyCalculator.isMacroSumConsistent(
        calories: targets.calories,
        proteinG: targets.proteinGrams,
        carbsG: targets.carbsGrams,
        fatG: targets.fatGrams,
      );
      expect(isConsistent, isTrue);
    });

    test('isMacroSumConsistent identifies inconsistent targets accurately', () {
      // 2000 kcal target, but macros sum to: 100*4 + 100*4 + 20*9 = 400 + 400 + 180 = 980 kcal
      expect(
        EnergyCalculator.isMacroSumConsistent(
          calories: 2000,
          proteinG: 100,
          carbsG: 100,
          fatG: 20,
        ),
        isFalse,
      );

      // Consistent: 2000 kcal with 150g P (600), 225g C (900), 55g F (495) = 1995 kcal (within 8% tolerance)
      expect(
        EnergyCalculator.isMacroSumConsistent(
          calories: 2000,
          proteinG: 150,
          carbsG: 225,
          fatG: 55,
        ),
        isTrue,
      );
    });
  });
}
