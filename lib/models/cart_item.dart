import 'coffee.dart';

class CartItem {
  final Coffee coffee;
  int quantity;

  CartItem({
    required this.coffee,
    this.quantity = 1,
  });

  double get totalPrice => coffee.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'coffee': coffee.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      coffee: Coffee.fromJson(json['coffee']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
