import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/hydration/presentation/water_providers.dart';
import '../../features/nutrition/presentation/nutrition_providers.dart';
import '../../l10n/app_localizations.dart';
import 'cloud_service.dart';

/// Pushes today's numbers to the Android home-screen widget (FitWidgetProvider.kt).
abstract class HomeWidgetService {
  Future<void> update({
    required String title,
    required String kcal,
    required String kcalLabel,
    required String protein,
    required String water,
    required int progress,
  });
}

class NoopHomeWidgetService implements HomeWidgetService {
  @override
  Future<void> update({
    required String title,
    required String kcal,
    required String kcalLabel,
    required String protein,
    required String water,
    required int progress,
  }) async {}
}

class AndroidHomeWidgetService implements HomeWidgetService {
  @override
  Future<void> update({
    required String title,
    required String kcal,
    required String kcalLabel,
    required String protein,
    required String water,
    required int progress,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('w_title', title),
        HomeWidget.saveWidgetData<String>('w_kcal', kcal),
        HomeWidget.saveWidgetData<String>('w_kcal_label', kcalLabel),
        HomeWidget.saveWidgetData<String>('w_protein', protein),
        HomeWidget.saveWidgetData<String>('w_water', water),
        HomeWidget.saveWidgetData<int>('w_progress', progress),
      ]);
      await HomeWidget.updateWidget(androidName: 'FitWidgetProvider');
    } catch (_) {
      // Widget not placed / plugin unavailable: ignore.
    }
  }
}

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) => NoopHomeWidgetService());

/// Invisible helper placed in the app shell: whenever today's summary or water
/// changes, the home-screen widget is refreshed.
class HomeWidgetSync extends ConsumerStatefulWidget {
  final Widget child;

  const HomeWidgetSync({super.key, required this.child});

  @override
  ConsumerState<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends ConsumerState<HomeWidgetSync> {
  late final AppLifecycleListener _lifecycle;
  DateTime _lastAutoSync = DateTime(2000);

  @override
  void initState() {
    super.initState();
    // Cloud auto-sync when the app goes to background (throttled to every 10 min).
    _lifecycle = AppLifecycleListener(onHide: () {
      if (DateTime.now().difference(_lastAutoSync) < const Duration(minutes: 10)) return;
      _lastAutoSync = DateTime.now();
      ref.read(cloudServiceProvider).autoPushIfSafe().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final l10n = AppLocalizations.of(context)!;
    final summary = ref.watch(todayNutritionSummaryProvider).value;
    final water = ref.watch(todayWaterProvider).value;
    final waterGoal = ref.watch(waterGoalProvider).value;
    if (summary != null) {
      final left = summary.caloriesRemaining;
      ref.read(homeWidgetServiceProvider).update(
            title: l10n.appTitle,
            kcal: left.abs().toInt().toString(),
            kcalLabel: left < 0 ? l10n.dashboardKcalOver : l10n.dashboardKcalLeft,
            protein: '${l10n.dashboardProtein} ${summary.proteinConsumed.toInt()}/${summary.targetProtein.toInt()}${l10n.commonGrams}',
            water: '💧 ${water ?? 0}/${waterGoal ?? 2500} ${l10n.commonMl}',
            progress: (summary.calorieProgress * 100).round(),
          );
    }
    return child;
  }
}
