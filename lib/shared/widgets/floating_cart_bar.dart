import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/currency_formatter.dart';
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

        final distinct = cart.distinctProducts;
        final previewItems = distinct.take(3).toList();

        return AnimatedSlide(
          offset: cart.isEmpty ? const Offset(0, 1) : Offset.zero,
          duration: TanizMotion.entranceDuration,
          curve: TanizMotion.entranceCurve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top: Free Delivery Celebration Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: TanizColors.greenContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border.all(color: TanizColors.greenBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: TanizColors.rapidGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Yay! You unlocked FREE Delivery • No coupon needed',
                        style: TanizTypography.caption.copyWith(
                          color: TanizColors.rapidGreenDark,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Pill: Overlapping items + "View cart" + Count & Price
              TanizTappable(
                onTap: onViewCart,
                scaleTo: 0.97,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: TanizColors.rapidGreen,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: TanizColors.rapidGreen.withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Overlapping Circular Packshot Avatars
                      Row(
                        children: [
                          SizedBox(
                            width: previewItems.isEmpty
                                ? 36
                                : 36 + (previewItems.length - 1) * 20.0,
                            height: 36,
                            child: Stack(
                              children: List.generate(previewItems.length, (index) {
                                return Positioned(
                                  left: index * 20.0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: previewItems[index].imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (c, u) => const TanizShimmerBox(
                                          width: 36,
                                          height: 36,
                                          borderRadius: 18,
                                        ),
                                        errorWidget: (c, u, e) => const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 18,
                                          color: TanizColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'View cart',
                                    style: TanizTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ElasticPopBadge(
                                    count: cart.totalItemCount,
                                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    cart.totalItemCount == 1 ? 'item in basket' : 'items in basket',
                                    style: TanizTypography.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: Price Badge (12px button/chip)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          CurrencyFormatter.format(cart.grandTotal),
                          style: TanizTypography.priceMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
