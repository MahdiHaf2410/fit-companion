import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_companion/core/database/app_database.dart';

import '../generated_migrations/schema.dart';

/// Protects real users' data: a v2 database must upgrade to v3 without losing rows.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  for (final from in [2, 3]) {
    test('upgrade v$from -> v4 matches the v4 schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    });
  }

  test('v3 -> v4: old logs count as eaten, built-in programs become templates', () async {
    final schema = await verifier.schemaAt(3);
    final raw = schema.rawDatabase;
    raw.execute("INSERT INTO food_logs (id, date, timestamp, meal_type, quantity_g, food_name, calories, protein, carbs, fat) VALUES ('l1', '2026-11-01', 1761955200, 'lunch', 200, 'Rice', 260, 5, 56, 1)");
    raw.execute("INSERT INTO workout_programs (id, name, scheduled_days, created_at, updated_at) VALUES ('prog_push_hypertrophy', 'Push', 'Monday', 1761955200, 1761955200)");
    raw.execute("INSERT INTO workout_programs (id, name, scheduled_days, created_at, updated_at) VALUES ('my-own', 'My Upper', 'Monday', 1761955200, 1761955200)");
    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    final log = await db.select(db.foodLogs).getSingle();
    expect(log.isEaten, isTrue);
    expect(log.eatenAt, isNotNull);
    final progs = {for (final p in await db.select(db.workoutPrograms).get()) p.id: p.isTemplate};
    expect(progs['prog_push_hypertrophy'], isTrue);
    expect(progs['my-own'], isFalse);
    await db.close();
  });

  test('v2 data survives the upgrade and new columns get defaults', () async {
    final schema = await verifier.schemaAt(2);
    // Write v2 rows with raw SQL (independent of the current table classes).
    final raw = schema.rawDatabase;
    raw.execute("INSERT INTO body_metrics (id, date, timestamp, weight_kg) VALUES ('m1', '2026-11-01', 1761955200, 80.5)");
    raw.execute("INSERT INTO workout_sessions (id, start_time, status, total_volume_kg, total_completed_sets) VALUES ('s1', 1761955200, 'completed', 500, 1)");
    raw.execute("INSERT INTO exercises (id, name, muscle_group, equipment, exercise_type, is_custom) VALUES ('ex_x', 'X', 'chest', 'barbell', 'compound', 0)");
    raw.execute("INSERT INTO workout_sets (id, session_id, exercise_id, exercise_name, set_number, weight_kg, reps, is_completed, is_personal_record) VALUES ('w1', 's1', 'ex_x', 'X', 1, 100, 5, 1, 1)");

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    final metric = await db.select(db.bodyMetrics).getSingle();
    expect(metric.weightKg, 80.5);
    expect(metric.chestCm, isNull);

    final set = await db.select(db.workoutSets).getSingle();
    expect(set.weightKg, 100);
    expect(set.setType, 'normal');
    expect(set.rpe, isNull);

    expect(await db.select(db.mealTemplates).get(), isEmpty);
    await db.seedInitialData(); // base exercises (FKs are enforced from v3)
    await db.ensureSeedV3();
    final programs = await (db.select(db.workoutPrograms)..where((p) => p.id.like('prog_531%'))).get();
    expect(programs.length, 4);
    await db.ensureSeedV3(); // idempotent
    await db.close();
  });
}
