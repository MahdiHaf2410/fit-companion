import 'package:fit_companion/core/services/cloud_service.dart';
import 'package:fit_companion/core/utils/exercise_video.dart';
import 'package:fit_companion/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Override o) => ProviderScope(
      overrides: [o],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SizedBox(width: 360, child: ExerciseVideoPlayer(englishName: 'Dumbbell Fly'))),
      ),
    );

void main() {
  test('YouTube search link for an exercise', () {
    final u = exerciseVideoUri('Dumbbell Fly');
    expect(u.host, 'www.youtube.com');
    expect(u.queryParameters['search_query'], 'Dumbbell Fly exercise proper form');
  });

  test('cache key normalisation matches the Edge Function', () {
    expect(ExerciseVideo.normalize('  Dumbbell   FLY '), 'dumbbell fly');
    expect(ExerciseVideo.listFrom([
      {'id': 'abc', 'title': 'T', 'channel': 'C'},
      {'bad': 1},
    ]).single.id, 'abc');
    expect(ExerciseVideo.listFrom(null), isEmpty);
  });

  testWidgets('no video → open-in-YouTube fallback', (tester) async {
    await tester.pumpWidget(_app(exerciseVideosProvider.overrideWith((ref, name) async => const <ExerciseVideo>[])));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Open in YouTube'), findsOneWidget);
  });

  testWidgets('not signed in → sign-in hint', (tester) async {
    await tester.pumpWidget(_app(exerciseVideosProvider.overrideWith((ref, name) async => throw CoachException('unauthorized'))));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('cached video → thumbnail with title and another-video button', (tester) async {
    await tester.pumpWidget(_app(exerciseVideosProvider.overrideWith(
        (ref, name) async => const [ExerciseVideo('a1', 'How to fly', 'Coach'), ExerciseVideo('b2', 'Fly form', 'Gym')])));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('How to fly'), findsOneWidget);
    await tester.tap(find.text('Another video'));
    await tester.pump();
    expect(find.text('Fly form'), findsOneWidget);
  });
}
