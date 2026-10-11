import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants.navy,
      brightness: Brightness.light,
      primary: AppConstants.navy,
      secondary: AppConstants.gold,
      surface: AppConstants.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppConstants.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.canvas,
        foregroundColor: AppConstants.navy,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppConstants.gold, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.white,
        indicatorColor: AppConstants.gold.withValues(alpha: 0.2),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
      ),
      dividerColor: const Color(0xFFE3E8EF),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants.navy,
      brightness: Brightness.dark,
      primary: const Color(0xFF91B9E7),
      secondary: AppConstants.gold,
      surface: const Color(0xFF1D1D1D),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppConstants.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.dark,
        foregroundColor: AppConstants.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF20242B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFF353B45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppConstants.gold, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: AppConstants.gold.withValues(alpha: 0.22),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
      ),
      dividerColor: const Color(0xFF353B45),
    );
  }
}
