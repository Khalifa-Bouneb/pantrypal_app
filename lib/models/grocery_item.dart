/// Represents a grocery item parsed from a receipt
class GroceryItem {
  final String id;
  String name;
  String category;
  double quantity;
  String unit; // e.g., "pcs", "kg", "L"
  double? price;
  DateTime? estimatedExpiryDate;
  bool isVerified; // User confirmed the item is correct

  GroceryItem({
    required this.id,
    required this.name,
    this.category = 'Uncategorized',
    this.quantity = 1.0,
    this.unit = 'pcs',
    this.price,
    this.estimatedExpiryDate,
    this.isVerified = false,
  });

  /// Create from JSON (from backend API response)
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unknown Item',
      category: json['category'] ?? 'Uncategorized',
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      price: json['price']?.toDouble(),
      estimatedExpiryDate: json['estimated_expiry_date'] != null
          ? DateTime.parse(json['estimated_expiry_date'])
          : null,
      isVerified: json['is_verified'] ?? false,
    );
  }

  /// Convert to JSON (for sending to backend or local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'estimated_expiry_date': estimatedExpiryDate?.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  /// Create a copy with modified fields
  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? price,
    DateTime? estimatedExpiryDate,
    bool? isVerified,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      estimatedExpiryDate: estimatedExpiryDate ?? this.estimatedExpiryDate,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
