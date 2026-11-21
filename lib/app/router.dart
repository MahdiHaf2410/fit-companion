import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_scaffold_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/nutrition/presentation/food_search_screen.dart';
import '../features/nutrition/presentation/add_food_screen.dart';
import '../features/nutrition/presentation/custom_food_screen.dart';
import '../features/nutrition/presentation/recipe_builder_screen.dart';
import '../features/nutrition/presentation/nutrition_calculator_screen.dart';
import '../features/nutrition/presentation/smart_food_calculator_screen.dart';
import '../features/nutrition/presentation/academy_screen.dart';
import '../features/nutrition/presentation/lesson_detail_screen.dart';
import '../features/workouts/presentation/workouts_screen.dart';
import '../features/workouts/presentation/program_details_screen.dart';
import '../features/workouts/presentation/create_program_screen.dart';
import '../features/workouts/presentation/active_workout_screen.dart';
import '../features/workouts/presentation/exercise_library_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/progress/presentation/add_metric_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/data_export_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final profileAsync = ref.watch(profileStreamProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      // Check if user is onboarded
      final profile = profileAsync.value;
      final isOnboardingLocation = state.matchedLocation == '/onboarding';

      if (profileAsync.hasValue) {
        final isOnboarded = profile != null && profile.isOnboarded;
        if (!isOnboarded && !isOnboardingLocation) {
          return '/onboarding';
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
          return AppScaffoldShell(navigationShell: navigationShell);
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
        builder: (context, state) => const CustomFoodScreen(),
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
        builder: (context, state) => const CreateProgramScreen(),
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
