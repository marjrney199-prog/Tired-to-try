import 'package:flutter_test/flutter_test.dart';
import 'package:ea_language_hub/services/translation_service.dart';

void main() {
  const service = TranslationService();

  group('TranslationService offline glossary', () {
    test('translates an exact included word', () {
      final result = service.translate(input: 'hello', sourceCode: 'en', targetCode: 'pt');
      expect(result.text, 'olá');
      expect(result.matchedTerms, 1);
      expect(result.unknownTerms, isEmpty);
    });

    test('translates an included multi-word phrase', () {
      final result = service.translate(input: 'I need help', sourceCode: 'en', targetCode: 'fr');
      expect(result.text, 'J’ai besoin d’aide');
      expect(result.isComplete, isTrue);
    });

    test('keeps unknown words visible and reports them', () {
      final result = service.translate(input: 'Hello, moon!', sourceCode: 'en', targetCode: 'pt');
      expect(result.text, 'Olá, moon!');
      expect(result.unknownTerms, contains('moon'));
    });

    test('returns original text for the same source and target language', () {
      final result = service.translate(input: 'Good morning!', sourceCode: 'en', targetCode: 'en');
      expect(result.text, 'Good morning!');
      expect(result.unknownTerms, isEmpty);
    });
  });
}
