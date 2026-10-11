enum ExerciseKind { multipleChoice, trueFalse, fillBlank, matching, listening }

class ExerciseQuestion {
  const ExerciseQuestion({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.answer,
    this.choices = const [],
    this.spokenText,
  });

  final String id;
  final ExerciseKind kind;
  final String prompt;
  final String answer;
  final List<String> choices;
  final String? spokenText;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.level,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.questions,
  });

  final String id;
  final String languageCode;
  final String languageName;
  final String level;
  final String title;
  final String description;
  final int durationMinutes;
  final List<ExerciseQuestion> questions;
}
