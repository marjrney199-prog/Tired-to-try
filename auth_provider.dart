import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);
  final AuthService _service;

  AppUser? currentUser;
  bool isReady = false;

  Future<void> restore() async {
    try {
      currentUser = await _service.restoreSession().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
    } catch (_) {
      currentUser = null;
    } finally {
      isReady = true;
      notifyListeners();
    }
  }

  Future<AuthResult> register({required String name, required String email, required String password}) async {
    final result = await _service.register(name: name, email: email, password: password);
    currentUser = result.user;
    notifyListeners();
    return result;
  }

  Future<AppUser> login({required String email, required String password}) async {
    final user = await _service.login(email: email, password: password);
    currentUser = user;
    notifyListeners();
    return user;
  }

  Future<void> recoverPassword({required String email, required String recoveryCode, required String newPassword}) =>
      _service.recoverPassword(email: email, recoveryCode: recoveryCode, newPassword: newPassword);

  Future<AppUser> continueOffline() async {
    final user = await _service.continueOffline();
    currentUser = user;
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    await _service.logout();
    currentUser = null;
    notifyListeners();
  }
}
