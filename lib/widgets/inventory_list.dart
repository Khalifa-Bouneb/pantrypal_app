import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

/// Widget that displays the list of inventory items
class InventoryList extends StatelessWidget {
  final List<InventoryItem> items;
  final Function(String) onRemoveItem;
  final Function(String, double) onUpdateQuantity;

  const InventoryList({
    super.key,
    required this.items,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    // Group items by expiry status
    final expiringSoon = items.where((item) => item.isExpiringSoon).toList();
    final expired = items.where((item) => item.isExpired).toList();
    final fresh = items.where((item) => !item.isExpiringSoon && !item.isExpired).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (expired.isNotEmpty) ...[
          _buildSectionHeader('Expired', Colors.red, expired.length),
          ...expired.map((item) => _buildInventoryCard(context, item, Colors.red)),
          const SizedBox(height: 16),
        ],
        if (expiringSoon.isNotEmpty) ...[
          _buildSectionHeader('Expiring Soon', Colors.orange, expiringSoon.length),
          ...expiringSoon.map((item) => _buildInventoryCard(context, item, Colors.orange)),
          const SizedBox(height: 16),
        ],
        if (fresh.isNotEmpty) ...[
          _buildSectionHeader('Fresh', Colors.green, fresh.length),
          ...fresh.map((item) => _buildInventoryCard(context, item, Colors.green)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getColorShade(color, 700),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getColorShade(color, 100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColorShade(color, 700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItem item, Color statusColor) {
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
                color: _getColorShade(statusColor, 400),
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
                            color: _getColorShade(statusColor, 700),
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
                    onUpdateQuantity(item.id, item.quantity - 1);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green[600],
                  onPressed: () {
                    onUpdateQuantity(item.id, item.quantity + 1);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  onPressed: () {
                    onRemoveItem(item.id);
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

  /// Helper to get color shades (replacing MaterialColor indexing)
  Color _getColorShade(Color baseColor, int shade) {
    if (baseColor == Colors.red) {
      return shade == 700 ? Colors.red.shade700 : Colors.red.shade100;
    } else if (baseColor == Colors.orange) {
      return shade == 700 ? Colors.orange.shade700 : shade == 100 ? Colors.orange.shade100 : Colors.orange.shade400;
    } else if (baseColor == Colors.green) {
      return shade == 700 ? Colors.green.shade700 : shade == 100 ? Colors.green.shade100 : Colors.green.shade400;
    }
    return baseColor;
  }
}
