import 'dart:math' as math;

/// Pure, offline "smart coach" analytics (unit-tested, no Flutter imports).

// =============================================================================
// Adaptive TDEE
// =============================================================================

class TdeeResult {
  final double tdee; // real maintenance calories
  final double avgIntake; // average logged calories per full day
  final double weeklyChangeKg; // weight trend (kg / week)
  final int daysLogged;
  final int weighIns;
  final int spanDays;
  final String confidence; // high | medium | low

  const TdeeResult({
    required this.tdee,
    required this.avgIntake,
    required this.weeklyChangeKg,
    required this.daysLogged,
    required this.weighIns,
    required this.spanDays,
    required this.confidence,
  });
}

class AdaptiveTdee {
  AdaptiveTdee._();

  /// Energy in 1 kg of body-weight change (mixed tissue), kcal.
  static const kcalPerKg = 7700.0;

  /// [dailyIntake]: calories eaten per day (only eaten items), keyed by day.
  /// [weights]: (date, kg) weigh-ins. Uses the last [windowDays] days.
  /// Returns null when there is not enough data yet.
  static TdeeResult? compute({
    required Map<DateTime, double> dailyIntake,
    required List<(DateTime, double)> weights,
    DateTime? now,
    int windowDays = 28,
  }) {
    final end = now ?? DateTime.now();
    final start = end.subtract(Duration(days: windowDays));
    // Days with < 800 kcal are probably incomplete logs: ignore them.
    final days = dailyIntake.entries.where((e) => e.key.isAfter(start) && e.value >= 800).toList();
    final w = weights.where((e) => e.$1.isAfter(start)).toList()..sort((a, b) => a.$1.compareTo(b.$1));
    if (days.length < 10 || w.length < 4) return null;
    final span = w.last.$1.difference(w.first.$1).inDays;
    if (span < 14) return null;

    // Least-squares slope of weight over time (kg/day): robust to daily water noise.
    final t0 = w.first.$1;
    final xs = [for (final e in w) e.$1.difference(t0).inHours / 24.0];
    final ys = [for (final e in w) e.$2];
    final mx = xs.reduce((a, b) => a + b) / xs.length;
    final my = ys.reduce((a, b) => a + b) / ys.length;
    double num = 0, den = 0;
    for (int i = 0; i < xs.length; i++) {
      num += (xs[i] - mx) * (ys[i] - my);
      den += (xs[i] - mx) * (xs[i] - mx);
    }
    final slope = den == 0 ? 0.0 : num / den; // kg per day

    final avgIntake = days.fold<double>(0, (a, e) => a + e.value) / days.length;
    final tdee = avgIntake - slope * kcalPerKg;
    final confidence = days.length >= 21 && w.length >= 8
        ? 'high'
        : (days.length >= 14 && w.length >= 5 ? 'medium' : 'low');
    return TdeeResult(
      tdee: tdee.clamp(1200, 6000).toDouble(),
      avgIntake: avgIntake,
      weeklyChangeKg: slope * 7,
      daysLogged: days.length,
      weighIns: w.length,
      spanDays: span,
      confidence: confidence,
    );
  }

  /// Calorie target for a goal, based on the measured TDEE.
  static int targetFor(String goalType, double tdee) {
    final t = switch (goalType) {
      'muscleGain' => tdee + 250,
      'fatLoss' => tdee - 450,
      'recomposition' => tdee - 150,
      _ => tdee,
    };
    return (math.max(1200, t) / 10).round() * 10;
  }
}

// =============================================================================
// Fatigue / deload detection
// =============================================================================

/// One exercise performance inside a completed session.
class ExercisePerf {
  final String exerciseId;
  final DateTime date;
  final double bestE1rm;
  final double? avgRpe;

  const ExercisePerf(this.exerciseId, this.date, this.bestE1rm, [this.avgRpe]);
}

enum FatigueLevel { fresh, watch, deload }

class FatigueReport {
  final FatigueLevel level;
  final List<String> reasons; // codes: declining:<n>, high_rpe, long_block:<weeks>
  final List<String> decliningExercises;

  const FatigueReport(this.level, this.reasons, this.decliningExercises);
}

class FatigueAnalyzer {
  FatigueAnalyzer._();

