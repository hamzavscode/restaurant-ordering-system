import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

/// Manages the shopping cart state.
/// Handles adding, removing, updating quantity, and computing totals.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// All items currently in the cart.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Total number of individual items in the cart (sum of quantities).
  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// Number of unique menu items in the cart.
  int get uniqueItemCount => _items.length;

  /// Subtotal price of all items.
  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Tax amount (15%).
  double get tax => subtotal * 0.15;

  /// Service fee for in-restaurant ordering.
  double get serviceFee => subtotal > 0 ? 5 : 0;

  /// Total price including tax and service fee.
  double get totalPrice => subtotal + tax + serviceFee;

  /// Whether the cart is empty.
  bool get isEmpty => _items.isEmpty;

  /// Adds a menu item to the cart. If it already exists, increases quantity.
  void addItem(MenuItem menuItem, [int quantity = 1]) {
    final existingIndex = _items.indexWhere(
      (cartItem) => cartItem.itemId == menuItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(menuItem: menuItem, quantity: quantity));
    }
    notifyListeners();
  }

  /// Removes an item from the cart entirely.
  void removeItem(int menuItemId) {
    _items.removeWhere((item) => item.itemId == menuItemId);
    notifyListeners();
  }

  /// Increases the quantity of a specific item.
  void increaseQuantity(int menuItemId) {
    final item = _items.firstWhere(
      (item) => item.itemId == menuItemId,
      orElse: () => throw Exception('Item not found'),
    );
    item.quantity++;
    notifyListeners();
  }

  /// Decreases the quantity of a specific item.
  /// Removes the item if quantity reaches 0.
  void decreaseQuantity(int menuItemId) {
    final index = _items.indexWhere((item) => item.itemId == menuItemId);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  /// Returns a list of all menu item IDs in the cart (with duplicates for quantity).
  /// Used when creating an order via the API.
  List<int> get allItemIds {
    final ids = <int>[];
    for (final item in _items) {
      for (int i = 0; i < item.quantity; i++) {
        ids.add(item.itemId);
      }
    }
    return ids;
  }

  /// Clears the entire cart.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
