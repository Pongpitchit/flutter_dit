import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/coffee.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static CartService? _instance;
  static CartService get instance => _instance ??= CartService._();
  CartService._();

  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final List<dynamic> cartData = json.decode(cartJson);
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _items = [];
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartKey, json.encode(cartData));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  Future<void> addToCart(Coffee coffee, {int quantity = 1}) async {
    try {
      final existingIndex = _items.indexWhere((item) => item.coffee.id == coffee.id);
      
      if (existingIndex != -1) {
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(coffee: coffee, quantity: quantity));
      }
      
      await saveCart();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(int coffeeId, int quantity) async {
    try {
      final index = _items.indexWhere((item) => item.coffee.id == coffeeId);
      
      if (index != -1) {
        if (quantity <= 0) {
          _items.removeAt(index);
        } else {
          _items[index].quantity = quantity;
        }
        await saveCart();
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(int coffeeId) async {
    try {
      _items.removeWhere((item) => item.coffee.id == coffeeId);
      await saveCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      _items.clear();
      await saveCart();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