  /// [perfs]: last ~8 weeks of performances. [sessionDates]: completed workout days.
  static FatigueReport analyze({required List<ExercisePerf> perfs, required List<DateTime> sessionDates, DateTime? now}) {
    final today = now ?? DateTime.now();
    final reasons = <String>[];

    // (a) Exercises whose best e1RM dropped in each of the last 2 sessions.
    final byEx = <String, List<ExercisePerf>>{};
    for (final p in perfs) {
      byEx.putIfAbsent(p.exerciseId, () => []).add(p);
    }
    final declining = <String>[];
    byEx.forEach((id, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
      if (list.length >= 3) {
        final n = list.length;
        if (list[n - 1].bestE1rm < list[n - 2].bestE1rm * 0.985 && list[n - 2].bestE1rm < list[n - 3].bestE1rm * 0.985) {
          declining.add(id);
        }
      }
    });
    if (declining.isNotEmpty) reasons.add('declining:${declining.length}');

    // (b) Very high effort lately (average RPE ≥ 9 over the last 14 days).
    final recentRpe = perfs
        .where((p) => p.avgRpe != null && today.difference(p.date).inDays <= 14)
        .map((p) => p.avgRpe!)
        .toList();
    final highRpe = recentRpe.length >= 4 && recentRpe.reduce((a, b) => a + b) / recentRpe.length >= 9;
    if (highRpe) reasons.add('high_rpe');

    // (c) Long hard block: consecutive weeks with ≥ 3 sessions.
    int weeks = 0;
    for (int w = 0; w < 12; w++) {
      final from = today.subtract(Duration(days: 7 * (w + 1)));
      final to = today.subtract(Duration(days: 7 * w));
      final c = sessionDates.where((d) => d.isAfter(from) && !d.isAfter(to)).length;
      if (c >= 3) {
        weeks++;
      } else {
        break;
      }
    }
    if (weeks >= 6) reasons.add('long_block:$weeks');

    final score = (declining.length >= 2 ? 2 : declining.length) + (highRpe ? 1 : 0) + (weeks >= 8 ? 2 : (weeks >= 6 ? 1 : 0));
    final level = score >= 3 ? FatigueLevel.deload : (score >= 1 ? FatigueLevel.watch : FatigueLevel.fresh);
    return FatigueReport(level, reasons, declining);
  }
}

// =============================================================================
// Live coach notes during a workout
// =============================================================================

enum CoachNoteType { skippedSet, weightDropping, missedReps, closeToPr }

class CoachNote {
  final CoachNoteType type;
  final double? value; // e.g. kg to the PR
  const CoachNote(this.type, [this.value]);
}

class WorkoutCoach {
  WorkoutCoach._();

  /// [setsDone]: completion flags of the current exercise in order.
  /// [recentTopWeights]: top working weight of the last sessions (oldest → newest).
  /// [lastReps]/[targetReps]: reps of the last session's working sets vs program target.
  /// [currentTop]/[prWeight]: today's heaviest planned weight and the all-time best.
  static List<CoachNote> notes({
    required List<bool> setsDone,
    List<double> recentTopWeights = const [],
    List<int> lastReps = const [],
    int? targetReps,
    double? currentTop,
    double? prWeight,
  }) {
    final notes = <CoachNote>[];
    // A later set was ticked while an earlier one is still open.
    final lastDone = setsDone.lastIndexOf(true);
    if (lastDone > 0 && setsDone.sublist(0, lastDone).contains(false)) notes.add(const CoachNote(CoachNoteType.skippedSet));
    // Top weight went down 2 sessions in a row.
    final n = recentTopWeights.length;
    if (n >= 3 && recentTopWeights[n - 1] < recentTopWeights[n - 2] && recentTopWeights[n - 2] < recentTopWeights[n - 3]) {
      notes.add(const CoachNote(CoachNoteType.weightDropping));
    }
    // Every working set last time fell short of the target.
    if (targetReps != null && lastReps.isNotEmpty && lastReps.every((r) => r < targetReps)) {
      notes.add(const CoachNote(CoachNoteType.missedReps));
    }
    // Within reach of a personal record today.
    if (currentTop != null && prWeight != null && prWeight > 0) {
      final gap = prWeight - currentTop;
      if (gap > 0 && gap <= 2.5) notes.add(CoachNote(CoachNoteType.closeToPr, gap));
    }
    return notes;
  }
}

// =============================================================================
// Sleep vs performance
// =============================================================================

class SleepReport {
  final double avgHours; // last 7 nights with data
  final int nights;
  /// Workout volume after good nights (≥ 7 h) vs short nights, in % (null if not enough data).
  final double? performanceDiffPct;
  final int goodSessions;
  final int poorSessions;

  const SleepReport(this.avgHours, this.nights, this.performanceDiffPct, this.goodSessions, this.poorSessions);
}

class SleepAnalyzer {
  SleepAnalyzer._();
  static const goodNight = 7.0;

  /// [sleep]: hours per wake-up day. [sessions]: (start time, total volume kg).
  static SleepReport? analyze({required Map<DateTime, double> sleep, required List<(DateTime, double)> sessions, DateTime? now}) {
    if (sleep.isEmpty) return null;
    final today = now ?? DateTime.now();
    DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
    final recent = sleep.entries.where((e) => today.difference(e.key).inDays < 7).map((e) => e.value).toList();
    final avg = recent.isEmpty ? 0.0 : recent.reduce((a, b) => a + b) / recent.length;

    final withSleep = [for (final s in sessions) if (sleep[day(s.$1)] != null && s.$2 > 0) (sleep[day(s.$1)]!, s.$2)];
    double? diff;
    int good = 0, poor = 0;
    if (withSleep.length >= 4) {
      final mean = withSleep.map((e) => e.$2).reduce((a, b) => a + b) / withSleep.length;
      final g = [for (final e in withSleep) if (e.$1 >= goodNight) e.$2 / mean];
      final p = [for (final e in withSleep) if (e.$1 < goodNight) e.$2 / mean];
      good = g.length;
      poor = p.length;
      if (g.length >= 2 && p.length >= 2) {
        final ga = g.reduce((a, b) => a + b) / g.length;
        final pa = p.reduce((a, b) => a + b) / p.length;
        diff = (ga - pa) / pa * 100;
      }
    }
    return SleepReport(avg, recent.length, diff, good, poor);
  }
}
