import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';

class UserProfileService {
  static final UserProfileService instance = UserProfileService._init();

  UserProfileService._init();

  static const _prefsKeyPrefix = 'user_profile_';

  final ValueNotifier<UserProfile> profileNotifier = ValueNotifier(UserProfile.empty());

  UserProfile get profile => profileNotifier.value;

  String _keyForCurrentUser() {
    final uid = AuthService.getCurrentUserId();
    return '$_prefsKeyPrefix${uid ?? 'anonymous'}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForCurrentUser();
    final raw = prefs.getString(key);

    final fallbackName = AuthService.getCurrentUserName() ?? '';

    if (raw == null || raw.trim().isEmpty) {
      profileNotifier.value = UserProfile.empty(fullName: fallbackName);
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final loaded = UserProfile.fromJson(decoded);
        profileNotifier.value = loaded.fullName.trim().isEmpty
            ? loaded.copyWith(fullName: fallbackName)
            : loaded;
      } else {
        profileNotifier.value = UserProfile.empty(fullName: fallbackName);
      }
    } catch (e) {
      debugPrint('UserProfileService.load error: $e');
      profileNotifier.value = UserProfile.empty(fullName: fallbackName);
    }
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForCurrentUser();
    await prefs.setString(key, jsonEncode(profile.toJson()));
    profileNotifier.value = profile;

    // Keep Firebase display name in sync when possible.
    final name = profile.fullName.trim();
    if (name.isNotEmpty && AuthService.currentUser != null) {
      try {
        await AuthService.currentUser!.updateDisplayName(name);
        await AuthService.currentUser!.reload();
      } catch (_) {
        // best effort
      }
    }
  }
}
