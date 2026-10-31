import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/product_model.dart';
import '../../state/wishlist_state.dart';
import '../../state/auth_state.dart';
import '../../features/auth/screens/login_sheet.dart';
import 'add_to_cart_stepper.dart';
import 'taniz_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  final double? width;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.width,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      scaleTo: 0.97,
      child: SizedBox(
        width: width,
        child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: quantity > 0
                ? TanizColors.primaryBlue.withValues(alpha: 0.35)
                : TanizColors.borderCard,
            width: quantity > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            TanizColors.cardShadow,
            if (quantity > 0)
              BoxShadow(
                color: TanizColors.primaryBlue.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed aspect top section with ClipRRect(16) & BoxFit.cover
            Expanded(
              flex: 12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TanizImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    heroTag: heroTag,
                    fallbackLabel: product.name,
                    fallbackEmoji: '🛒',
                  ),

                  // Top Left: High-Impact Discount Tag (e.g. 23% OFF)
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TanizColors.royalBlue,
                          borderRadius: BorderRadius.circular(999), // 999px pill badge
                          boxShadow: [
                            BoxShadow(
                              color: TanizColors.royalBlue.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Top Right: Accessible Wishlist Save Button with immediate visual feedback
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer2<WishlistState, AuthState>(
                      builder: (context, wishlist, auth, _) {
                        final isSaved = wishlist.isWishlisted(product.id);
                        return Semantics(
                          button: true,
                          label: isSaved ? 'Remove from wishlist' : 'Save to wishlist',
                          child: TanizTappable(
                            onTap: () {
                              wishlist.toggleWishlist(
                                product,
                                isAuthenticated: auth.isAuthenticated,
                                onRequireLogin: () => LoginSheet.show(context),
                              );
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    key: ValueKey<bool>(isSaved),
                                    size: 18,
                                    color: isSaved ? TanizColors.errorRed : TanizColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Product Details Section
            Padding(
              padding: const EdgeInsets.all(12), // Standard 12px spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Name
                  Text(
                    product.brand.toUpperCase(),
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Product Title (Plus Jakarta Sans)
                  Text(
                    product.name,
                    style: TanizTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Pack Size / Weight (Inter)
                  Text(
                    product.packSize,
                    style: TanizTypography.bodySmall.copyWith(
                      color: TanizColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Row & Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Pricing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.price),
                              style: TanizTypography.priceMedium.copyWith(
                                color: TanizColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            if (product.originalPrice > product.price)
                              Text(
                                CurrencyFormatter.format(product.originalPrice),
                                style: TanizTypography.caption.copyWith(
                                  color: TanizColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Stepper / ADD Button
                      AddToCartStepper(
                        quantity: quantity,
                        onAdd: onAdd,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
