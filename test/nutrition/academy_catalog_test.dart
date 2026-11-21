import 'package:flutter_test/flutter_test.dart';
import 'package:fit_companion/features/nutrition/domain/academy_lesson.dart';

void main() {
  group('AcademyCatalog - 14 Lessons & Quizzes Integrity', () {
    test('Contains exactly 14 lessons in correct chronological order', () {
      final lessons = AcademyCatalog.lessons;
      expect(lessons.length, equals(14));

      for (int i = 0; i < lessons.length; i++) {
        expect(lessons[i].number, equals(i + 1));
      }
    });

    test('All lessons contain complete bilingual metadata and non-empty content', () {
      final lessons = AcademyCatalog.lessons;

      for (final lesson in lessons) {
        expect(lesson.id, isNotEmpty);
        expect(lesson.titleEn, isNotEmpty);
        expect(lesson.titleAr, isNotEmpty);
        expect(lesson.categoryEn, isNotEmpty);
        expect(lesson.categoryAr, isNotEmpty);
        expect(lesson.explanationEn, isNotEmpty);
        expect(lesson.explanationAr, isNotEmpty);
        expect(lesson.workedExampleEn, isNotEmpty);
        expect(lesson.workedExampleAr, isNotEmpty);
        expect(lesson.takeawayEn, isNotEmpty);
        expect(lesson.takeawayAr, isNotEmpty);

        // Quiz Integrity
        final quiz = lesson.quiz;
        expect(quiz.questionEn, isNotEmpty);
        expect(quiz.questionAr, isNotEmpty);
        expect(quiz.optionsEn.length, greaterThanOrEqualTo(2));
        expect(quiz.optionsAr.length, equals(quiz.optionsEn.length));
        expect(quiz.correctOptionIndex, inInclusiveRange(0, quiz.optionsEn.length - 1));
        expect(quiz.explanationEn, isNotEmpty);
        expect(quiz.explanationAr, isNotEmpty);
      }
    });

    test('All lesson IDs are unique', () {
      final lessons = AcademyCatalog.lessons;
      final ids = lessons.map((l) => l.id).toSet();
      expect(ids.length, equals(lessons.length));
    });
  });
}
