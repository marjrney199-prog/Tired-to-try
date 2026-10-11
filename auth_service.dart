import 'dart:math';

import '../core/storage/local_storage.dart';
import '../core/utils/password_hasher.dart';
import '../core/utils/validators.dart';
import '../models/app_user.dart';
import '../repositories/user_repository.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({required this.user, this.recoveryCode});
  final AppUser user;
  final String? recoveryCode;
}

class AuthService {
  AuthService(this._users);
  final UserRepository _users;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nameError = FormValidators.name(name);
    final emailError = FormValidators.email(email);
    final passwordError = FormValidators.password(password);
    if (nameError != null) throw AuthException(nameError);
    if (emailError != null) throw AuthException(emailError);
    if (passwordError != null) throw AuthException(passwordError);
    if (await _users.byEmail(email) != null) {
      throw const AuthException('Este endereço de e-mail já está registado.');
    }

    final id = _newId();
    final passwordSalt = PasswordHasher.newSalt();
    final recoveryCode = PasswordHasher.newRecoveryCode();
    final recoverySalt = PasswordHasher.newSalt();
    final createdAt = DateTime.now();
    final record = <String, dynamic>{
      'id': id,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': PasswordHasher.hash(password, passwordSalt),
      'password_salt': passwordSalt,
      'recovery_hash': PasswordHasher.hash(recoveryCode, recoverySalt),
      'recovery_salt': recoverySalt,
      'created_at': createdAt.toIso8601String(),
      'is_active': 1,
    };

    try {
      await _users.create(record);
    } on StateError catch (error) {
      throw AuthException(error.message);
    }
    final user = AppUser.fromMap(record);
    await LocalStorage.saveSession(user.id);
    return AuthResult(user: user, recoveryCode: recoveryCode);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final record = await _users.byEmail(email);
    if (record == null || !PasswordHasher.verify(
      password,
      record['password_salt']?.toString() ?? '',
      record['password_hash']?.toString() ?? '',
    )) {
      throw const AuthException('E-mail ou palavra-passe incorrectos.');
    }
    final isActive = (record['is_active'] ?? 1) == 1 || record['is_active'] == true;
    if (!isActive) throw const AuthException('Esta conta local está desactivada.');
    final user = AppUser.fromMap(record);
    await LocalStorage.saveSession(user.id);
    return user;
  }

  Future<void> recoverPassword({
    required String email,
    required String recoveryCode,
    required String newPassword,
  }) async {
    final emailError = FormValidators.email(email);
    final passwordError = FormValidators.password(newPassword);
    if (emailError != null) throw AuthException(emailError);
    if (passwordError != null) throw AuthException(passwordError);
    final user = await _users.byEmail(email);
    if (user == null || !PasswordHasher.verify(
      recoveryCode.trim().replaceAll(' ', '').toUpperCase(),
      user['recovery_salt']?.toString() ?? '',
      user['recovery_hash']?.toString() ?? '',
    )) {
      throw const AuthException('E-mail ou código de recuperação incorrectos.');
    }
    final salt = PasswordHasher.newSalt();
    await _users.updatePassword(user['id'].toString(), PasswordHasher.hash(newPassword, salt), salt);
  }

  Future<AppUser> continueOffline() async {
    final now = DateTime.now();
    final random = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    final user = AppUser(
      id: 'guest_${now.microsecondsSinceEpoch}_$random',
      name: 'Utilizador Offline',
      email: '',
      createdAt: now,
    );
    await _users.create({
      ...user.toPublicMap(),
      'password_hash': '',
      'password_salt': '',
      'recovery_hash': '',
      'recovery_salt': '',
    });
    await LocalStorage.saveSession(user.id);
    return user;
  }

  Future<AppUser?> restoreSession() async {
    final id = LocalStorage.sessionUserId;
    if (id == null) return null;
    final record = await _users.byId(id);
    if (record == null) {
      await LocalStorage.saveSession(null);
      return null;
    }
    final isActive = (record['is_active'] ?? 1) == 1 || record['is_active'] == true;
    if (!isActive) {
      await LocalStorage.saveSession(null);
      return null;
    }
    return AppUser.fromMap(record);
  }

  Future<void> logout() => LocalStorage.saveSession(null);

  String _newId() {
    final random = Random.secure();
    return '${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(0x7fffffff).toRadixString(16)}';
  }
}
