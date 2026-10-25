import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';

class AddToCartStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isCompact;

  const AddToCartStepper({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: TanizMotion.stateDuration,
      switchInCurve: TanizMotion.stateCurve,
      switchOutCurve: TanizMotion.stateCurve,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: quantity == 0 ? _buildAddButton(context) : _buildStepper(context),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return TanizTappable(
      key: const ValueKey('add_btn'),
      onTap: onAdd,
      borderRadius: BorderRadius.circular(12),
      scaleTo: 0.94,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: TanizColors.amberBadgeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TanizColors.accentGold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TanizColors.accentGold.withValues(alpha: 0.16),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ADD',
              style: TanizTypography.labelMedium.copyWith(
                color: TanizColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.add_rounded,
              size: 14,
              color: TanizColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Container(
      key: const ValueKey('stepper_active'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: TanizColors.accentGold,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TanizColors.accentGold.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedSwitcher(
              duration: TanizMotion.stateDuration,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                style: TanizTypography.labelLarge.copyWith(
                  color: TanizColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TanizTappable(
      onTap: onTap,
      scaleTo: 0.88,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: isCompact ? 14 : 16,
          color: TanizColors.textPrimary,
        ),
      ),
    );
  }
}
