import 'package:drift/native.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/database/seed_v4.dart';
import 'package:fit_companion/core/database/seed_v5.dart';
import 'package:fit_companion/core/utils/exercise_video.dart';
import 'package:fit_companion/features/workouts/presentation/exercise_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extended catalogue: ids unique, valid groups/equipment, Arabic names present', () {
    final all = [...SeedV4.exercises, ...SeedV5.exercises];
    expect(all.map((e) => e.$1).toSet().length, all.length);
    expect(all.map((e) => e.$2.toLowerCase()).toSet().length, all.length);
    for (final e in SeedV5.exercises) {
      expect(kMuscleGroups, contains(e.$4), reason: e.$1);
      expect(kEquipments, contains(e.$5), reason: e.$1);
      expect(e.$3.trim(), isNotEmpty, reason: e.$1);
    }
    expect(SeedV5.exercises.length, greaterThanOrEqualTo(270));
  });

  test('new exercises are inserted on start, also for existing databases (idempotent)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedInitialData();
    await db.ensureSeedV3();
    await db.ensureSeedV3(); // second start: no duplicates, no error
    final rows = await db.select(db.exercises).get();
    final ids = rows.map((e) => e.id).toSet();
    expect(ids, containsAll(['ex_bench_press', 'ex_zercher_squat', 'ex_turkish_getup', 'ex_supine_neck_bridge']));
    expect(rows.length, ids.length);
    expect(rows.length, greaterThanOrEqualTo(400));
    final band = rows.firstWhere((e) => e.id == 'ex_band_pull_apart');
    expect(band.equipment, 'band');
    expect(band.nameAr, 'فتح المطاط');
    await db.close();
  });

  test('video search drops "(reps = seconds)" hints', () {
    expect(videoSearchName('Copenhagen Plank (reps = seconds)'), 'Copenhagen Plank');
    expect(videoSearchName('Muscle-Up (Bar)'), 'Muscle-Up (Bar)');
    expect(exerciseVideoUri('L-Sit (reps = seconds)').queryParameters['search_query'], 'L-Sit exercise proper form');
  });
}
