import 'package:flutter/material.dart';

class AppThemes {
  static ThemeMode getThemeMode(String themeType) {
    return themeType == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static ThemeData getLightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData getDarkTheme(String themeType, Color seedColor) {
    if (themeType == 'amoled') {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          background: Colors.black,
          surface: Colors.black,
        ),
      );
    }
    // Default Dark Theme
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        background: const Color(0xFF0a0a0a),
        surface: const Color(0xFF111111),
      ),
    );
  }
}
