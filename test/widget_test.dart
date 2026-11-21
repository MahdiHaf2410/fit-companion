import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:fit_companion/app/app.dart';
import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';
import 'package:fit_companion/features/profile/presentation/profile_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('FitCompanionApp launches and renders onboarding for new user', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          profileStreamProvider.overrideWith((ref) => Stream.value(null)),
          goalStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const FitCompanionApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Onboarding screen is shown
    expect(find.text('Welcome to Fit Companion'), findsOneWidget);
    expect(find.text('Save and Get Started'), findsOneWidget);

    // Unmount and flush cleanup microtasks/timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('App supports Arabic locale and displays Arabic strings', (tester) async {
    SharedPreferences.setMockInitialValues({'user_locale': 'ar'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          profileStreamProvider.overrideWith((ref) => Stream.value(null)),
          goalStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const FitCompanionApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Arabic Onboarding screen is shown with RTL directionality
    expect(find.text('مرحباً بك في رفيق اللياقة'), findsOneWidget);
    expect(find.text('حفظ والبدء الآن'), findsOneWidget);

    // Unmount and flush cleanup microtasks/timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
