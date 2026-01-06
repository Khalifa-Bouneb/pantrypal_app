import 'package:flutter/material.dart';
import 'home_screen.dart' show AppTheme;
// import '../models/inventory_item.dart'; // Will use later

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'My Pantry',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'Vegetables'),
            Tab(text: 'Fruits'),
            Tab(text: 'Protein'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPantryList(),
          const Center(child: Text('Vegetables Filter')),
          const Center(child: Text('Fruits Filter')),
          const Center(child: Text('Protein Filter')),
        ],
      ),
    );
  }

  Widget _buildPantryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Mock data
      itemBuilder: (context, index) {
        return _buildPantryItem(
          name: [
            'Tomatoes',
            'Bell Peppers',
            'Milk',
            'Spinach',
            'Yogurt',
          ][index],
          quantity: [
            '3 medium',
            '2 medium',
            '1 carton',
            '1 bunch',
            '2 cups',
          ][index],
          expiry: [
            'Expires in 1 day',
            'Expires in 2 days',
            'Expires in 3 days',
            'Expires in 2 days',
            'Expires in 4 days',
          ][index],
          icon: [
            Icons.circle,
            Icons.circle,
            Icons.local_drink,
            Icons.grass,
            Icons.local_cafe,
          ][index], // Placeholders
          color: [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.green,
            Colors.blue,
          ][index],
        );
      },
    );
  }

  Widget _buildPantryItem({
    required String name,
    required String quantity,
    required String expiry,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  quantity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              expiry,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
