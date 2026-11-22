import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/demo_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/cloud_service.dart';
import 'core/services/health_service.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/notification_service.dart';
import 'shared/providers/database_provider.dart';
import 'shared/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for theme and locale
  final sharedPreferences = await SharedPreferences.getInstance();

  // Single database instance shared by the whole app (seeded on startup).
  // Using one instance guarantees that every drift stream gets notified of writes.
  // `flutter run --dart-define=DEMO=true` opens a separate demo database filled
  // with sample data (handy for screenshots / trying features). Real data untouched.
  const demo = bool.fromEnvironment('DEMO');
  final db = AppDatabase(fileName: demo ? 'fit_companion_demo.sqlite' : 'fit_companion.sqlite');
  await db.seedInitialData();
  await db.ensureSeedV3();
  if (demo) await DemoData.seedIfEmpty(db);

  // Cloud sync + AI coach (Supabase free plan). The app keeps working offline
  // if initialisation fails (no network on first launch, etc.).
  var cloudEnabled = true;
  try {
    await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.publishableKey);
  } catch (_) {
    cloudEnabled = false;
  }

  final notifications = LocalNotificationService();
  try {
    await notifications.init();
  } catch (_) {
    // Never block app start because of a notification plugin problem.
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
        healthServiceProvider.overrideWithValue(HealthConnectService()),
        homeWidgetServiceProvider.overrideWithValue(AndroidHomeWidgetService()),
        cloudServiceProvider.overrideWithValue(CloudService(db, enabled: cloudEnabled)),
      ],
      child: const FitCompanionApp(),
    ),
  );
}
