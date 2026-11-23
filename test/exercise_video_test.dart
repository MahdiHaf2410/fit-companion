import 'package:fit_companion/core/utils/exercise_video.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('YouTube search link for an exercise', () {
    final u = exerciseVideoUri('Dumbbell Fly');
    expect(u.host, 'www.youtube.com');
    expect(u.path, '/results');
    expect(u.queryParameters['search_query'], 'Dumbbell Fly exercise proper form');
    expect(u.toString(), contains('Dumbbell+Fly'));
  });
}
