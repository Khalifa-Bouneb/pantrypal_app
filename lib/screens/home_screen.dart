import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../widgets/add_item_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // In-memory inventory (in real app, use a state management solution or local DB)
  List<InventoryItem> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadMockInventory();
  }

  /// Load some mock inventory items for demo
  void _loadMockInventory() {
    final now = DateTime.now();
    setState(() {
      _inventory = [
        InventoryItem(
          id: 'demo1',
          name: 'Milk',
          category: 'Dairy',
          quantity: 2.0,
          unit: 'L',
          addedDate: now.subtract(const Duration(days: 2)),
          expiryDate: now.add(const Duration(days: 2)),
        ),
        InventoryItem(
          id: 'demo2',
          name: 'Apples',
          category: 'Produce',
          quantity: 6.0,
          unit: 'pcs',
          addedDate: now.subtract(const Duration(days: 1)),
          expiryDate: now.add(const Duration(days: 7)),
        ),
      ];
    });
  }

  /// Show the add item bottom sheet with 3 options
  void _showAddItemOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddItemBottomSheet(
        onItemsAdded: _addItemsToInventory,
      ),
    );
  }

  /// Add items to inventory (called after receipt confirmation, barcode scan, or manual add)
  void _addItemsToInventory(List<InventoryItem> newItems) {
    setState(() {
      _inventory.addAll(newItems);
    });
  }

  /// Remove item from inventory
  void _removeItem(String itemId) {
    setState(() {
      _inventory.removeWhere((item) => item.id == itemId);
    });
  }

  /// Update item quantity
  void _updateItemQuantity(String itemId, double newQuantity) {
    setState(() {
      final index = _inventory.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        if (newQuantity <= 0) {
          _inventory.removeAt(index);
        } else {
          _inventory[index] = _inventory[index].updateQuantity(newQuantity);
        }
      }
    });
  }

  /// Build inventory content with grouping
  List<Widget> _buildInventoryContent() {
    // Group items by expiry status
    final expiringSoon = _inventory.where((item) => item.isExpiringSoon).toList();
    final expired = _inventory.where((item) => item.isExpired).toList();
    final fresh = _inventory.where((item) => !item.isExpiringSoon && !item.isExpired).toList();

    List<Widget> widgets = [];

    if (expired.isNotEmpty) {
      widgets.add(_buildSectionHeader('Expired', Colors.red, expired.length));
      widgets.addAll(expired.map((item) => _buildInventoryCard(item, Colors.red)));
      widgets.add(const SizedBox(height: 16));
    }

    if (expiringSoon.isNotEmpty) {
      widgets.add(_buildSectionHeader('Expiring Soon', Colors.orange, expiringSoon.length));
      widgets.addAll(expiringSoon.map((item) => _buildInventoryCard(item, Colors.orange)));
      widgets.add(const SizedBox(height: 16));
    }

    if (fresh.isNotEmpty) {
      widgets.add(_buildSectionHeader('Fresh', Colors.green, fresh.length));
      widgets.addAll(fresh.map((item) => _buildInventoryCard(item, Colors.green)));
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title, MaterialColor color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item, MaterialColor statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: statusColor[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.expiryDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${_formatExpiryDate(item)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Quantity controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.grey[600],
                  onPressed: () {
                    _updateItemQuantity(item.id, item.quantity - 1);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green[600],
                  onPressed: () {
                    _updateItemQuantity(item.id, item.quantity + 1);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  onPressed: () {
                    _removeItem(item.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiryDate(InventoryItem item) {
    final days = item.daysUntilExpiry;
    if (days == null) return 'No expiry';
    if (days < 0) return 'Expired ${-days} days ago';
    if (days == 0) return 'Expires today!';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern gradient AppBar with hero effect
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.kitchen,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PantryPal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green[700]!,
                      Colors.green[500]!,
                      Colors.lightGreen[400]!,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expiry notifications will be added in a future update')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings panel will be added in a future update')),
                  );
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: _inventory.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _buildInventoryContent(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        elevation: 6,
        onPressed: _showAddItemOptions,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text(
          'Add Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Show friendly empty state when no items in inventory
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen,
            size: 100,
            color: Colors.green[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Your pantry is empty!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the + button to add your first items',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}
