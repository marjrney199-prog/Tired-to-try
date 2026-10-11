import 'package:flutter_test/flutter_test.dart';
import 'package:ea_language_hub/data/seed_data.dart';
import 'package:ea_language_hub/models/lesson.dart';

void main() {
  test('each supported language and CEFR level has three offline lessons', () {
    for (final language in SeedData.languages) {
      for (final level in SeedData.levels) {
        final lessons = SeedData.lessonsFor(language.code, level);
        expect(lessons, hasLength(3), reason: '${language.name} $level');
        for (final lesson in lessons) {
          expect(lesson.questions, hasLength(5));
          expect(lesson.questions.map((question) => question.kind).toSet(), containsAll(ExerciseKind.values));
        }
      }
    }
  });
}
