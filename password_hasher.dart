import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Derivação local de palavras-passe usando PBKDF2-HMAC-SHA256 e salt aleatório.
/// É deliberadamente mais segura do que guardar SHA-256(password) sem salt.
class PasswordHasher {
  PasswordHasher._();

  static const int iterations = 60000;
  static const int keyLength = 32;
  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String newSalt({int bytes = 16}) {
    final random = Random.secure();
    return List<int>.generate(bytes, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String newRecoveryCode() {
    final random = Random.secure();
    final chars = List<String>.generate(16, (_) => _alphabet[random.nextInt(_alphabet.length)]);
    return '${chars.sublist(0, 4).join()}-${chars.sublist(4, 8).join()}-${chars.sublist(8, 12).join()}-${chars.sublist(12).join()}';
  }

  static String hash(String password, String saltHex) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = _decodeHex(saltHex);
    final hmac = Hmac(sha256, passwordBytes);
    final firstBlock = <int>[...saltBytes, 0, 0, 0, 1];
    var u = hmac.convert(firstBlock).bytes;
    final derived = List<int>.from(u);

    for (var round = 1; round < iterations; round++) {
      u = hmac.convert(u).bytes;
      for (var i = 0; i < derived.length; i++) {
        derived[i] ^= u[i];
      }
    }

    return derived.take(keyLength).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  }

  static bool verify(String password, String saltHex, String expectedHex) {
    if (saltHex.isEmpty || expectedHex.isEmpty) return false;
    final actual = hash(password, saltHex);
    if (actual.length != expectedHex.length) return false;
    var difference = 0;
    for (var i = 0; i < actual.length; i++) {
      difference |= actual.codeUnitAt(i) ^ expectedHex.codeUnitAt(i);
    }
    return difference == 0;
  }

  static List<int> _decodeHex(String value) {
    if (value.length.isOdd) throw const FormatException('Salt inválido.');
    return List<int>.generate(value.length ~/ 2, (index) => int.parse(value.substring(index * 2, index * 2 + 2), radix: 16));
  }
}
