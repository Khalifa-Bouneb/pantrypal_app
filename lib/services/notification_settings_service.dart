import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_settings.dart';
import 'auth_service.dart';

class NotificationSettingsService {
  static final NotificationSettingsService instance = NotificationSettingsService._init();

  NotificationSettingsService._init();

  static const _prefsKeyPrefix = 'notification_settings_';

  final ValueNotifier<NotificationSettings> settingsNotifier =
      ValueNotifier(NotificationSettings.defaults());

  NotificationSettings get settings => settingsNotifier.value;

  String _keyForCurrentUser() {
    final uid = AuthService.getCurrentUserId();
    return '$_prefsKeyPrefix${uid ?? 'anonymous'}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForCurrentUser());
    if (raw == null || raw.trim().isEmpty) {
      settingsNotifier.value = NotificationSettings.defaults();
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        settingsNotifier.value = NotificationSettings.fromJson(decoded);
      } else {
        settingsNotifier.value = NotificationSettings.defaults();
      }
    } catch (e) {
      debugPrint('NotificationSettingsService.load error: $e');
      settingsNotifier.value = NotificationSettings.defaults();
    }
  }

  Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForCurrentUser(), jsonEncode(settings.toJson()));
    settingsNotifier.value = settings;
  }
}
