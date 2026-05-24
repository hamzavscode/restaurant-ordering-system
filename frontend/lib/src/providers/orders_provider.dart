import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

/// Manages the orders state.
/// Fetches, caches, and updates order data from the API.
class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  /// All orders for the current user.
  List<Order> get orders => List.unmodifiable(_orders);

  /// Whether orders are currently being loaded.
  bool get isLoading => _isLoading;

  /// Error message if the last operation failed.
  String? get error => _error;

  /// Whether we have any orders.
  bool get hasOrders => _orders.isNotEmpty;

  /// Fetches all orders for a given client from the API.
  Future<void> fetchOrders(int clientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ordersJson = await ApiService.getOrdersByClient(clientId);
      _orders = ordersJson.map((json) => Order.fromJson(json)).toList();
      // Sort by date descending (newest first)
      _orders.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new order and adds it to the local list.
  Future<Order> createOrder(int clientId, List<int> elementIds) async {
    final json = await ApiService.createOrder(clientId, elementIds);
    final newOrder = Order.fromJson(json);
    _orders.insert(0, newOrder);
    notifyListeners();
    return newOrder;
  }

  /// Cancels an order by updating its status to CANCELLED.
  Future<void> cancelOrder(int orderId) async {
    await ApiService.cancelOrder(orderId);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final old = _orders[index];
      _orders[index] = Order(
        id: old.id,
        date: old.date,
        status: 'CANCELLED',
        elements: old.elements,
      );
      notifyListeners();
    }
  }
}
