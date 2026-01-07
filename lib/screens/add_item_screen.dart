import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'manual_add_screen.dart';
import 'barcode_scanner_screen.dart';
import 'receipt_scanner_screen.dart';
import 'home_screen.dart' show AppTheme;
import '../l10n/app_localizations.dart';
import '../services/pantry_service.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  Future<void> _handleItemsAdded(
    BuildContext context,
    List<InventoryItem> items,
  ) async {
    final t = AppLocalizations.of(context);
    // Save items to persistent storage
    await PantryService.instance.addItems(items);

    if (!context.mounted) return;

    // Show feedback once, then return to Home (pop child + pop AddItemScreen).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t
              .tr('added_items_to_pantry')
              .replaceAll('{count}', '${items.length}')
              .replaceAll('{plural}', items.length == 1 ? '' : 's'),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          t.tr('add_items_title'),
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.tr('how_add_items'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.tr('choose_method'),
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildOptionCard(
                context,
                title: t.tr('scan_receipt'),
                subtitle: t.tr('ai_powered_inventory'),
                icon: Icons.receipt_long_rounded,
                color: AppTheme.primary,
                suffixTag: t.tr('ai_powered_tag'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptScannerScreen(
                        onItemsAdded: (items) async {
                          await PantryService.instance.addItems(items);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context,
                title: t.tr('scan_barcode'),
                subtitle: t.tr('quick_product_id'),
                icon: Icons.qr_code_scanner_rounded,
                color: Colors.blue, // Keep differentiated colors for visual aid
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarcodeScannerScreen(
                        onItemsAdded: (items) =>
                            _handleItemsAdded(context, items),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context,
                title: t.tr('add_manually'),
                subtitle: t.tr('type_one_by_one'),
                icon: Icons.edit_note_rounded,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManualAddScreen(
                        onItemsAdded: (items) =>
                            _handleItemsAdded(context, items),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.amber[800],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.tr('pro_tip'),
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? suffixTag,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (suffixTag != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                suffixTag,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ],
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
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade300,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
