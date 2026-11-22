import '../database/app_database.dart' show WorkoutSet;

/// Pure strength-training math (no Flutter imports, easy to unit test).
class StrengthCalculator {
  StrengthCalculator._();

  /// Estimated one-rep max using the Epley formula: w × (1 + reps / 30).
  /// A single rep returns the weight itself.
  static double estimateOneRepMax(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30.0);
  }

  /// Weight to use for [reps] given a 1RM (inverse Epley).
  static double weightForReps(double oneRepMax, int reps) {
    if (oneRepMax <= 0 || reps <= 0) return 0;
    if (reps == 1) return oneRepMax;
    return oneRepMax / (1 + reps / 30.0);
  }

  /// Smart progressive overload (double progression):
  /// - every working set of last session reached [targetReps] → add weight
  ///   (+2.5 kg compound, +1.25 kg isolation)
  /// - best set fell 3+ reps short of the target → reduce ~5 % (deload)
  /// - otherwise → keep the weight and try to beat the reps.
  /// Returns null when there is no history yet.
  static OverloadSuggestion? suggestNextWeight({
    required List<WorkoutSet> lastSets,
    required int targetReps,
    required bool isCompound,
  }) {
    final working = lastSets.where((s) => s.setType != 'warmup' && s.weightKg > 0).toList();
    if (working.isEmpty) return null;
    final top = working.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
    final topSets = working.where((s) => s.weightKg == top).toList();
    final allHit = topSets.every((s) => s.reps >= targetReps);
    final bestReps = topSets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
    if (allHit) {
      final step = isCompound ? 2.5 : 1.25;
      return OverloadSuggestion(weightKg: top + step, change: OverloadChange.increase, deltaKg: step);
    }
    if (bestReps <= targetReps - 3) {
      final reduced = (top * 0.95 / 1.25).round() * 1.25;
      return OverloadSuggestion(weightKg: reduced, change: OverloadChange.decrease, deltaKg: reduced - top);
    }
    return OverloadSuggestion(weightKg: top, change: OverloadChange.keep, deltaKg: 0);
  }

  /// Standard percentage table shown in the 1RM tool.
  static const percentTable = [100, 95, 90, 85, 80, 75, 70, 65, 60];

  /// Plates needed PER SIDE to reach [targetKg] with a [barKg] bar.
  /// Returns an empty list if the target is lighter than the bar.
  static PlateResult platesPerSide(
    double targetKg, {
    double barKg = 20,
    List<double> available = const [25, 20, 15, 10, 5, 2.5, 1.25],
  }) {
    if (targetKg <= barKg) return PlateResult(plates: const [], remainderKg: 0, achievedKg: barKg);
    var perSide = (targetKg - barKg) / 2;
    final plates = <double>[];
    for (final p in available) {
      while (perSide + 1e-9 >= p) {
        plates.add(p);
        perSide -= p;
      }
    }
    final loaded = plates.fold<double>(0, (a, b) => a + b);
    return PlateResult(
      plates: plates,
      remainderKg: double.parse((perSide * 2).toStringAsFixed(2)),
      achievedKg: barKg + loaded * 2,
    );
  }
}

class PlateResult {
  final List<double> plates;
  final double remainderKg;
  final double achievedKg;

  const PlateResult({required this.plates, required this.remainderKg, required this.achievedKg});
}

enum OverloadChange { increase, keep, decrease }

class OverloadSuggestion {
  final double weightKg;
  final OverloadChange change;
  final double deltaKg;

  const OverloadSuggestion({required this.weightKg, required this.change, required this.deltaKg});
}
