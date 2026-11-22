import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';

class WeightPoint {
  final DateTime date;
  final double weightKg;
  final double? movingAverageKg;

  WeightPoint({
    required this.date,
    required this.weightKg,
    this.movingAverageKg,
  });
}

class ProgressRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProgressRepository(this._db);

  Stream<List<BodyMetric>> watchMetrics({int? limitDays}) {
    final query = _db.select(_db.bodyMetrics)
      ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]);
    
    if (limitDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: limitDays));
      query.where((m) => m.timestamp.isBiggerOrEqualValue(cutoff));
    }

    return query.watch();
  }

  Future<BodyMetric?> getLatestMetric() async {
    final query = _db.select(_db.bodyMetrics)
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<BodyMetric?> watchLatestMetric() {
    final query = _db.select(_db.bodyMetrics)
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<void> logMetric({
    required double weightKg,
    double? waistCm,
    double? chestCm,
    double? armCm,
    double? thighCm,
    double? hipsCm,
    double? bodyFatPercent,
    String? notes,
    DateTime? date,
  }) async {
    final timestamp = date ?? DateTime.now();
    final dateStr = "${timestamp.year.toString().padLeft(4, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}";

    await _db.into(_db.bodyMetrics).insert(
      BodyMetricsCompanion.insert(
        id: _uuid.v4(),
        date: dateStr,
        timestamp: timestamp,
        weightKg: weightKg,
        waistCm: Value(waistCm),
        chestCm: Value(chestCm),
        armCm: Value(armCm),
        thighCm: Value(thighCm),
        hipsCm: Value(hipsCm),
        bodyFatPercent: Value(bodyFatPercent),
        notes: Value(notes),
      ),
    );

    // Also update current weight on profile
    final profile = await (_db.select(_db.profiles)..limit(1)).getSingleOrNull();
    if (profile != null) {
      await (_db.update(_db.profiles)..where((p) => p.id.equals(profile.id))).write(
        ProfilesCompanion(
          currentWeightKg: Value(weightKg),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> deleteMetric(String id) async {
    await (_db.delete(_db.bodyMetrics)..where((m) => m.id.equals(id))).go();
  }

  /// Calculates a 7-day moving average series from raw weight logs
  static List<WeightPoint> calculateMovingAverages(List<BodyMetric> rawMetrics) {
    if (rawMetrics.isEmpty) return [];

    final result = <WeightPoint>[];
    for (int i = 0; i < rawMetrics.length; i++) {
      final current = rawMetrics[i];
      // Collect all points within previous 7 days
      final windowStart = current.timestamp.subtract(const Duration(days: 7));
      final windowPoints = rawMetrics.where((m) =>
          m.timestamp.isAfter(windowStart) &&
          !m.timestamp.isAfter(current.timestamp)).toList();

      double sum = 0;
      for (final p in windowPoints) {
        sum += p.weightKg;
      }
      final avg = sum / windowPoints.length;

      result.add(WeightPoint(
        date: current.timestamp,
        weightKg: current.weightKg,
        movingAverageKg: double.parse(avg.toStringAsFixed(1)),
      ));
    }

    return result;
  }
}
