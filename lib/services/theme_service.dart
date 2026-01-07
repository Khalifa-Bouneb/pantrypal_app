import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService instance = ThemeService._init();
  static const String _themeKey = 'is_dark_mode';

  ThemeService._init();

  // Default to light for deterministic visuals; user can toggle to dark.
  // Using ThemeMode.system caused mismatches with custom per-screen theming.
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    if (isDark != null) {
      themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
}
