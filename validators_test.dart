import 'package:flutter_test/flutter_test.dart';
import 'package:ea_language_hub/core/utils/validators.dart';

void main() {
  group('FormValidators', () {
    test('accepts a valid email and rejects malformed values', () {
      expect(FormValidators.email('utilizador@example.org'), isNull);
      expect(FormValidators.email('sem-arroba'), isNotNull);
    });

    test('requires a sufficiently long password', () {
      expect(FormValidators.password('curta'), isNotNull);
      expect(FormValidators.password('segura123'), isNull);
    });

    test('trims and checks names', () {
      expect(FormValidators.name(' A '), isNotNull);
      expect(FormValidators.name(' Ana Maria '), isNull);
    });
  });
}
