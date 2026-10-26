import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../state/cart_state.dart';

class FloatingCartBar extends StatelessWidget {
  final VoidCallback onViewCart;

  const FloatingCartBar({
    super.key,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cart, child) {
        if (cart.isEmpty) return const SizedBox.shrink();

        final screenWidth = MediaQuery.of(context).size.width;
        // 55-60% of screen width clamped nicely
        final pillWidth = (screenWidth * 0.58).clamp(215.0, 275.0);

        final distinct = cart.distinctProducts;
        final previewItems = distinct.take(3).toList();

        return AnimatedSlide(
          offset: cart.isEmpty ? const Offset(0, 1) : Offset.zero,
          duration: TanizMotion.entranceDuration,
          curve: TanizMotion.entranceCurve,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Compact, Centered, Floating Green Pill (Matching Image 5)
                  Center(
                    child: TanizTappable(
                      onTap: onViewCart,
                      scaleTo: 0.96,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: pillWidth,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C831F), // Crisp quick-commerce green
                          borderRadius: BorderRadius.circular(999), // Fully rounded ends
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0C831F).withValues(alpha: 0.40),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Small Overlapping Product Thumbnails
                            if (previewItems.isNotEmpty)
                              SizedBox(
                                width: 28.0 + (previewItems.length - 1) * 14.0,
                                height: 28,
                                child: Stack(
                                  children: List.generate(previewItems.length, (index) {
                                    return Positioned(
                                      left: index * 14.0,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: previewItems[index].imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (c, u) => const TanizShimmerBox(
                                              width: 28,
                                              height: 28,
                                              borderRadius: 14,
                                            ),
                                            errorWidget: (c, u, e) => const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 14,
                                              color: TanizColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                            const SizedBox(width: 8),

                            // "View cart" & live item count underneath
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'View cart',
                                    style: TanizTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'}',
                                    style: TanizTypography.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.90),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right Chevron
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 2. Separate Free-Delivery Banner Below Pill (Matching Image 5)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: TanizColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Yay! You got FREE Delivery • No coupon needed',
                            style: TanizTypography.caption.copyWith(
                              color: TanizColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: TanizColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
