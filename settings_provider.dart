import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/storage/local_storage.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  Future<void> load() async {
    themeMode = LocalStorage.darkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await LocalStorage.setDarkMode(value);
    notifyListeners();
  }
}
