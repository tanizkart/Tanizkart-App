import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/typography.dart';

class TanizBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TanizBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: const Border(
          top: BorderSide(color: TanizColors.borderSubtle, width: 1),
        ),
        boxShadow: [TanizColors.cardShadow],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Categories',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Orders',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = currentIndex == index;
    return TanizTappable(
      scaleTo: 0.94,
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? TanizColors.primaryBlue : TanizColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TanizTypography.labelSmall.copyWith(
                color: isActive ? TanizColors.primaryBlue : TanizColors.textSecondary,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
