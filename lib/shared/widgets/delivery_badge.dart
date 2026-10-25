import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class DeliveryBadge extends StatelessWidget {
  final String text;
  final bool isCompact;

  const DeliveryBadge({
    super.key,
    this.text = '10 MINS',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: TanizColors.greenContainer,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: TanizColors.greenBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⚡',
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TanizTypography.labelSmall.copyWith(
              color: TanizColors.rapidGreenDark,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
