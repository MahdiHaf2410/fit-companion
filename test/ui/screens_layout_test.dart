import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fit_companion/core/database/app_database.dart';
import 'package:fit_companion/core/theme/app_theme.dart';
import 'package:fit_companion/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fit_companion/features/nutrition/presentation/nutrition_screen.dart';
import 'package:fit_companion/features/profile/presentation/profile_providers.dart';
import 'package:fit_companion/features/progress/presentation/progress_screen.dart';
import 'package:fit_companion/features/tools/presentation/gym_tools_screen.dart';
import 'package:fit_companion/features/ai/ai_tools.dart';
import 'package:fit_companion/features/challenges/challenges.dart';
import 'package:fit_companion/features/social/social.dart';
import 'package:fit_companion/features/workouts/presentation/workouts_screen.dart';
import 'package:fit_companion/features/workouts/presentation/active_workout_screen.dart';
import 'package:fit_companion/features/workouts/data/workout_repository.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:fit_companion/shared/providers/database_provider.dart';
import 'package:fit_companion/shared/providers/settings_provider.dart';

/// Pumps every redesigned screen on a small phone (360×740) in EN + AR and in
/// light + dark mode. Any RenderFlex overflow makes the test fail.
void main() {
  final screens = <String, Widget Function()>{
    'dashboard': () => const DashboardScreen(),
    'nutrition': () => const NutritionScreen(),
    'workouts': () => const WorkoutsScreen(),
    'progress': () => const ProgressScreen(),
    'tools': () => const GymToolsScreen(),
    'challenges': () => const ChallengesScreen(),
    'weekly report': () => const WeeklyReportScreen(),
    'program builder': () => const ProgramBuilderScreen(),
    'meal plan': () => const MealPlanScreen(),
    'friends': () => const FriendsScreen(),
    'active workout': () => const ActiveWorkoutScreen(),
    'dashboard (active)': () => const DashboardScreen(),
  };

  for (final lang in ['en', 'ar']) {
    for (final dark in [false, true]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} renders without overflow ($lang, ${dark ? 'dark' : 'light'})', (tester) async {
          SharedPreferences.setMockInitialValues({'user_locale': lang});
          final prefs = await SharedPreferences.getInstance();
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          await db.seedInitialData();
          if (entry.key.contains('active')) {
            final repo = WorkoutRepository(db);
            final prog = await repo.watchProgramDetails('prog_push_hypertrophy').first;
            await repo.startWorkoutSession(
              programId: prog!.program.id,
              programName: prog.program.name,
              exercises: prog.exercises,
            );
          }

          tester.view.physicalSize = const Size(360, 740);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(prefs),
                databaseProvider.overrideWithValue(db),
                profileStreamProvider.overrideWith((ref) => Stream.value(null)),
                goalStreamProvider.overrideWith((ref) => Stream.value(null)),
              ],
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                locale: Locale(lang),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: entry.value(),
              ),
            ),
          );

          // Let streams emit and entrance animations finish.
          for (int i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 150));
          }
          expect(tester.takeException(), isNull);
          // Sanity: the screen actually loaded data (not stuck on a spinner).
          if (entry.key == 'active workout') expect(find.byType(TextField), findsWidgets);
          if (entry.key == 'workouts') {
            // Programs are below the stats + muscle map, scroll to them.
            await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
            for (int i = 0; i < 4; i++) {
              await tester.pump(const Duration(milliseconds: 150));
            }
            // Built-in programs are now templates behind the "Ready-made programs" card.
            expect(find.byIcon(Icons.auto_awesome_rounded, skipOffstage: false), findsWidgets);
          }

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(milliseconds: 100));
          await db.close();
        });
      }
    }
  }
}
