class Lexeme {
  const Lexeme({
    required this.id,
    required this.forms,
    required this.definition,
    required this.partOfSpeech,
    required this.example,
    this.pronunciations = const {},
    this.synonyms = const [],
    this.antonyms = const [],
  });

  final String id;
  final Map<String, String> forms;
  final String definition;
  final String partOfSpeech;
  final String example;
  final Map<String, String> pronunciations;
  final List<String> synonyms;
  final List<String> antonyms;

  String formFor(String code) => forms[code] ?? forms['en'] ?? id;
  String pronunciationFor(String code) => pronunciations[code] ?? formFor(code);
}
