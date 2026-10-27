import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../state/wishlist_state.dart';
import '../../../state/cart_state.dart';
import '../../../core/utils/cart_navigation.dart';
import '../../../features/detail/screens/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistState>(
      builder: (context, wishlistState, _) {
        final products = wishlistState.savedProducts;
        final cart = context.watch<CartState>();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Text(
                  'Wishlist',
                  style: TanizTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (products.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: TanizColors.blueContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${products.length}',
                      style: TanizTypography.labelSmall.copyWith(
                        color: TanizColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (products.isNotEmpty)
                IconButton(
                  tooltip: 'Clear Wishlist',
                  icon: const Icon(Icons.delete_outline_rounded, color: TanizColors.textSecondary),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Clear Wishlist?'),
                        content: const Text('Are you sure you want to remove all saved items from your wishlist?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              wishlistState.clearWishlist();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear All', style: TextStyle(color: TanizColors.errorRed)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              if (wishlistState.isLoading && products.isEmpty)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(TanizColors.primaryBlue),
                  ),
                )
              else if (products.isEmpty && wishlistState.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: TanizColors.errorRed),
                        const SizedBox(height: 12),
                        Text(
                          wishlistState.error!,
                          textAlign: TextAlign.center,
                          style: TanizTypography.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => wishlistState.retry(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TanizColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (products.isEmpty)
                _buildEmptyState(context)
              else
                GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    14,
                    14,
                    14,
                    cart.totalItemCount > 0 ? 100 : 24,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final qty = cart.getQuantity(product.id);
                    return ProductCard(
                      product: product,
                      quantity: qty,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      onAdd: () => cart.addItem(product),
                      onIncrement: () => cart.addItem(product),
                      onDecrement: () => cart.removeItem(product),
                    );
                  },
                ),

              // Floating Cart Bar if cart has items
              if (cart.totalItemCount > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: FloatingCartBar(
                    onViewCart: () => CartNavigation.openCart(context),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: TanizColors.redContainer,
                shape: BoxShape.circle,
                border: Border.all(color: TanizColors.errorRed.withValues(alpha: 0.2), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: TanizColors.errorRed,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Wishlist is Empty',
              style: TanizTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore TanizKart products and tap the heart icon on any product to save it here for quick access later.',
              textAlign: TextAlign.center,
              style: TanizTypography.bodyMedium.copyWith(
                color: TanizColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            TanizTappable(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: TanizColors.blueGoldGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: TanizColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Browse Products',
                      style: TanizTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
