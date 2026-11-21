class DailyNutritionSummary {
  final double caloriesConsumed;
  final double proteinConsumed;
  final double carbsConsumed;
  final double fatConsumed;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const DailyNutritionSummary({
    this.caloriesConsumed = 0.0,
    this.proteinConsumed = 0.0,
    this.carbsConsumed = 0.0,
    this.fatConsumed = 0.0,
    this.targetCalories = 2000,
    this.targetProtein = 150.0,
    this.targetCarbs = 200.0,
    this.targetFat = 65.0,
  });

  double get caloriesRemaining => (targetCalories - caloriesConsumed).clamp(-9999.0, 9999.0);
  double get calorieProgress => targetCalories > 0 ? (caloriesConsumed / targetCalories).clamp(0.0, 1.0) : 0.0;
  double get proteinProgress => targetProtein > 0 ? (proteinConsumed / targetProtein).clamp(0.0, 1.0) : 0.0;
  double get carbsProgress => targetCarbs > 0 ? (carbsConsumed / targetCarbs).clamp(0.0, 1.0) : 0.0;
  double get fatProgress => targetFat > 0 ? (fatConsumed / targetFat).clamp(0.0, 1.0) : 0.0;
}
