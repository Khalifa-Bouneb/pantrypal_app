import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/llm_service.dart';
import '../services/user_profile_service.dart';
import '../services/notification_settings_service.dart';
import '../services/localization_service.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'home_screen.dart' show AppTheme;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _userEmail;
  bool _loadingProfile = true;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    _userName = AuthService.getCurrentUserName();
    _userEmail = AuthService.getCurrentUserEmail();

    Future.wait([
      UserProfileService.instance.load(),
      NotificationSettingsService.instance.load(),
    ]).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
      });
    });
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to end your session?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final userProfile = UserProfileService.instance.profile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          t.tr('profile'),
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _pickAndSaveAvatar,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryLight,
                            border: Border.all(color: AppTheme.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            image: _avatarDecorationImage(userProfile),
                          ),
                          child: _avatarDecorationImage(userProfile) != null
                              ? null
                              : Center(
                                  child: Text(
                                    (userProfile.fullName.trim().isNotEmpty
                                                ? userProfile.fullName.trim()
                                                : (_userName ?? 'User'))
                                            .trim()
                                            .isNotEmpty
                                        ? (userProfile.fullName.trim().isNotEmpty
                                                ? userProfile.fullName.trim()[0]
                                                : (_userName ?? 'U')[0])
                                            .toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.isDarkMode
                                          ? AppTheme.primary
                                          : AppTheme.primaryDark,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _pickAndSaveAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile.fullName.trim().isNotEmpty
                        ? userProfile.fullName.trim()
                        : (_userName ?? 'User Name'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail ?? 'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                  if ((userProfile.city.trim().isNotEmpty ||
                          userProfile.country.trim().isNotEmpty) &&
                      !_loadingProfile) ...[
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (userProfile.city.trim().isNotEmpty)
                          userProfile.city.trim(),
                        if (userProfile.country.trim().isNotEmpty)
                          userProfile.country.trim(),
                      ].join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                  if (_loadingProfile) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(color: AppTheme.primary),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            _buildSectionHeader(t.tr('account_settings')),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.person_outline_rounded,
              title: t.tr('personal_information'),
              onTap: _showEditProfileDialog,
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline_rounded,
              title: t.tr('security_password'),
              onTap: _showSecurityDialog,
            ),
            _buildSettingsTile(
              icon: Icons.key_rounded,
              title: t.tr('ai_model_settings'),
              onTap: _showApiKeyDialog,
            ),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: t.tr('notifications'),
              onTap: _showNotificationsDialog,
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(t.tr('preferences')),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.language_rounded,
              title: t.tr('language'),
              trailingText: _languageName(LocalizationService.instance.localeNotifier.value.languageCode),
              onTap: _showLanguageSelector,
            ),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: t.tr('dark_mode'),
              isSwitch: true,
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _handleSignOut,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade200),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: Text(t.tr('sign_out')),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
      default:
        return 'English';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
    bool isSwitch = false,
  }) {
    // Handling Switch logic specifically for Dark Mode
    if (isSwitch && title == 'Dark Mode') {
      return ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeService.instance.themeModeNotifier,
        builder: (context, themeMode, _) {
          final isDark = themeMode == ThemeMode.dark;
          return _buildTileContainer(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: _buildIcon(icon),
              title: _buildTitle(title),
              trailing: Switch(
                value: isDark,
                onChanged: (val) => ThemeService.instance.toggleTheme(val),
                activeThumbColor: AppTheme.primary,
              ),
            ),
          );
        },
      );
    }

    return _buildTileContainer(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _buildIcon(icon),
        title: _buildTitle(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppTheme.textDark, size: 22),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }

  DecorationImage? _avatarDecorationImage(UserProfile profile) {
    final raw = profile.avatarBase64.trim();
    if (raw.isEmpty) return null;
    try {
      final Uint8List bytes = base64Decode(raw);
      if (bytes.isEmpty) return null;
      return DecorationImage(
        image: MemoryImage(bytes),
        fit: BoxFit.cover,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickAndSaveAvatar() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (picked == null) return;

      final Uint8List bytes = await picked.readAsBytes();
      if (bytes.isEmpty) return;

      final updated = UserProfileService.instance.profile.copyWith(
        avatarBase64: base64Encode(bytes),
      );
      await UserProfileService.instance.save(updated);

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set photo: $e')),
      );
    }
  }

  // --- Actions ---

  void _showEditProfileDialog() {
    final t = AppLocalizations.of(context);
    final existing = UserProfileService.instance.profile;

    final nameController = TextEditingController(
      text: existing.fullName.trim().isNotEmpty ? existing.fullName : (_userName ?? ''),
    );
    final phoneController = TextEditingController(text: existing.phone);
    final countryController = TextEditingController(text: existing.country);
    final cityController = TextEditingController(text: existing.city);
    final addressController = TextEditingController(text: existing.addressLine);
    final householdController = TextEditingController(text: existing.householdSize.toString());
    final dietaryController = TextEditingController(text: existing.dietaryPreferences);
    final allergiesController = TextEditingController(text: existing.allergies);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(t.tr('personal_information')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: t.tr('full_name')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.tr('phone')),
              ),
              const SizedBox(height: 8),
              TextField(
                enabled: false,
                controller: TextEditingController(text: _userEmail ?? ''),
                decoration: InputDecoration(labelText: t.tr('email')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: t.tr('country')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: t.tr('city')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: t.tr('address')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: householdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.tr('household_size')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dietaryController,
                decoration: InputDecoration(labelText: t.tr('dietary_preferences')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: allergiesController,
                decoration: InputDecoration(labelText: t.tr('allergies')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final updated = existing.copyWith(
                fullName: nameController.text.trim(),
                phone: phoneController.text.trim(),
                country: countryController.text.trim(),
                city: cityController.text.trim(),
                addressLine: addressController.text.trim(),
                householdSize: int.tryParse(householdController.text.trim()) ?? existing.householdSize,
                dietaryPreferences: dietaryController.text.trim(),
                allergies: allergiesController.text.trim(),
              );

              UserProfileService.instance.save(updated);
              setState(() {
                _userName = updated.fullName.trim().isNotEmpty ? updated.fullName.trim() : _userName;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t.tr('personal_information')} ${t.tr('save')}d')),
              );
            },
            child: Text(t.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    final t = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(t.tr('security')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.tr('email')}: ${_userEmail ?? ''}', style: TextStyle(color: AppTheme.textLight)),
            const SizedBox(height: 8),
            Text(
              AuthService.isEmailVerified() ? 'Email verified' : 'Email not verified',
              style: TextStyle(
                color: AuthService.isEmailVerified() ? Colors.green.shade700 : Colors.orange.shade800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: _userEmail == null ? null : () async {
                  Navigator.pop(context);
                  await _showResetPasswordFlow();
                },
                icon: const Icon(Icons.email_outlined),
                label: Text(t.tr('reset_password')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _showChangePasswordFlow();
                },
                icon: const Icon(Icons.lock_reset_rounded),
                label: Text(t.tr('change_password')),
              ),
            ),
            if (!AuthService.isEmailVerified()) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await AuthService.sendEmailVerification();
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('${t.tr('verify_email')}: ${t.tr('send_link')}')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(t.tr('verify_email')),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.tr('cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetPasswordFlow() async {
    final t = AppLocalizations.of(context);
    final email = _userEmail;
    if (email == null || email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email found')));
      return;
    }
    try {
      await AuthService.sendPasswordReset(email: email.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.tr('reset_password')}: ${t.tr('send_link')}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _showChangePasswordFlow() async {
    final t = AppLocalizations.of(context);
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(t.tr('change_password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.tr('current_password')),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.tr('new_password')),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: t.tr('confirm_new_password')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.tr('cancel'))),
          FilledButton(
            onPressed: () async {
              final newPass = newController.text;
              if (newPass != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              try {
                await AuthService.changePassword(
                  currentPassword: currentController.text,
                  newPassword: newPass,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.tr('update_password'))),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            },
            child: Text(t.tr('update_password')),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    final t = AppLocalizations.of(context);
    var settings = NotificationSettingsService.instance.settings;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(t.tr('notification_settings')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: settings.expiryAlerts,
                  onChanged: (v) => setLocalState(() => settings = settings.copyWith(expiryAlerts: v)),
                  title: Text(t.tr('expiry_alerts')),
                ),
                SwitchListTile(
                  value: settings.lowStockAlerts,
                  onChanged: (v) => setLocalState(() => settings = settings.copyWith(lowStockAlerts: v)),
                  title: Text(t.tr('low_stock_alerts')),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(t.tr('lead_time_days'))),
                    DropdownButton<int>(
                      value: settings.leadDays,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0')),
                        DropdownMenuItem(value: 1, child: Text('1')),
                        DropdownMenuItem(value: 2, child: Text('2')),
                        DropdownMenuItem(value: 3, child: Text('3')),
                        DropdownMenuItem(value: 5, child: Text('5')),
                      ],
                      onChanged: (v) => setLocalState(() => settings = settings.copyWith(leadDays: v ?? 2)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.tr('cancel'))),
              FilledButton(
                onPressed: () async {
                  await NotificationSettingsService.instance.save(settings);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${t.tr('notifications')} ${t.tr('save')}d')),
                  );
                },
                child: Text(t.tr('save')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showApiKeyDialog() async {
    final service = LLMService();
    final keyController = TextEditingController(text: service.apiKey);
    final baseUrlController = TextEditingController(text: service.baseUrl);
    final modelController = TextEditingController(text: service.model);
    if (!mounted) return;

    var loadingModels = false;
    var models = <String>[];
    String? testStatus;
   
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('AI Model Settings'),
        content: StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> loadModels() async {
              setLocalState(() {
                loadingModels = true;
                testStatus = null;
              });
              try {
                final result = await service.listModelsForConfig(
                  baseUrl: baseUrlController.text.trim(),
                  apiKey: keyController.text.trim().isEmpty ? null : keyController.text.trim(),
                );
                setLocalState(() {
                  models = result;
                  loadingModels = false;
                  testStatus = result.isEmpty
                      ? 'Could not load models (check URL/key)'
                      : 'Connected: ${result.length} models';
                  if (result.isNotEmpty && modelController.text.trim().isEmpty) {
                    modelController.text = result.first;
                  }
                });
              } catch (e) {
                setLocalState(() {
                  loadingModels = false;
                  testStatus = 'Connection failed: $e';
                });
              }
            }

            final currentModel = modelController.text.trim();
            final modelInList = models.contains(currentModel);
            final dropdownValue = modelInList ? currentModel : (models.isNotEmpty ? models.first : null);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Use Groq (cloud) or Ollama (local open-source). For Ollama you can leave API key empty.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'API Key (optional for Ollama)',
                    hintText: 'gsk_... (Groq) or empty (Ollama)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://api.groq.com/openai/v1 OR http://localhost:11434/v1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'llama-3.1-8b-instant (Groq) or llama3.2 (Ollama)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loadingModels ? null : loadModels,
                        child: Text(loadingModels ? 'Testing...' : 'Test & Load Models'),
                      ),
                    ),
                  ],
                ),
                if (testStatus != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      testStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: testStatus!.startsWith('Connected') ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
                if (models.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Pick a model',
                      border: OutlineInputBorder(),
                    ),
                    items: models
                        .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      modelController.text = v;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          baseUrlController.text = 'http://localhost:11434/v1';
                          if (modelController.text.trim().isEmpty) {
                            modelController.text = 'llama3.2';
                          }
                        },
                        child: const Text('Use Ollama'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          baseUrlController.text = 'https://api.groq.com/openai/v1';
                          if (modelController.text.trim().isEmpty) {
                            modelController.text = 'llama-3.1-8b-instant';
                          }
                        },
                        child: const Text('Use Groq'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await service.saveConfig(
                keyController.text.trim(),
                baseUrl: baseUrlController.text.trim().isEmpty
                    ? null
                    : baseUrlController.text.trim(),
                model: modelController.text.trim().isEmpty
                    ? null
                    : modelController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI settings saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English'),
            trailing: LocalizationService.instance.localeNotifier.value.languageCode == 'en'
                ? const Icon(Icons.check, color: AppTheme.primary)
                : null,
            onTap: () async {
              await LocalizationService.instance.setLocale(const Locale('en'));
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('${t.tr('language')}: English')),
              );
            },
          ),
          ListTile(
            title: const Text('Français'),
            trailing: LocalizationService.instance.localeNotifier.value.languageCode == 'fr'
                ? const Icon(Icons.check, color: AppTheme.primary)
                : null,
            onTap: () async {
              await LocalizationService.instance.setLocale(const Locale('fr'));
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('${t.tr('language')}: Français')),
              );
            },
          ),
        ],
      ),
    );
  }
}


