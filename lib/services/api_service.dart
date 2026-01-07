import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/grocery_item.dart';
import 'llm_service.dart';

/// Service for handling API calls to backend (OCR, barcode lookup, etc.)
/// Uses mock data for now as Receipt Scanning is not yet migrated to open source
class ApiService {
  // Simulate network delay for mock mode
  static const Duration _mockDelay = Duration(seconds: 2);
  
  ApiService();

  /// Send receipt image to backend for OCR processing
  /// Returns a list of parsed grocery items
  Future<List<GroceryItem>> processReceiptImage(dynamic imageFile) async {
    // Check if running on web platform
    if (kIsWeb) {
      print('⚠️ Running on web platform - AI scanning not supported');
      print('📱 For AI-powered receipt scanning, please use:');
      print('   • Android: flutter run (with device/emulator)');
      print('   • iOS: flutter run (with device/simulator)');
      print('   • Desktop: flutter run -d windows/macos/linux');
      print('Using demo data for web preview...');
      
      // Return mock data for web platform
      await Future.delayed(_mockDelay);
      return _getMockReceiptItems();
    }
    
    // AI Receipt Scanning is currently disabled pending migration
    // Real AI receipt scanning for mobile/desktop.
    try {
      Uint8List bytes;
      if (imageFile is File) {
        bytes = await imageFile.readAsBytes();
      } else if (imageFile is XFile) {
        bytes = await imageFile.readAsBytes();
      } else {
        throw Exception('Unsupported image type: ${imageFile.runtimeType}');
      }

      if (!LLMService.instance.isConfigured) {
        throw Exception('AI not configured. Set API key and a vision model in Profile → AI Model Settings.');
      }

      final items = await LLMService.instance.parseReceiptImageToItems(bytes);
      if (items.isEmpty) {
        throw Exception('No items found on the receipt. Try retaking a clearer photo.');
      }
      return items;
    } catch (e) {
      // If anything goes wrong, surface a clear error (caller will show snackbar).
      throw Exception('AI receipt scanning failed: $e');
    }

  }

  /// Look up product by barcode
  Future<GroceryItem?> lookupBarcode(String barcode) async {
    await Future.delayed(_mockDelay);

    // Mock barcode lookup
    return GroceryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Organic Whole Milk',
      category: 'Dairy',
      quantity: 1.0,
      unit: 'L',
      price: 4.99,
      estimatedExpiryDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  /// Mock data: simulated receipt parsing result
  List<GroceryItem> _getMockReceiptItems() {
    final now = DateTime.now();
    return [
      GroceryItem(
        id: '1',
        name: 'Organic Whole Milk',
        category: 'Dairy',
        quantity: 1.0,
        unit: 'L',
        price: 4.99,
        estimatedExpiryDate: now.add(const Duration(days: 7)),
      ),
      GroceryItem(
        id: '2',
        name: 'Whole Wheat Bread',
        category: 'Bakery',
        quantity: 1.0,
        unit: 'loaf',
        price: 3.49,
        estimatedExpiryDate: now.add(const Duration(days: 5)),
      ),
      GroceryItem(
        id: '3',
        name: 'Avocados',
        category: 'Produce',
        quantity: 4.0,
        unit: 'pcs',
        price: 5.96,
        estimatedExpiryDate: now.add(const Duration(days: 4)),
      ),
      GroceryItem(
        id: '4',
        name: 'Chicken Breast',
        category: 'Meat',
        quantity: 1.2,
        unit: 'kg',
        price: 12.50,
        estimatedExpiryDate: now.add(const Duration(days: 3)),
      ),
      GroceryItem(
        id: '5',
        name: 'Greek Yogurt',
        category: 'Dairy',
        quantity: 6.0,
        unit: 'pcs',
        price: 8.94,
        estimatedExpiryDate: now.add(const Duration(days: 14)),
      ),
      GroceryItem(
        id: '6',
        name: 'Baby Spinach',
        category: 'Produce',
        quantity: 1.0,
        unit: 'bag',
        price: 3.99,
        estimatedExpiryDate: now.add(const Duration(days: 6)),
      ),
      GroceryItem(
        id: '7',
        name: 'Eggs',
        category: 'Dairy',
        quantity: 12.0,
        unit: 'pcs',
        price: 4.49,
        estimatedExpiryDate: now.add(const Duration(days: 21)),
      ),
      GroceryItem(
        id: '8',
        name: 'Pasta',
        category: 'Pantry Staples',
        quantity: 1.0,
        unit: 'box',
        price: 2.99,
        estimatedExpiryDate: now.add(const Duration(days: 365)),
      ),
    ];
  }
}
