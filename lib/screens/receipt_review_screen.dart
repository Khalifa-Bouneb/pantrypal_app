import 'dart:io';
import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../models/inventory_item.dart';

/// Screen to review and confirm items parsed from receipt
class ReceiptReviewScreen extends StatefulWidget {
  final List<GroceryItem> parsedItems;
  final File receiptImage;
  final Function(List<InventoryItem>) onItemsAdded;

  const ReceiptReviewScreen({
    super.key,
    required this.parsedItems,
    required this.receiptImage,
    required this.onItemsAdded,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late List<GroceryItem> _editableItems;

  @override
  void initState() {
    super.initState();
    _editableItems = List.from(widget.parsedItems);
  }

  /// Remove an item from the list
  void _removeItem(int index) {
    setState(() {
      _editableItems.removeAt(index);
    });
  }

  /// Confirm and add all items to inventory
  void _confirmItems() {
    final inventoryItems = _editableItems
        .map((item) => InventoryItem.fromGroceryItem(item))
        .toList();
    
    widget.onItemsAdded(inventoryItems);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${inventoryItems.length} items to your pantry!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Go back to home (pop twice: review -> scanner -> home)
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern gradient AppBar
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Review Items',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 60),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Found ${_editableItems.length} items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // List of parsed items
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _editableItems.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No items to add',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItemCard(_editableItems[index], index),
                      childCount: _editableItems.length,
                    ),
                  ),
          ),
          
          // Bottom spacing for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // Confirm button as FAB
      floatingActionButton: _editableItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _confirmItems,
              backgroundColor: Colors.green[700],
              elevation: 6,
              icon: const Icon(Icons.check_rounded, size: 28),
              label: Text(
                'Add ${_editableItems.length} Items',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildItemCard(GroceryItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item icon based on category
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: _getCategoryColor(item.category),
                size: 28,
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
                    '${item.category} • ${item.quantity} ${item.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (item.estimatedExpiryDate != null)
                    Text(
                      'Expires: ${_formatDate(item.estimatedExpiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.red[400],
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return Colors.blue;
      case 'produce':
        return Colors.green;
      case 'meat':
        return Colors.red;
      case 'bakery':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return Icons.local_drink;
      case 'produce':
        return Icons.eco;
      case 'meat':
        return Icons.restaurant;
      case 'bakery':
        return Icons.bakery_dining;
      default:
        return Icons.shopping_bag;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'in $difference days';
    
    return '${date.month}/${date.day}/${date.year}';
  }
}
