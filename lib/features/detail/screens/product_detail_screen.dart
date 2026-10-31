import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/taniz_image.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../state/cart_state.dart';
import '../../../core/utils/cart_navigation.dart';
import '../../search/screens/product_search_screen.dart';

import '../../../state/wishlist_state.dart';
import '../../../state/auth_state.dart';
import '../../auth/screens/login_sheet.dart';
import '../../profile/screens/wishlist_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedPackIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final similarProducts = MockProductRepository.getAllProducts()
        .where((p) => p.id != product.id)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Clean Blinkit-style App Bar with Back, Wishlist, Search & Share
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: TanizColors.textPrimary,
                            onPressed: () => Navigator.pop(context),
                          ),
                          Row(
                            children: [
                              Consumer2<WishlistState, AuthState>(
                                builder: (context, wishlistState, authState, _) {
                                  final isSaved = wishlistState.isWishlisted(product.id);
                                  return IconButton(
                                    tooltip: isSaved ? 'Remove from Wishlist' : 'Add to Wishlist',
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: Icon(
                                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        key: ValueKey(isSaved),
                                        color: isSaved ? TanizColors.errorRed : TanizColors.textPrimary,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!authState.isAuthenticated) {
                                        LoginSheet.show(context);
                                        return;
                                      }
                                      final added = await wishlistState.toggleWishlist(product);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              added
                                                  ? '${product.name} saved to Wishlist'
                                                  : '${product.name} removed from Wishlist',
                                            ),
                                            backgroundColor: TanizColors.navyDark,
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            action: added
                                                ? SnackBarAction(
                                                    label: 'VIEW',
                                                    textColor: TanizColors.primaryGold,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => const WishlistScreen(),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.search_rounded),
                                color: TanizColors.textPrimary,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProductSearchScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                color: TanizColors.textPrimary,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('🔗 Product link copied to clipboard')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Hero Packshot Stage with Radial Glow
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          const Color(0xFFEFF4FC),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: TanizColors.borderSubtle),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (product.discountPercent > 0)
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: TanizColors.goldenAmber,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: TanizColors.goldenAmber.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${product.discountPercent}% OFF • SAVE ${CurrencyFormatter.format(product.savings)}',
                                style: TanizTypography.labelSmall.copyWith(
                                  color: TanizColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                        // Close-up Hero Image (fixed aspect, BoxFit.cover, 16px radius, shimmer placeholder)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            child: TanizImage(
                              imageUrl: product.imageUrl,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(16),
                              heroTag: widget.heroTag,
                              fallbackLabel: product.name,
                              fallbackEmoji: '🛒',
                            ),
                          ),
                        ),

                        // Carousel Dots
                        Positioned(
                          bottom: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: TanizColors.goldenAmber,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title, Brand & Pack Size Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: TanizColors.blueContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.brand,
                              style: TanizTypography.labelSmall.copyWith(
                                color: TanizColors.primaryBlue,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: TanizColors.goldenAmber),
                              const SizedBox(width: 2),
                              Text(
                                '${product.rating}',
                                style: TanizTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                ' (${product.ratingCount}+)',
                                style: TanizTypography.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: TanizTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.packSize,
                        style: TanizTypography.bodyMedium.copyWith(
                          color: TanizColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pack Size Selector Chips
                      Text(
                        'Select Pack Size',
                        style: TanizTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPackChip(0, product.packSize, product.price),
                          const SizedBox(width: 10),
                          _buildPackChip(1, '1 Litre Pouch', product.price * 1.9),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Pricing & Dark Store Savings Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: TanizColors.amberContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: TanizColors.goldenAmber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(product.price),
                                      style: TanizTypography.priceLarge.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'MRP ${CurrencyFormatter.format(product.originalPrice)}',
                                      style: TanizTypography.bodySmall.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: TanizColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Inclusive of all taxes • Direct Warehouse Price',
                                  style: TanizTypography.bodySmall.copyWith(
                                    fontSize: 10.5,
                                    color: TanizColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: TanizColors.goldenAmber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Save ${CurrencyFormatter.format(product.savings)}',
                                style: TanizTypography.labelSmall.copyWith(
                                  color: TanizColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nutritional Bento (4 cards)
                      if (product.nutritionalInfo.isNotEmpty) ...[
                        Text(
                          'Nutritional Value (Per 100ml)',
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: product.nutritionalInfo.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.2,
                          ),
                          itemBuilder: (context, index) {
                            final key = product.nutritionalInfo.keys.elementAt(index);
                            final val = product.nutritionalInfo.values.elementAt(index);
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TanizColors.canvasBackground,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: TanizColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    key,
                                    style: TanizTypography.bodySmall.copyWith(
                                      color: TanizColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    val,
                                    style: TanizTypography.titleMedium.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Product Details Description
                      Text(
                        'Product Overview',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        style: TanizTypography.bodyMedium.copyWith(
                          color: TanizColors.textSecondary,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quality Assurance Seals
                      Column(
                        children: product.highlights.map((h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18, color: TanizColors.rapidGreen),
                              const SizedBox(width: 8),
                              Text(
                                h,
                                style: TanizTypography.bodySmall.copyWith(
                                  color: TanizColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Frequently Bought Together Mini-Shelf
                      Text(
                        'Frequently Bought Together',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: Consumer<CartState>(
                          builder: (context, cart, _) {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarProducts.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                final p = similarProducts[idx];
                                return ProductCard(
                                  width: 145,
                                  product: p,
                                  quantity: cart.getQuantity(p.id),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: p),
                                      ),
                                    );
                                  },
                                  onAdd: () => cart.addItem(p),
                                  onIncrement: () => cart.addItem(p),
                                  onDecrement: () => cart.removeItem(p),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Checkout Dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<CartState>(
              builder: (context, cart, _) {
                final qty = cart.getQuantity(product.id);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(color: TanizColors.borderSubtle),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Left: Quantity Stepper
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: TanizColors.surfaceLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: TanizColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded),
                                color: TanizColors.textPrimary,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: qty > 0 ? () => cart.removeItem(product) : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '$qty',
                                  style: TanizTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_rounded),
                                color: TanizColors.textPrimary,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () => cart.addItem(product),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right: 135° Blue→Gold Gradient Primary CTA (12px radius, soft shadow, TanizTappable)
                        Expanded(
                          child: TanizTappable(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (qty == 0) {
                                cart.addItem(product);
                              }
                              CartNavigation.openCart(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: TanizColors.blueGoldGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [TanizColors.softShadow],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shopping_basket_rounded, size: 20, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        qty > 0 ? 'View in Cart' : 'Add to Cart',
                                        style: TanizTypography.labelLarge.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(qty > 0 ? product.price * qty : product.price),
                                        style: TanizTypography.priceMedium.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackChip(int index, String label, double price) {
    final isSelected = _selectedPackIndex == index;
    return TanizTappable(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedPackIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TanizColors.blueContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TanizColors.primaryBlue : TanizColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TanizTypography.labelSmall.copyWith(
                color: isSelected ? TanizColors.primaryBlue : TanizColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            Text(
              CurrencyFormatter.format(price),
              style: TanizTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? TanizColors.primaryBlue : TanizColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
