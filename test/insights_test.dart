import 'package:fit_companion/core/utils/insights.dart';
import 'package:fit_companion/features/challenges/challenges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 20);

  group('AdaptiveTdee', () {
    test('returns null without enough data', () {
      expect(AdaptiveTdee.compute(dailyIntake: {}, weights: [], now: now), isNull);
    });

    test('stable weight → TDEE equals intake', () {
      final intake = {for (int i = 1; i <= 21; i++) now.subtract(Duration(days: i)): 2500.0};
      final w = [for (int i = 0; i < 6; i++) (now.subtract(Duration(days: 3 + i * 4)), 80.0)];
      final r = AdaptiveTdee.compute(dailyIntake: intake, weights: w, now: now)!;
      expect(r.tdee, closeTo(2500, 1));
      expect(r.weeklyChangeKg, closeTo(0, 0.001));
    });

    test('losing 0.5 kg/week at 2000 kcal → TDEE ≈ 2550', () {
      final intake = {for (int i = 1; i <= 21; i++) now.subtract(Duration(days: i)): 2000.0};
      final w = [
        for (int i = 0; i < 8; i++) (now.subtract(Duration(days: 22 - i * 3)), 80 - (0.5 / 7) * (i * 3)),
      ];
      final r = AdaptiveTdee.compute(dailyIntake: intake, weights: w, now: now)!;
      expect(r.weeklyChangeKg, closeTo(-0.5, 0.01));
      expect(r.tdee, closeTo(2550, 10));
      expect(r.confidence, 'high');
    });

    test('targetFor goals', () {
      expect(AdaptiveTdee.targetFor('muscleGain', 2500), 2750);
      expect(AdaptiveTdee.targetFor('fatLoss', 2500), 2050);
      expect(AdaptiveTdee.targetFor('maintenance', 2504), 2500);
      expect(AdaptiveTdee.targetFor('fatLoss', 1300), 1200);
    });
  });

  group('FatigueAnalyzer', () {
    test('fresh when nothing declines', () {
      final perfs = [for (int i = 0; i < 4; i++) ExercisePerf('bench', now.subtract(Duration(days: 20 - i * 5)), 100.0 + i)];
      expect(FatigueAnalyzer.analyze(perfs: perfs, sessionDates: [], now: now).level, FatigueLevel.fresh);
    });

    test('deload when several lifts decline with high RPE', () {
      List<ExercisePerf> down(String id) => [
            ExercisePerf(id, now.subtract(const Duration(days: 12)), 100, 9.5),
            ExercisePerf(id, now.subtract(const Duration(days: 8)), 95, 9.5),
            ExercisePerf(id, now.subtract(const Duration(days: 3)), 90, 9.5),
          ];
      final r = FatigueAnalyzer.analyze(perfs: [...down('bench'), ...down('squat')], sessionDates: [], now: now);
      expect(r.level, FatigueLevel.deload);
      expect(r.reasons, containsAll(['declining:2', 'high_rpe']));
    });

    test('long block detected', () {
      final dates = [for (int w = 0; w < 7; w++) for (int d = 0; d < 3; d++) now.subtract(Duration(days: w * 7 + d * 2))];
      final r = FatigueAnalyzer.analyze(perfs: [], sessionDates: dates, now: now);
      expect(r.reasons.any((c) => c.startsWith('long_block:')), isTrue);
      expect(r.level, FatigueLevel.watch);
    });
  });

  group('WorkoutCoach', () {
    test('notes', () {
      final n = WorkoutCoach.notes(
        setsDone: [false, true],
        recentTopWeights: [100, 97.5, 95],
        lastReps: [6, 7],
        targetReps: 8,
        currentTop: 98,
        prWeight: 100,
      );
      expect(n.map((e) => e.type), [
        CoachNoteType.skippedSet,
        CoachNoteType.weightDropping,
        CoachNoteType.missedReps,
        CoachNoteType.closeToPr,
      ]);
      expect(WorkoutCoach.notes(setsDone: [true, true, false]), isEmpty);
    });
  });

  group('Levels', () {
    test('XP curve', () {
      expect(LevelInfo(0).level, 1);
      expect(LevelInfo(99).level, 1);
      expect(LevelInfo(100).level, 2);
      expect(LevelInfo(300).level, 3);
      expect(LevelInfo(450).progress, closeTo(0.5, 0.001));
    });

    test('week starts on Saturday', () {
      expect(weekStart(DateTime(2026, 11, 20)), DateTime(2026, 11, 14)); // Fri → Sat before
      expect(weekStart(DateTime(2026, 11, 21)), DateTime(2026, 11, 21)); // Sat
    });
  });

  group('SleepAnalyzer', () {
    test('better volume after good nights', () {
      final sleep = <DateTime, double>{};
      final sessions = <(DateTime, double)>[];
      for (int i = 0; i < 6; i++) {
        final d = DateTime(2026, 11, 10 + i);
        sleep[d] = i.isEven ? 8 : 5.5;
        sessions.add((d.add(const Duration(hours: 18)), i.isEven ? 11000 : 10000));
      }
      final r = SleepAnalyzer.analyze(sleep: sleep, sessions: sessions, now: DateTime(2026, 11, 16))!;
      expect(r.performanceDiffPct, closeTo(10, 0.01));
      expect(r.goodSessions, 3);
      expect(r.nights, 6);
    });
    test('null without sleep data', () {
      expect(SleepAnalyzer.analyze(sleep: {}, sessions: []), isNull);
    });
  });
}
