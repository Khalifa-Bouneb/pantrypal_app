import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart';
import '../models/shopping_item.dart';

class PantryService {
  static final PantryService instance = PantryService._init();
  static const String _storageKey = 'pantry_items';
  static const String _shoppingKey = 'shopping_list';

  PantryService._init();

  final ValueNotifier<List<InventoryItem>> itemsNotifier = ValueNotifier([]);
  final ValueNotifier<List<ShoppingItem>> shoppingListNotifier = ValueNotifier(
    [],
  );

  List<InventoryItem> get items => itemsNotifier.value;
  List<ShoppingItem> get shoppingList => shoppingListNotifier.value;

  Future<void> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Pantry
      final String? itemsJson = prefs.getString(_storageKey);
      if (itemsJson != null) {
        final List<dynamic> decodedList = jsonDecode(itemsJson);
        final List<InventoryItem> loadedItems = decodedList
            .map((item) => InventoryItem.fromJson(item))
            .toList();
        itemsNotifier.value = loadedItems;
      }

      // Load Shopping List
      final String? shoppingJson = prefs.getString(_shoppingKey);
      if (shoppingJson != null) {
        final List<dynamic> decodedList = jsonDecode(shoppingJson);
        final List<ShoppingItem> loadedShopping = decodedList
            .map((item) => ShoppingItem.fromJson(item))
            .toList();
        shoppingListNotifier.value = loadedShopping;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = jsonEncode(
        itemsNotifier.value.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('Error saving pantry items: $e');
    }
  }

  Future<void> saveShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = jsonEncode(
        shoppingListNotifier.value.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_shoppingKey, encodedList);
    } catch (e) {
      debugPrint('Error saving shopping list: $e');
    }
  }

  // --- Pantry Methods ---

  Future<void> addItems(List<InventoryItem> newItems) async {
    final currentItems = List<InventoryItem>.from(itemsNotifier.value);
    currentItems.addAll(newItems);
    itemsNotifier.value = currentItems;
    await saveItems();
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    final currentItems = List<InventoryItem>.from(itemsNotifier.value);
    final index = currentItems.indexWhere((item) => item.id == updatedItem.id);

    if (index != -1) {
      currentItems[index] = updatedItem;
      itemsNotifier.value = currentItems;
      await saveItems();
    }
  }

  Future<void> removeItem(String id) async {
    final currentItems = List<InventoryItem>.from(itemsNotifier.value);
    currentItems.removeWhere((item) => item.id == id);
    itemsNotifier.value = currentItems;
    await saveItems();
  }

  // --- Shopping List Methods ---

  Future<void> addToShoppingList(ShoppingItem item) async {
    final currentList = List<ShoppingItem>.from(shoppingListNotifier.value);
    currentList.add(item);
    shoppingListNotifier.value = currentList;
    await saveShoppingList();
  }

  Future<void> addMultipleToShoppingList(List<ShoppingItem> items) async {
    final currentList = List<ShoppingItem>.from(shoppingListNotifier.value);
    currentList.addAll(items);
    shoppingListNotifier.value = currentList;
    await saveShoppingList();
  }

  Future<void> toggleShoppingItem(String id) async {
    final currentList = List<ShoppingItem>.from(shoppingListNotifier.value);
    final index = currentList.indexWhere((item) => item.id == id);
    if (index != -1) {
      currentList[index] = currentList[index].toggle();
      shoppingListNotifier.value = currentList;
      await saveShoppingList();
    }
  }

  Future<void> removeShoppingItem(String id) async {
    final currentList = List<ShoppingItem>.from(shoppingListNotifier.value);
    currentList.removeWhere((item) => item.id == id);
    shoppingListNotifier.value = currentList;
    await saveShoppingList();
  }

  Future<void> moveBoughtItemsToPantry() async {
    final currentShoppingList = List<ShoppingItem>.from(
      shoppingListNotifier.value,
    );
    final boughtItems = currentShoppingList.where((i) => i.isBought).toList();

    if (boughtItems.isEmpty) return;

    // Convert to Inventory Items
    final newInventoryItems = boughtItems.map((sItem) {
      // Try to parse quantity, default to 1.0
      double qty =
          double.tryParse(sItem.quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          1.0;

      return InventoryItem(
        id: sItem.id, // Reuse ID or generic match
        name: sItem.name,
        category: 'Pantry Staples', // Default category
        quantity: qty,
        unit: 'pcs',
        addedDate: DateTime.now(),
        // No default expiry for shopping list items
      );
    }).toList();

    // Add to Pantry
    await addItems(newInventoryItems);

    // Remove from Shopping List
    final remainingList = currentShoppingList
        .where((i) => !i.isBought)
        .toList();
    shoppingListNotifier.value = remainingList;
    await saveShoppingList();
  }
}
