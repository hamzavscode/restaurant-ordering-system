import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A visual progress bar showing the order's journey through statuses.
/// Shows steps: Pending → Confirmed → (or Cancelled).
class OrderProgressBar extends StatelessWidget {
  final String status;

  const OrderProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut de la commande',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          if (status == 'CANCELLED')
            _buildCancelledView()
          else
            _buildProgressView(),
        ],
      ),
    );
  }

  Widget _buildProgressView() {
    final steps = [
      _StepData('Reçue', Icons.receipt_long, true),
      _StepData(
          'En préparation',
          Icons.restaurant,
          status == 'CONFIRMED'),
      _StepData(
          'Confirmée',
          Icons.check_circle,
          status == 'CONFIRMED'),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isActive = steps[stepIndex + 1].isActive;
          return Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2E7D32)
                    : AppTheme.textMuted.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        final step = steps[index ~/ 2];
        return _buildStep(step);
      }),
    );
  }

  Widget _buildStep(_StepData step) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: step.isActive
                ? const Color(0xFF2E7D32).withOpacity(0.1)
                : AppTheme.textMuted.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: step.isActive
                  ? const Color(0xFF2E7D32)
                  : AppTheme.textMuted.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            step.icon,
            size: 20,
            color: step.isActive
                ? const Color(0xFF2E7D32)
                : AppTheme.textMuted.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: step.isActive ? FontWeight.w700 : FontWeight.w500,
            color: step.isActive
                ? const Color(0xFF2E7D32)
                : AppTheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCancelledView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel, color: Color(0xFFC62828), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande annulée',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cette commande a été annulée.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC62828),
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

class _StepData {
  final String label;
  final IconData icon;
  final bool isActive;

  _StepData(this.label, this.icon, this.isActive);
}
