import 'package:flutter/material.dart';
import 'dart:developer' show log;
import '../services/auth_service.dart';
import '../services/pantry_service.dart';
import '../models/inventory_item.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';
import 'pantry_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_screen.dart';
import 'profile_screen.dart';

// Modern Color Palette
class AppTheme {
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1F2937); // Gray 800
  static const Color textLight = Color(0xFF6B7280); // Gray 500
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
            child: const Text(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${DateTime.now().hour < 12 ? 'Morning' : 'Evening'},',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userName?.split(' ').first ?? 'Chef',
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
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
                  tooltip: 'Sign Out',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search your pantry...',
          hintStyle: TextStyle(color: AppTheme.textLight),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'At a Glance',
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
                'Total Items',
                totalItems,
                Icons.inventory_2_outlined,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                'Expiring',
                expiringSoon,
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                'Low Stock',
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
            style: const TextStyle(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
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
                    title: 'My Pantry',
                    subtitle: 'Manage inventory',
                    icon: Icons.kitchen_rounded,
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantryScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: 'Add Items',
                    subtitle: 'Scan or type',
                    icon: Icons.add_circle_outline_rounded,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: 'Shopping List',
                    subtitle: 'Plan purchases',
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
                    title: 'Recipes',
                    subtitle: 'What to cook?',
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
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
              color: AppTheme.primary.withOpacity(0.3),
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You saved \$24 this week!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
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
  }

  Widget _buildBottomNav() {
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
              _buildNavItem(Icons.home_rounded, 'Home', 0, false),
              _buildNavItem(
                Icons.inventory_2_rounded,
                'Pantry',
                1,
                false,
                onTap: () => _onBottomNavTapped(1),
              ),
              _buildNavItem(
                Icons.center_focus_strong_rounded,
                'Scan',
                2,
                true,
                onTap: () => _onBottomNavTapped(2),
              ),
              _buildNavItem(
                Icons.restaurant_rounded,
                'Cooking',
                3,
                false,
                onTap: () => _onBottomNavTapped(3),
              ),
              _buildNavItem(
                Icons.person_rounded,
                'Profile',
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
