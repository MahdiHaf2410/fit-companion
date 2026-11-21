import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/providers/database_provider.dart';
import '../data/progress_repository.dart';

final progressTimeRangeDaysProvider = StateProvider<int?>((ref) => 30); // Default 1 month

final bodyMetricsStreamProvider = StreamProvider<List<BodyMetric>>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  final days = ref.watch(progressTimeRangeDaysProvider);
  return repo.watchMetrics(limitDays: days);
});

final latestBodyMetricProvider = StreamProvider<BodyMetric?>((ref) {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.watchLatestMetric();
});

final weightTrendSeriesProvider = Provider<List<WeightPoint>>((ref) {
  final metricsAsync = ref.watch(bodyMetricsStreamProvider);
  final metrics = metricsAsync.value ?? [];
  return ProgressRepository.calculateMovingAverages(metrics);
});
