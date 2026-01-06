import 'package:flutter/material.dart';
import 'home_screen.dart' show AppTheme;
import '../services/pantry_service.dart';
import '../models/shopping_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _addItemController = TextEditingController();

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add to Shopping List'),
        content: TextField(
          controller: _addItemController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Milk, Bread',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (_addItemController.text.trim().isNotEmpty) {
                final newItem = ShoppingItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _addItemController.text.trim(),
                  quantity: '1',
                );
                PantryService.instance.addToShoppingList(newItem);
                _addItemController.clear();
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewItem,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white)),
      ),
      body: ValueListenableBuilder<List<ShoppingItem>>(
        valueListenable: PantryService.instance.shoppingListNotifier,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your list is empty',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }

          final boughtItems = items.where((i) => i.isBought).toList();
          final activeItems = items.where((i) => !i.isBought).toList();

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (activeItems.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Text(
                            'To Buy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildShoppingItem(activeItems[index]),
                          childCount: activeItems.length,
                        ),
                      ),
                    ],
                    if (boughtItems.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildShoppingItem(boughtItems[index]),
                          childCount: boughtItems.length,
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ), // Space for FAB
                  ],
                ),
              ),
              if (boughtItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await PantryService.instance
                              .moveBoughtItemsToPantry();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Moved items to Pantry!'),
                                backgroundColor: AppTheme.primary,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('Done Shopping (${boughtItems.length})'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        PantryService.instance.removeShoppingItem(item.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        child: ListTile(
          onTap: () => PantryService.instance.toggleShoppingItem(item.id),
          leading: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: item.isBought ? AppTheme.primary : Colors.grey.shade400,
                width: 2,
              ),
              color: item.isBought ? AppTheme.primary : Colors.transparent,
            ),
            child: item.isBought
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : const SizedBox(width: 14, height: 14),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              decoration: item.isBought ? TextDecoration.lineThrough : null,
              color: item.isBought ? AppTheme.textLight : AppTheme.textDark,
              fontWeight: item.isBought ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: () => PantryService.instance.removeShoppingItem(item.id),
          ),
        ),
      ),
    );
  }
}
