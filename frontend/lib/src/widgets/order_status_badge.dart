import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A colored badge widget that displays an order's status.
/// Adapted for in-restaurant ordering:
///   PENDING → "En attente" (Waiting — order just placed)
///   CONFIRMED → "En préparation" (Preparing — kitchen working on it)
///   CANCELLED → "Annulée"
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _textColor),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status) {
      case 'PENDING':
        return 'Waiting';
      case 'CONFIRMED':
        return 'Preparing';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.restaurant;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFE6A817); // Amber/yellow
      case 'CONFIRMED':
        return const Color(0xFFE8630A); // Orange
      case 'CANCELLED':
        return const Color(0xFFC62828); // Red
      default:
        return AppTheme.textMuted;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFF8E1); // Light yellow
      case 'CONFIRMED':
        return const Color(0xFFFFF3E0); // Light orange
      case 'CANCELLED':
        return const Color(0xFFF8D7DA); // Light red
      default:
        return AppTheme.background;
    }
  }

  /// Returns the accent color for the card's left border.
  static Color borderColorFor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFD54F); // Yellow border
      case 'CONFIRMED':
        return const Color(0xFFFF9800); // Orange border
      case 'CANCELLED':
        return const Color(0xFFEF5350); // Red border
      default:
        return AppTheme.textMuted;
    }
  }
}
