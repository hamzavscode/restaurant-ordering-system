import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a beautiful bottom sheet with item details when a menu card is tapped.
/// Includes hero image, description, price, quantity selector, and add-to-cart button.
void showItemDetail(
  BuildContext context,
  Map<String, dynamic> item,
  String imageUrl,
  Function(Map<String, dynamic> item, int quantity) onAddToCart,
) {
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final double price = (item['prix'] ?? 0).toDouble();
          final double totalPrice = price * quantity;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // ─── Drag Handle ───
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ─── Scrollable Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Hero Image ───
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            imageUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryFaded.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.restaurant,
                                  size: 60, color: AppTheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Category Badge ───
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getCategoryLabel(item['typeElement'] ?? item['type_element']),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ─── Item Name ───
                        Text(
                          item['nom'] ?? 'Sans nom',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ─── Price ───
                        Text(
                          '${price.toStringAsFixed(0)} DH',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Description ───
                        Text(
                          item['description'] ?? 'Aucune description disponible',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Extra Info Chips ───
                        _buildInfoChips(item),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Action Bar (Quantity + Add to Cart) ───
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ─── Quantity Selector ───
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _quantityButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (quantity > 1) {
                                  setModalState(() => quantity--);
                                }
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            _quantityButton(
                              icon: Icons.add,
                              onTap: () {
                                setModalState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ─── Add to Cart Button ───
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            onAddToCart(item, quantity);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Ajouter  •  ${totalPrice.toStringAsFixed(0)} DH',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
        },
      );
    },
  );
}

/// Quantity button (+/-)
Widget _quantityButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: AppTheme.primary),
    ),
  );
}

/// Category label from backend type
String _getCategoryLabel(String? type) {
  switch (type) {
    case 'PLAT':
      return '🍽️  Plat Principal';
    case 'BOISSON':
      return '🥤  Boisson';
    case 'DESSERT':
      return '🍰  Dessert';
    default:
      return '🍽️  Menu';
  }
}

/// Info chips showing extra details (prep time, calories, volume, etc.)
Widget _buildInfoChips(Map<String, dynamic> item) {
  final List<Widget> chips = [];
  final type = item['typeElement'] ?? item['type_element'];

  if (type == 'PLAT' && item['tempsPreparationMinutes'] != null && item['tempsPreparationMinutes'] > 0) {
    chips.add(_infoChip(Icons.timer_outlined, '${item['tempsPreparationMinutes']} min'));
  }

  if (type == 'DESSERT') {
    if (item['calories'] != null && item['calories'] > 0) {
      chips.add(_infoChip(Icons.local_fire_department_outlined, '${item['calories']} cal'));
    }
    if (item['estServiChaud'] == true) {
      chips.add(_infoChip(Icons.whatshot, 'Servi chaud'));
    } else {
      chips.add(_infoChip(Icons.ac_unit, 'Servi froid'));
    }
  }

  if (type == 'BOISSON') {
    if (item['volumeLitre'] != null && item['volumeLitre'] > 0) {
      chips.add(_infoChip(Icons.water_drop_outlined, '${(item['volumeLitre'] * 100).toInt()} cl'));
    }
    if (item['contientAlcool'] == true) {
      chips.add(_infoChip(Icons.wine_bar, 'Alcoolisée'));
    } else {
      chips.add(_infoChip(Icons.no_drinks, 'Sans alcool'));
    }
  }

  if (chips.isEmpty) return const SizedBox.shrink();

  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: chips,
  );
}

/// Single info chip widget
Widget _infoChip(IconData icon, String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.textMuted.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    ),
  );
}
