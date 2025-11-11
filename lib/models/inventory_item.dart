import 'grocery_item.dart';

/// Represents an item in the user's pantry/inventory
class InventoryItem {
  final String id;
  final String name;
  final String category;
  double quantity;
  final String unit;
  final DateTime addedDate;
  DateTime? expiryDate;
  final String? imageUrl; // Optional: for custom items
  bool isExpiringSoon; // Auto-calculated: within 3 days

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.unit = 'pcs',
    required this.addedDate,
    this.expiryDate,
    this.imageUrl,
  }) : isExpiringSoon = _calculateExpiringSoon(expiryDate);

  /// Calculate if item expires within 3 days
  static bool _calculateExpiringSoon(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }

  /// Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Days until expiry (negative if expired)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Create from GroceryItem (after receipt scan confirmation)
  factory InventoryItem.fromGroceryItem(GroceryItem item) {
    return InventoryItem(
      id: item.id,
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      addedDate: DateTime.now(),
      expiryDate: item.estimatedExpiryDate,
    );
  }

  /// Create from JSON (for local storage)
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'] ?? 'pcs',
      addedDate: DateTime.parse(json['added_date']),
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      imageUrl: json['image_url'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'added_date': addedDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  /// Update quantity (e.g., when user consumes item)
  InventoryItem updateQuantity(double newQuantity) {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      quantity: newQuantity,
      unit: unit,
      addedDate: addedDate,
      expiryDate: expiryDate,
      imageUrl: imageUrl,
    );
  }
}
