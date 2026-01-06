class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  bool isBought;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isBought = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? '1',
      isBought: json['is_bought'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'is_bought': isBought,
    };
  }

  ShoppingItem toggle() {
    return ShoppingItem(
      id: id,
      name: name,
      quantity: quantity,
      isBought: !isBought,
    );
  }
}
