import 'package:flutter_test/flutter_test.dart';
import 'package:ea_language_hub/core/utils/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('creates a salted SHA-256 based key and verifies it', () {
      final salt = PasswordHasher.newSalt();
      final hash = PasswordHasher.hash('PalavraSegura2026!', salt);
      expect(hash, hasLength(64));
      expect(PasswordHasher.verify('PalavraSegura2026!', salt, hash), isTrue);
      expect(PasswordHasher.verify('outra palavra-passe', salt, hash), isFalse);
    });

    test('generates a recovery code in a readable grouped format', () {
      final code = PasswordHasher.newRecoveryCode();
      expect(code.split('-'), hasLength(4));
      expect(code.replaceAll('-', ''), hasLength(16));
    });
  });
}
