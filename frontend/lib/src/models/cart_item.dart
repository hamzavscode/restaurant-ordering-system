import 'menu_item.dart';

/// Represents an item in the cart with its quantity.
/// Wraps a [MenuItem] and adds quantity tracking.
class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  /// Total price for this cart item (unit price × quantity).
  double get totalPrice => menuItem.prix * quantity;

  /// Convenience getters for display.
  String get nom => menuItem.nom;
  double get unitPrice => menuItem.prix;
  String get imageUrl => menuItem.displayImageUrl;
  int get itemId => menuItem.id;
}
