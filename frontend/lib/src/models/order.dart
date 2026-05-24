import 'menu_item.dart';

/// Represents an order from the backend (Commande entity).
/// Contains the order's status, date, and associated menu items.
class Order {
  final int id;
  final DateTime date;
  final String status; // PENDING, CONFIRMED, CANCELLED
  final List<MenuItem> elements;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.elements,
  });

  /// Creates an Order from JSON returned by the API.
  factory Order.fromJson(Map<String, dynamic> json) {
    final elementsList = (json['elements'] as List<dynamic>?)
            ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      if (json['date'] is String) {
        parsedDate = DateTime.tryParse(json['date']) ?? DateTime.now();
      } else if (json['date'] is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(json['date']);
      }
    }

    return Order(
      id: json['id'] ?? 0,
      date: parsedDate,
      status: json['status'] ?? 'PENDING',
      elements: elementsList,
    );
  }

  /// Total price of all elements in this order.
  double get totalPrice =>
      elements.fold(0.0, (sum, item) => sum + item.prix);

  /// Number of items in this order.
  int get itemCount => elements.length;

  /// Whether this order can be cancelled (only if PENDING).
  bool get canCancel => status == 'PENDING';

  /// Returns a formatted date string.
  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }
}
