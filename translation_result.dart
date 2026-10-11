class TranslationResult {
  const TranslationResult({
    required this.text,
    required this.matchedTerms,
    required this.unknownTerms,
  });

  final String text;
  final int matchedTerms;
  final List<String> unknownTerms;
  bool get isComplete => unknownTerms.isEmpty;
}
