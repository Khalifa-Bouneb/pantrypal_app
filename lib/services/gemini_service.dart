import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/grocery_item.dart';

/// Service for using Google Gemini AI to parse receipt images
class GeminiService {
  
  static const String _apiKey = 'ADD_YOUR_GEMINI_API_KEY_HERE'; 
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Process receipt image and extract grocery items using Gemini AI
  Future<List<GroceryItem>> processReceiptImage(dynamic imageFile) async {
    try {
      // Check if running on web
      if (kIsWeb) {
        throw UnsupportedError(
          'Gemini AI receipt scanning is not supported on web. '
          'Please use an Android, iOS, or desktop app for AI-powered scanning.'
        );
      }
      
      // Read image as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Create the prompt for Gemini
      final prompt = '''
Analyze this grocery receipt image and extract ALL items purchased. For each item, provide:
1. Item name (standardized, e.g., "Organic Whole Milk" not "ORG MLK")
2. Quantity (as a number)
3. Unit (pcs, kg, L, box, bag, etc.)
4. Category (Produce, Dairy, Meat, Bakery, Pantry Staples, Frozen, Beverages, Snacks, Other)
5. Price (if visible)
6. Estimated shelf life in days (realistic estimate based on typical food storage)

Return ONLY a valid JSON array with this exact structure, nothing else:
[
  {
    "name": "Organic Whole Milk",
    "quantity": 1.0,
    "unit": "L",
    "category": "Dairy",
    "price": 4.99,
    "shelf_life_days": 7
  }
]

Important rules:
- Be precise with item names
- If quantity is not clear, use 1.0
- Always include a category
- Estimate realistic shelf life (milk: 7 days, bread: 5 days, eggs: 21 days, etc.)
- Ignore store name, taxes, totals, etc.
- Only return the JSON array, no other text
''';

      // Send request to Gemini with image
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse the JSON response
      return _parseGeminiResponse(responseText);
    } catch (e) {
      print('Error processing receipt with Gemini: $e');
      rethrow;
    }
  }

  /// Parse Gemini's JSON response into GroceryItem objects
  List<GroceryItem> _parseGeminiResponse(String responseText) {
    try {
      // Clean the response (remove markdown code blocks if present)
      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parse JSON
      final List<dynamic> jsonList = jsonDecode(cleanedText);
      final now = DateTime.now();

      return jsonList.map((json) {
        final shelfLifeDays = json['shelf_life_days'] ?? 7;
        return GroceryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + json['name'].toString().hashCode.toString(),
          name: json['name'] ?? 'Unknown Item',
          category: json['category'] ?? 'Other',
          quantity: (json['quantity'] ?? 1.0).toDouble(),
          unit: json['unit'] ?? 'pcs',
          price: json['price']?.toDouble(),
          estimatedExpiryDate: now.add(Duration(days: shelfLifeDays)),
        );
      }).toList();
    } catch (e) {
      print('Error parsing Gemini response: $e');
      print('Response text: $responseText');
      throw Exception('Failed to parse receipt data. Please try again.');
    }
  }

  /// Check if API key is configured
  static bool isConfigured() {
    return _apiKey != 'YOUR_GEMINI_API_KEY_HERE' && _apiKey.isNotEmpty;
  }
}
