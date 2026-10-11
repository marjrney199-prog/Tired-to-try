import '../data/seed_data.dart';
import '../models/translation_result.dart';

/// Tradutor estritamente offline baseado no vocabulário e nas frases incluídas
/// em SeedData. Não finge traduzir texto geral nem depende de uma API.
class TranslationService {
  const TranslationService();

  static final RegExp _wordPattern = RegExp(
    r'[A-Za-zÀ-ÖØ-öø-ÿĀ-ž\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\u4E00-\u9FFF]+',
    unicode: true,
  );
  static final RegExp _trailingPunctuation = RegExp(r'[.!?,;:؟。،]+$');
  static final RegExp _leadingPunctuation = RegExp(r'^[.!?,;:؟。，]+');

  TranslationResult translate({
    required String input,
    required String sourceCode,
    required String targetCode,
  }) {
    if (input.trim().isEmpty) {
      return const TranslationResult(text: '', matchedTerms: 0, unknownTerms: []);
    }
    if (sourceCode == targetCode) {
      return TranslationResult(text: input, matchedTerms: 0, unknownTerms: []);
    }

    final normalizedInput = _normalizePhrase(input);
    for (final lexeme in SeedData.lexemes) {
      if (_normalizePhrase(lexeme.formFor(sourceCode)) == normalizedInput) {
        return TranslationResult(
          text: _preserveOuterWhitespace(input, lexeme.formFor(targetCode)),
          matchedTerms: 1,
          unknownTerms: const [],
        );
      }
    }

    var working = input;
    var matched = 0;
    final unknown = <String>{};
    final protectedPhrases = <String>[];
    final phrases = SeedData.lexemes
        .where((item) => item.formFor(sourceCode).trim().contains(' '))
        .toList()
      ..sort((a, b) => b.formFor(sourceCode).length.compareTo(a.formFor(sourceCode).length));

    for (final lexeme in phrases) {
      final source = lexeme.formFor(sourceCode);
      if (source.trim().isEmpty) continue;
      final pattern = RegExp(RegExp.escape(source), caseSensitive: false, unicode: true);
      working = working.replaceAllMapped(pattern, (match) {
        final placeholder = '\uE000${protectedPhrases.length}\uE001';
        protectedPhrases.add(_matchCase(match.group(0) ?? '', lexeme.formFor(targetCode)));
        matched++;
        return placeholder;
      });
    }

    working = working.replaceAllMapped(_wordPattern, (match) {
      final token = match.group(0) ?? '';
      final key = token.toLowerCase();
      for (final lexeme in SeedData.lexemes) {
        if (lexeme.formFor(sourceCode).toLowerCase() == key) {
          matched++;
          return _matchCase(token, lexeme.formFor(targetCode));
        }
      }
      // Pontuação e capitalização são preservadas; palavras desconhecidas
      // ficam visíveis para que o utilizador saiba onde o dicionário não chegou.
      unknown.add(token);
      return token;
    });

    for (var index = 0; index < protectedPhrases.length; index++) {
      working = working.replaceAll('\uE000$index\uE001', protectedPhrases[index]);
    }
    return TranslationResult(
      text: working,
      matchedTerms: matched,
      unknownTerms: unknown.toList(),
    );
  }

  String _normalizePhrase(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(_trailingPunctuation, '')
      .replaceAll(_leadingPunctuation, '');

  String _preserveOuterWhitespace(String original, String translated) {
    final leading = RegExp(r'^\s*').firstMatch(original)?.group(0) ?? '';
    final trailing = RegExp(r'\s*$').firstMatch(original)?.group(0) ?? '';
    final core = original.trim();
    final matches = _wordPattern.allMatches(core).toList();
    if (matches.isEmpty) return original;
    final first = matches.first;
    final last = matches.last;
    final prefix = core.substring(0, first.start);
    final suffix = core.substring(last.end);
    final cased = _matchCase(first.group(0) ?? '', translated);
    return '$leading$prefix$cased$suffix$trailing';
  }

  String _matchCase(String source, String target) {
    if (source.isEmpty || target.isEmpty) return target;
    if (source.length > 1 && source == source.toUpperCase() && source != source.toLowerCase()) return target.toUpperCase();
    if (source[0] == source[0].toUpperCase()) {
      return '${target[0].toUpperCase()}${target.substring(1)}';
    }
    return target;
  }
}
