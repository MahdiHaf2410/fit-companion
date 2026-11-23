import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_scaffold_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/nutrition/presentation/food_search_screen.dart';
import '../features/nutrition/presentation/add_food_screen.dart';
import '../features/nutrition/presentation/my_food_screen.dart';
import '../features/nutrition/presentation/food_photo_screen.dart';
import '../features/nutrition/presentation/recipe_builder_screen.dart';
import '../features/nutrition/presentation/nutrition_calculator_screen.dart';
import '../features/nutrition/presentation/smart_food_calculator_screen.dart';
import '../features/nutrition/presentation/academy_screen.dart';
import '../features/nutrition/presentation/lesson_detail_screen.dart';
import '../features/workouts/presentation/workouts_screen.dart';
import '../features/workouts/presentation/program_details_screen.dart';
import '../features/workouts/presentation/program_editor_screen.dart';
import '../features/workouts/presentation/templates_screen.dart';
import '../features/workouts/presentation/active_workout_screen.dart';
import '../features/workouts/presentation/exercise_library_screen.dart';
import '../features/workouts/presentation/session_detail_screen.dart';
import '../features/workouts/presentation/exercise_detail_screen.dart';
import '../features/tools/presentation/gym_tools_screen.dart';
import '../features/achievements/achievements_screen.dart';
import '../features/settings/reminders_screen.dart';
import '../features/nutrition/presentation/barcode_scan_screen.dart';
import '../core/services/home_widget_service.dart';
import '../features/settings/backup_screen.dart';
import '../features/settings/cloud_screen.dart';
import '../features/settings/themes_screen.dart';
import '../features/coach/coach_screen.dart';
import '../features/settings/health_screen.dart';
import '../features/progress/presentation/progress_photos_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/progress/presentation/add_metric_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/data_export_screen.dart';
import '../core/services/cloud_service.dart' show isAuthCallback, pendingAuthCallback;
import '../features/ai/ai_tools.dart';
import '../features/challenges/challenges.dart';
import '../features/social/social.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // The router is created ONCE. Profile changes (e.g. logging weight updates the
  // profile) only trigger a redirect re-evaluation instead of rebuilding the whole
  // GoRouter, which previously reset navigation back to /home.
  final refresh = ValueNotifier<int>(0);
  ref.listen(profileStreamProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // INITIAL_ROUTE is a dev helper (e.g. --dart-define=INITIAL_ROUTE=/workouts)
    initialLocation: const String.fromEnvironment('INITIAL_ROUTE', defaultValue: '/home'),
    refreshListenable: refresh,
    redirect: (context, state) {
      // E-mail confirmation link → finish the sign-in on the Cloud screen (not a "page not found").
      if (isAuthCallback(state.uri)) {
        pendingAuthCallback.value = state.uri;
        return '/settings/cloud';
      }
      // Check if user is onboarded
      final profileAsync = ref.read(profileStreamProvider);
      final profile = profileAsync.value;
      final isOnboardingLocation = state.matchedLocation == '/onboarding';

      if (profileAsync.hasValue) {
        final isOnboarded = profile != null && profile.isOnboarded;
        if (!isOnboarded && !isOnboardingLocation) {
          return '/onboarding';
        }
        // Leave onboarding as soon as the saved profile arrives (works whatever the
        // timing between context.go('/home') and the drift stream re-emitting).
        if (isOnboarded && isOnboardingLocation) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeWidgetSync(child: AppScaffoldShell(navigationShell: navigationShell));
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Nutrition
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nutrition',
                builder: (context, state) => const NutritionScreen(),
              ),
            ],
          ),

          // Branch 2: Workouts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const WorkoutsScreen(),
              ),
            ],
          ),

          // Branch 3: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Secondary Screens pushed over the bottom bar
      GoRoute(
        path: '/nutrition/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final meal = state.uri.queryParameters['meal'];
          return FoodSearchScreen(initialMealType: meal);
        },
      ),
      GoRoute(
        path: '/nutrition/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final foodId = state.uri.queryParameters['foodId'] ?? '';
          final meal = state.uri.queryParameters['meal'];
          return AddFoodScreen(foodId: foodId, initialMealType: meal);
        },
      ),
      GoRoute(
        path: '/nutrition/custom',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MyFoodScreen(mealType: state.uri.queryParameters['meal']),
      ),
      GoRoute(
        path: '/nutrition/recipe/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecipeBuilderScreen(),
      ),
      GoRoute(
        path: '/nutrition/calculator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NutritionCalculatorScreen(),
      ),
      GoRoute(
        path: '/nutrition/food-calculator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final foodId = state.uri.queryParameters['foodId'];
          final meal = state.uri.queryParameters['meal'];
          return SmartFoodCalculatorScreen(initialFoodId: foodId, initialMealType: meal);
        },
      ),
      GoRoute(
        path: '/nutrition/academy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AcademyScreen(),
      ),
      GoRoute(
        path: '/nutrition/academy/lesson/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final lessonId = state.pathParameters['id'] ?? '';
          return LessonDetailScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/workouts/programs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WorkoutsScreen(),
      ),
      GoRoute(
        path: '/workouts/programs/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProgramEditorScreen(),
      ),
      GoRoute(
        path: '/workouts/program/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProgramEditorScreen(programId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/workouts/templates',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TemplatesScreen(),
      ),
      GoRoute(
        path: '/workouts/program/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final programId = state.pathParameters['id'] ?? '';
          return ProgramDetailsScreen(programId: programId);
        },
      ),
      GoRoute(
        path: '/workouts/active',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActiveWorkoutScreen(),
      ),
      GoRoute(
        path: '/workouts/exercises',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: '/workouts/session/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SessionDetailScreen(sessionId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/workouts/exercise/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ExerciseDetailScreen(exerciseId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/settings/reminders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/nutrition/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BarcodeScanScreen(mealType: state.uri.queryParameters['meal']),
      ),
      GoRoute(
        path: '/settings/backup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/settings/health',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthScreen(),
      ),
      GoRoute(
        path: '/progress/photos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProgressPhotosScreen(),
      ),
      GoRoute(
        path: '/settings/cloud',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CloudScreen(),
      ),
      GoRoute(
        path: '/ai/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WeeklyReportScreen(),
      ),
      GoRoute(
        path: '/ai/program',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProgramBuilderScreen(),
      ),
      GoRoute(
        path: '/ai/meals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MealPlanScreen(),
      ),
      GoRoute(
        path: '/friends',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/challenges',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: '/coach',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CoachScreen(),
      ),
      GoRoute(
        path: '/settings/themes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ThemesScreen(),
      ),
      GoRoute(
        path: '/nutrition/photo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => FoodPhotoScreen(mealType: state.uri.queryParameters['meal']),
      ),
      GoRoute(
        path: '/tools',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GymToolsScreen(),
      ),
      GoRoute(
        path: '/progress/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddMetricScreen(),
      ),
      GoRoute(
        path: '/profile/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DataExportScreen(),
      ),
    ],
  );
});
