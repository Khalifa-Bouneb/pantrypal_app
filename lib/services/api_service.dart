import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/grocery_item.dart';
import 'gemini_service.dart';

/// Service for handling API calls to backend (OCR, barcode lookup, etc.)
/// Uses Gemini AI when configured, otherwise falls back to mock data
class ApiService {
  // Simulate network delay for mock mode
  static const Duration _mockDelay = Duration(seconds: 2);
  
  final GeminiService? _geminiService;

  ApiService() : _geminiService = GeminiService.isConfigured() ? GeminiService() : null;

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
    
    // Try Gemini AI first if configured
    if (_geminiService != null) {
      try {
        print('🤖 Using Gemini AI for receipt processing...');
        final items = await _geminiService.processReceiptImage(imageFile);
        print('✅ Gemini AI successfully extracted ${items.length} items');
        return items;
      } catch (e, stackTrace) {
        print('❌ Gemini AI failed with error: $e');
        print('Stack trace: $stackTrace');
        
        // If it's a platform error, show helpful message
        if (e is UnsupportedError) {
          print('💡 Tip: Run on mobile or desktop for AI features');
          await Future.delayed(_mockDelay);
          return _getMockReceiptItems();
        }
        
        rethrow; // Don't fall back to mock data for other errors
      }
    } else {
      print('⚠️ Gemini AI not configured. Using mock data.');
      print('To enable AI-powered receipt scanning:');
      print('1. Get a free API key from https://makersuite.google.com/app/apikey');
      print('2. Add it to lib/services/gemini_service.dart');
      
      // Fallback: Simulate API call delay and return mock data
      await Future.delayed(_mockDelay);
      return _getMockReceiptItems();
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
