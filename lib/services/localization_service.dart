import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService instance = LocalizationService._init();

  LocalizationService._init();

  static const _prefsKey = 'app_locale';

  final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.trim().isEmpty) return;
    localeNotifier.value = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    localeNotifier.value = locale;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    localeNotifier.value = const Locale('en');
  }
}
