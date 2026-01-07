import 'package:flutter/material.dart';
import 'home_screen.dart' show AppTheme;
import '../services/pantry_service.dart';
import '../models/inventory_item.dart';
import '../l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          t.tr('my_pantry'),
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
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
          tabs: [
            Tab(text: t.tr('all_items')),
            Tab(text: t.tr('vegetables')),
            Tab(text: t.tr('fruits')),
            Tab(text: t.tr('protein')),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<InventoryItem>>(
        valueListenable: PantryService.instance.itemsNotifier,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.kitchen_rounded,
                    size: 64,
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.tr('pantry_empty'),
                    style: TextStyle(color: AppTheme.textLight, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPantryList(items),
              // Simple filtering for now - exact string match is brittle, ideally use enums
              _buildPantryList(
                items
                    .where(
                      (i) =>
                          i.category == 'Vegetables' || i.category == 'Produce',
                    )
                    .toList(),
              ),
              _buildPantryList(
                items.where((i) => i.category == 'Fruits').toList(),
              ),
              _buildPantryList(
                items
                    .where(
                      (i) => i.category == 'Meat' || i.category == 'Protein',
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPantryList(List<InventoryItem> items) {
    if (items.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).tr('no_items_category')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildPantryItem(item);
      },
    );
  }

  Widget _buildPantryItem(InventoryItem item) {
    final t = AppLocalizations.of(context);
    Color itemColor = Colors.green;
    IconData itemIcon = Icons.circle;

    // Simple visual mapping
    if (item.category.contains('Meat')) {
      itemColor = Colors.red;
      itemIcon = Icons.restaurant;
    } else if (item.category.contains('Dairy')) {
      itemColor = Colors.blue;
      itemIcon = Icons.local_drink;
    } else if (item.category.contains('Produce') ||
        item.category.contains('Vegetables')) {
      itemColor = Colors.green;
      itemIcon = Icons.grass;
    } else if (item.category.contains('Fruit')) {
      itemColor = Colors.orange;
      itemIcon = Icons.apple;
    }

    // Check expiry
    bool isExpired = item.isExpired;
    bool isExpiringSoon =
        item.daysUntilExpiry != null &&
        item.daysUntilExpiry! <= 3 &&
        !isExpired;
    String expiryText = '';

    if (item.expiryDate != null) {
      if (isExpired) {
        expiryText = t.tr('expired');
      } else {
        final days = item.daysUntilExpiry;
        expiryText = days == 0
            ? t.tr('expires_today')
            : t.tr('expires_in_days').replaceAll('{days}', '${days ?? ''}');
      }
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        PantryService.instance.removeItem(item.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('${item.name} ${t.tr('removed')}')),
        );
      },
      child: Container(
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
                color: itemColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(itemIcon, color: itemColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (item.expiryDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.red.withOpacity(0.1)
                      : (isExpiringSoon
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expiryText,
                  style: TextStyle(
                    fontSize: 10,
                    color: isExpired
                        ? Colors.red
                        : (isExpiringSoon ? Colors.orange : Colors.green),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
