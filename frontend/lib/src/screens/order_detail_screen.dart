import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/order_status_badge.dart';

/// Screen displaying the full details of a specific order.
/// Shows order ID, status, date, grouped items with quantities, and payment summary.
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  /// Groups flat list of MenuItems into a map of {MenuItem: Quantity}
  Map<MenuItem, int> _groupItems() {
    final grouped = <MenuItem, int>{};
    for (var item in order.elements) {
      // Find if we already have this item by ID
      final existingItem = grouped.keys
          .firstWhere((k) => k.id == item.id, orElse: () => item);

      if (grouped.containsKey(existingItem)) {
        grouped[existingItem] = grouped[existingItem]! + 1;
      } else {
        grouped[existingItem] = 1;
      }
    }
    return grouped;
  }

  void _handleReorder(BuildContext context) {
    final cart = context.read<CartProvider>();
    for (final item in order.elements) {
      cart.addItem(item);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${order.itemCount} article${order.itemCount > 1 ? 's' : ''} ajouté${order.itemCount > 1 ? 's' : ''} au panier'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItems();

    // Calculate totals (simulated based on the app's current logic)
    final subtotal = order.totalPrice; // We'll treat order.totalPrice as subtotal here for display
    final tax = subtotal * 0.15;
    final serviceFee = 5.0; // Fixed service fee for in-restaurant
    final total = subtotal + tax + serviceFee;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header Card (Order Info) ───
                    _buildHeaderCard(),
                    const SizedBox(height: 24),

                    // ─── Items Section Title ───
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: AppTheme.primary.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        const Text(
                          'Items Ordered',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Items List ───
                    ...groupedItems.entries.map((entry) => _buildItemCard(entry.key, entry.value)),

                    const SizedBox(height: 8),

                    // ─── Payment Summary ───
                    _buildPaymentSummary(subtotal, tax, serviceFee, total),
                  ],
                ),
              ),
            ),
            
            // ─── Bottom Actions Bar ───
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final borderColor = OrderStatusBadge.borderColorFor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent Border
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order #',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '#ORD-${order.id}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppTheme.textMuted.withOpacity(0.1), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          order.formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(MenuItem item, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.displayImageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppTheme.primaryFaded.withOpacity(0.2),
                child: const Icon(Icons.restaurant, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nom,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Quantity: $quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    // Price
                    Text(
                      '${(item.prix * quantity).toStringAsFixed(0)} DH',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double subtotal, double tax, double serviceFee, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow('Subtotal', subtotal),
          const SizedBox(height: 12),
          _summaryRow('VAT (15%)', tax),
          const SizedBox(height: 12),
          _summaryRow('Service Fee', serviceFee),
          const SizedBox(height: 16),
          
          // Dotted Divider (simulated with standard divider for simplicity)
          Divider(color: AppTheme.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),

          // Total Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryFaded.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} DH',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment Method Note
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card, size: 16, color: AppTheme.textMuted),
              SizedBox(width: 8),
              Text(
                'Paid via In-App Payment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
        ),
        Text(
          amount == 0 ? 'Free' : '${amount.toStringAsFixed(2)} DH',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: amount == 0 ? Colors.green.shade600 : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
      ),
      child: Row(
        children: [
          // Reorder Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handleReorder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC2609),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Reorder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Help Button
          SizedBox(
            height: 56,
            width: 56,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling waiter for assistance...')),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.primaryFaded.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.help_outline, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
