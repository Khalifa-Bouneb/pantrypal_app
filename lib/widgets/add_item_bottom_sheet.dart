import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../screens/receipt_scanner_screen.dart';
import '../screens/barcode_scanner_screen.dart';
import '../screens/manual_add_screen.dart';

/// Bottom sheet that shows 3 options for adding items:
/// 1. Scan Receipt (AI-powered)
/// 2. Scan Barcode (Quick single item)
/// 3. Add Manually (Fallback)
class AddItemBottomSheet extends StatelessWidget {
  final Function(List<InventoryItem>) onItemsAdded;

  const AddItemBottomSheet({
    super.key,
    required this.onItemsAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            
            Text(
              'Add Items to Pantry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Scan Receipt (The AI "wow" feature)
            _buildOptionTile(
              context: context,
              icon: Icons.receipt_long,
              title: 'Scan Receipt',
              subtitle: 'AI-powered magic ✨',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScannerScreen(
                      onItemsAdded: onItemsAdded,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Scan Barcode
            _buildOptionTile(
              context: context,
              icon: Icons.qr_code_scanner,
              title: 'Scan Barcode',
              subtitle: 'Quick single item entry',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarcodeScannerScreen(
                      onItemsAdded: onItemsAdded,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Option 3: Add Manually
            _buildOptionTile(
              context: context,
              icon: Icons.edit,
              title: 'Add Manually',
              subtitle: 'Type it in yourself',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualAddScreen(
                      onItemsAdded: onItemsAdded,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
