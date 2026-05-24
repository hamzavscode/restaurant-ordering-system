import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'order_status_badge.dart';

/// A card widget that displays a single order in the order history.
/// Follows the design reference with colored left border, item thumbnails,
/// status badge, total price, and optional reorder button.
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onReorder;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = OrderStatusBadge.borderColorFor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textMuted.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ─── Colored Left Accent Border ───
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

                // ─── Card Content ───
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Order ID + Status Badge ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            OrderStatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // ─── Date ───
                        Text(
                          order.formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Divider ───
                        Divider(
                          color: AppTheme.textMuted.withOpacity(0.1),
                          height: 1,
                        ),
                        const SizedBox(height: 16),

                        // ─── Items Count + Thumbnails & Total ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Items section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildItemThumbnails(),
                              ],
                            ),
                            // Total section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.totalPrice.toStringAsFixed(2)} DH',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ─── Reorder Button (only for CONFIRMED orders) ───
                        if (order.status == 'CONFIRMED' && onReorder != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: onReorder,
                              icon: const Icon(Icons.restaurant_menu, size: 16),
                              label: const Text('Reorder'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds overlapping circular thumbnails for the order's items.
  Widget _buildItemThumbnails() {
    final displayCount = order.elements.length > 3 ? 3 : order.elements.length;
    final extraCount = order.elements.length - displayCount;

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          // Overlapping avatars
          SizedBox(
            width: displayCount * 28.0 + (extraCount > 0 ? 28 : 0),
            child: Stack(
              children: [
                for (int i = 0; i < displayCount; i++)
                  Positioned(
                    left: i * 22.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          order.elements[i].displayImageUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.primaryFaded.withOpacity(0.3),
                            child: const Icon(Icons.restaurant,
                                size: 16, color: AppTheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                // "+N" badge if more items
                if (extraCount > 0)
                  Positioned(
                    left: displayCount * 22.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryFaded.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surface, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '+$extraCount',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
