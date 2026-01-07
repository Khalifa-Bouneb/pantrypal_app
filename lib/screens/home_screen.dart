import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' show log;
import '../services/auth_service.dart';
import '../services/pantry_service.dart';
import '../models/inventory_item.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';
import 'pantry_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'recipe_generation_screen.dart';
import '../l10n/app_localizations.dart';

// Modern Color Palette
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';

// Modern Color Palette - Dynamic based on Theme
class AppTheme {
  static bool get _isDark => ThemeService.instance.isDarkMode;

  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  
  static Color get primaryLight => _isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5); // Emerald 900 vs 100
  static Color get background => _isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB); // Gray 900 vs 50
  static Color get surface => _isDark ? const Color(0xFF1F2937) : Colors.white; // Gray 800 vs White
  
  static Color get textDark => _isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937); // Gray 50 vs 800
  static Color get textLight => _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280); // Gray 400 vs 500
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  String? _userEmail;
  bool _loading = true;
  int _currentIndex = 0; // Track bottom nav index

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    PantryService.instance.loadItems(); // Load pantry data
    UserProfileService.instance.load(); // Load user profile (incl. avatar)
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        _userName = AuthService.getCurrentUserName();
        _userEmail = AuthService.getCurrentUserEmail();
        _loading = false;
      });
      log('Loaded user info - Name: $_userName, Email: $_userEmail');
    } catch (e) {
      log('Error loading user info: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.tr('sign_out_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(t.tr('sign_out_confirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              t.tr('cancel'),
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            child: Text(t.tr('sign_out')),
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
      log('Sign out error: $e');
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0: // Home
        // Stay here
        break;
      case 1: // Pantry
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantryScreen()),
        );
        break;
      case 2: // Scan (FAB)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        );
        break;
      case 3: // Cooking (Recipes)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecipesScreen()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildAlertsWrapper(), // Smart Alerts
                    const SizedBox(height: 24),
                    _buildPantryInsightsWrapper(), // Updated to use real data
                    const SizedBox(height: 24),
                    _buildQuickActionsGrid(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final t = AppLocalizations.of(context);
    final isDark = ThemeService.instance.isDarkMode;

    final headerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.primary.withOpacity(isDark ? 0.18 : 0.12),
        AppTheme.surface,
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        gradient: headerGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(isDark ? 0.12 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryDark.withOpacity(isDark ? 0.10 : 0.06),
              ),
            ),
          ),
          Column(
            children: [
              ValueListenableBuilder<UserProfile>(
                valueListenable: UserProfileService.instance.profileNotifier,
                builder: (context, profile, _) {
                  final avatarImage = _avatarDecorationImage(profile.avatarBase64);
                  final displayName = profile.fullName.trim().isNotEmpty
                      ? profile.fullName.trim()
                      : (_userName ?? 'Chef');

                  final initial = displayName.trim().isNotEmpty
                      ? displayName.trim()[0].toUpperCase()
                      : 'U';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateTime.now().hour < 12
                                ? t.tr('good_morning')
                                : t.tr('good_evening'),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName.split(' ').first,
                            style: TextStyle(
                              fontSize: 28,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryLight.withOpacity(0.5),
                                border: Border.all(
                                  color: AppTheme.surface.withOpacity(0.9),
                                  width: 2,
                                ),
                                image: avatarImage,
                              ),
                              child: avatarImage != null
                                  ? null
                                  : Center(
                                      child: Text(
                                        initial,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ThemeService.instance.isDarkMode
                                              ? AppTheme.primary
                                              : AppTheme.primaryDark,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: AppTheme.primaryDark,
                              ),
                              onPressed: _handleSignOut,
                              tooltip: t.tr('sign_out'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSearchField(),
            ],
          ),
        ],
      ),
    );
  }

  DecorationImage? _avatarDecorationImage(String avatarBase64) {
    final raw = avatarBase64.trim();
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

  Widget _buildSearchField() {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: t.tr('search_pantry_hint'),
          hintStyle: TextStyle(color: AppTheme.textLight),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAlertsWrapper() {
    return ValueListenableBuilder<List<InventoryItem>>(
      valueListenable: PantryService.instance.itemsNotifier,
      builder: (context, items, _) {
        final expiringItems = items
            .where((i) => i.isExpiringSoon || i.isExpired)
            .toList();

        if (expiringItems.isEmpty) return const SizedBox.shrink();

        return _buildAlertCard(expiringItems);
      },
    );
  }

  Widget _buildAlertCard(List<InventoryItem> expiringItems) {
    final t = AppLocalizations.of(context);
    final isDark = ThemeService.instance.isDarkMode;
    final count = expiringItems.length;
    final isPlural = count > 1;
    final topNames = expiringItems.take(3).map((e) => e.name).toList();
    final remaining = count - topNames.length;

    final bgColor = isDark ? AppTheme.surface : Colors.orange.shade50;
    final borderColor =
        isDark ? Colors.orange.shade700.withOpacity(0.35) : Colors.orange.shade200;
    final titleColor = isDark ? AppTheme.textDark : Colors.orange.shade900;
    final bodyColor = isDark ? AppTheme.textLight : Colors.orange.shade800;
    final chipBg = isDark ? AppTheme.background : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.orange).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: chipBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.tr('action_needed'),
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t
                            .tr('items_expiring_soon')
                            .replaceAll('{count}', '$count')
                            .replaceAll('{plural}', isPlural ? 's' : ''),
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                topNames.join(', ') + (remaining > 0 ? ' +$remaining more' : ''),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecipeGenerationScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.soup_kitchen_rounded, size: 18),
                    label: Text(t.tr('ai_chef')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final prompt =
                          'I have these items expiring soon: ${topNames.join(', ')}. '
                          'Suggest 2 quick meals to use them today and a short plan to reduce waste.';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(initialMessage: prompt),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleColor,
                      side: BorderSide(color: Colors.orange.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.smart_toy_rounded, size: 18),
                    label: Text(t.tr('ask')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper to listen to pantry service
  Widget _buildPantryInsightsWrapper() {
    return ValueListenableBuilder<List<InventoryItem>>(
      valueListenable: PantryService.instance.itemsNotifier,
      builder: (context, items, _) {
        // Calculate stats
        final totalItems = items.length;
        final expiringSoon = items
            .where((i) => i.isExpiringSoon || i.isExpired)
            .length;
        final lowStock = items.where((i) => i.quantity < 2).length;

        return _buildPantryInsights(
          totalItems: totalItems.toString(),
          expiringSoon: expiringSoon.toString(),
          lowStock: lowStock.toString(),
        );
      },
    );
  }

  Widget _buildPantryInsights({
    required String totalItems,
    required String expiringSoon,
    required String lowStock,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            AppLocalizations.of(context).tr('at_a_glance'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildInsightCard(
                AppLocalizations.of(context).tr('total_items'),
                totalItems,
                Icons.inventory_2_outlined,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                AppLocalizations.of(context).tr('expiring'),
                expiringSoon,
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                AppLocalizations.of(context).tr('low_stock'),
                lowStock,
                Icons.shopping_basket_outlined,
                Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.tr('quick_actions'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    title: t.tr('my_pantry'),
                    subtitle: t.tr('manage_inventory'),
                    icon: Icons.kitchen_rounded,
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantryScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: t.tr('add_items'),
                    subtitle: t.tr('scan_or_type'),
                    icon: Icons.add_circle_outline_rounded,
                    color: AppTheme.primaryDark,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: t.tr('shopping_list'),
                    subtitle: t.tr('plan_purchases'),
                    icon: Icons.checklist_rtl_rounded,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShoppingListScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    title: t.tr('recipes'),
                    subtitle: t.tr('what_to_cook'),
                    icon: Icons.restaurant_menu_rounded,
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipesScreen()),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final t = AppLocalizations.of(context);
    return ValueListenableBuilder<List<InventoryItem>>(
      valueListenable: PantryService.instance.itemsNotifier,
      builder: (context, items, _) {
        final now = DateTime.now();
        final expiring7 = items.where((i) {
          final d = i.expiryDate;
          if (d == null) return false;
          final diff = d.difference(now).inDays;
          return diff >= 0 && diff <= 7;
        }).length;
        final isPlural = expiring7 != 1;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_graph_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.tr('waste_saver'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t
                            .tr('waste_saver_subtitle')
                            .replaceAll('{count}', '$expiring7')
                            .replaceAll('{plural}', isPlural ? 's' : ''),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, t.tr('home'), 0, false),
              _buildNavItem(
                Icons.inventory_2_rounded,
                t.tr('pantry'),
                1,
                false,
                onTap: () => _onBottomNavTapped(1),
              ),
              _buildNavItem(
                Icons.center_focus_strong_rounded,
                t.tr('scan'),
                2,
                true,
                onTap: () => _onBottomNavTapped(2),
              ),
              _buildNavItem(
                Icons.restaurant_rounded,
                t.tr('cooking'),
                3,
                false,
                onTap: () => _onBottomNavTapped(3),
              ),
              _buildNavItem(
                Icons.person_rounded,
                t.tr('profile'),
                4,
                false,
                onTap: () => _onBottomNavTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    bool isFab, {
    VoidCallback? onTap,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppTheme.primary : AppTheme.textLight;

    // Default to home logic if no tap handler, but technically Home is index 0
    final tapHandler =
        onTap ??
        () {
          if (index == 0) _onBottomNavTapped(0);
        };

    if (isFab) {
      return GestureDetector(
        onTap: tapHandler,
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      );
    }

    return GestureDetector(
      onTap: tapHandler,
      child: Container(
        color: Colors.transparent, // Hit test target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
