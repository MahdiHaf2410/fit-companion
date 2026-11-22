import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

enum HealthAvailability { available, needsInstall, unavailable }

/// Health Connect (Android) integration: read today's steps, write body weight.
/// Apple Health is not used — this app targets Android only.
abstract class HealthService {
  Future<HealthAvailability> availability();
  Future<void> install();
  Future<bool> requestAccess();
  Future<bool> hasAccess();
  Future<int?> stepsToday();
  Future<bool> writeWeight(double kg, DateTime at);
  /// Hours slept per night (keyed by the wake-up day) over the last [days] days.
  Future<Map<DateTime, double>> sleepByNight(int days);
}

class NoopHealthService implements HealthService {
  @override
  Future<HealthAvailability> availability() async => HealthAvailability.unavailable;
  @override
  Future<void> install() async {}
  @override
  Future<bool> requestAccess() async => false;
  @override
  Future<bool> hasAccess() async => false;
  @override
  Future<int?> stepsToday() async => null;
  @override
  Future<bool> writeWeight(double kg, DateTime at) async => false;
  @override
  Future<Map<DateTime, double>> sleepByNight(int days) async => {};
}

class HealthConnectService implements HealthService {
  final _health = Health();
  bool _configured = false;

  static const _types = [HealthDataType.STEPS, HealthDataType.WEIGHT, HealthDataType.SLEEP_SESSION];
  static const _perms = [HealthDataAccess.READ, HealthDataAccess.READ_WRITE, HealthDataAccess.READ];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<HealthAvailability> availability() async {
    if (defaultTargetPlatform != TargetPlatform.android) return HealthAvailability.unavailable;
    try {
      await _configure();
      final s = await _health.getHealthConnectSdkStatus();
      return switch (s) {
        HealthConnectSdkStatus.sdkAvailable => HealthAvailability.available,
        HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired => HealthAvailability.needsInstall,
        _ => HealthAvailability.unavailable,
      };
    } catch (_) {
      return HealthAvailability.unavailable;
    }
  }

  @override
  Future<void> install() => _health.installHealthConnect();

  @override
  Future<bool> requestAccess() async {
    try {
      await _configure();
      return await _health.requestAuthorization(_types, permissions: _perms);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasAccess() async {
    try {
      await _configure();
      return await _health.hasPermissions([HealthDataType.STEPS], permissions: [HealthDataAccess.READ]) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int?> stepsToday() async {
    try {
      await _configure();
      final now = DateTime.now();
      return await _health.getTotalStepsInInterval(DateTime(now.year, now.month, now.day), now);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<DateTime, double>> sleepByNight(int days) async {
    try {
      await _configure();
      final ok = await _health.hasPermissions([HealthDataType.SLEEP_SESSION], permissions: [HealthDataAccess.READ]) ?? false;
      if (!ok) return {};
      final now = DateTime.now();
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.SLEEP_SESSION],
        startTime: now.subtract(Duration(days: days + 1)),
        endTime: now,
      );
      final out = <DateTime, double>{};
      for (final p in _health.removeDuplicates(points)) {
        final hours = p.dateTo.difference(p.dateFrom).inMinutes / 60.0;
        if (hours <= 0 || hours > 16) continue;
        final wake = DateTime(p.dateTo.year, p.dateTo.month, p.dateTo.day);
        out[wake] = (out[wake] ?? 0) + hours;
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  @override
  Future<bool> writeWeight(double kg, DateTime at) async {
    try {
      await _configure();
      return await _health.writeHealthData(value: kg, type: HealthDataType.WEIGHT, startTime: at, unit: HealthDataUnit.KILOGRAM);
    } catch (_) {
      return false;
    }
  }
}

/// Overridden with [HealthConnectService] in main.dart; tests keep the no-op.
final healthServiceProvider = Provider<HealthService>((ref) => NoopHealthService());

/// Whether the user turned the Health Connect sync on (SharedPreferences-backed via AppPreferences).
final healthStepsTodayProvider = FutureProvider.autoDispose<int?>((ref) async {
  final service = ref.watch(healthServiceProvider);
  if (!await service.hasAccess()) return null;
  return service.stepsToday();
});
