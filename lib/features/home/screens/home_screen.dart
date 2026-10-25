import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/taniz_app_bar.dart';
import '../../../shared/widgets/search_input_bar.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../state/cart_state.dart';
import '../../listing/screens/product_listing_screen.dart';
import '../../detail/screens/product_detail_screen.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../../shared/widgets/live_motion_banner.dart';
import '../../cart/screens/cart_checkout_screen.dart';
import '../../../state/navigation_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _rushTimer;
  int _rushSecondsRemaining = 14 * 60 + 28;

  @override
  void initState() {
    super.initState();
    _rushTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_rushSecondsRemaining > 0) {
            _rushSecondsRemaining--;
          } else {
            _rushSecondsRemaining = 15 * 60;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rushTimer?.cancel();
    super.dispose();
  }

  String _formatRushTimer() {
    final m = (_rushSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_rushSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockCategoryRepository.getAllCategories();
    final bestsellers = MockProductRepository.getBestsellers();
    final allProducts = MockProductRepository.getAllProducts();

    return Scaffold(
      backgroundColor: TanizColors.canvasBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sticky App Bar with Location & Profile
              SliverToBoxAdapter(
                child: TanizAppBar(
                  onProfileTap: () {
                    Provider.of<NavigationState>(context, listen: false).setIndex(3);
                  },
                  onLocationTap: () {
                    AddressBottomSheet.show(context);
                  },
                ),
              ),

              // 2. Search Bar with Tappable Navigation
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: TanizTappable(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListingScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const SearchInputBar(
                      readOnly: true,
                    ),
                  ),
                ),
              ),

              // 3. Live Dark Store Status Radar Ticker
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: TanizColors.greenContainer,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: TanizColors.greenBorder, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: TanizColors.rapidGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hub #304 Active • 10-15 Min SLA • Sub-4°C Cold-Chain',
                            style: TanizTypography.caption.copyWith(
                              color: TanizColors.rapidGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Instant Moods / Stories Pill Rail (Zepto/Blinkit Style)
              SliverToBoxAdapter(
                child: _buildStoriesRail(context),
              ),

              // 5. Animated Motion Hero Banner (135° Blue->Gold Gradient with Flash Countdown)
              SliverToBoxAdapter(
                child: LiveMotionOfferBanner(
                  onShopNow: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductListingScreen(),
                      ),
                    );
                  },
                ),
              ),

              // 6. Explore Categories Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Categories',
                            style: TanizTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Organized aisles with 1,200+ fresh items',
                            style: TanizTypography.caption.copyWith(
                              color: TanizColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TanizTappable(
                        onTap: () {
                          Provider.of<NavigationState>(context, listen: false).setIndex(1);
                        },
                        child: Row(
                          children: [
                            Text(
                              'View All (24+)',
                              style: TanizTypography.labelMedium.copyWith(
                                color: TanizColors.primaryBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: TanizColors.primaryBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. 8 Category Tiles Grid (4 Columns) with Staggered Entrance
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: AnimationLimiter(
                  child: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = categories[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: TanizMotion.entranceDuration,
                          columnCount: 4,
                          child: ScaleAnimation(
                            curve: TanizMotion.entranceCurve,
                            child: FadeInAnimation(
                              curve: TanizMotion.entranceCurve,
                              child: CategoryCard(
                                category: cat,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductListingScreen(selectedCategory: cat),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
              ),

              // 8. ⚡ Lightning Rush Deals Urgency Section
              SliverToBoxAdapter(
                child: _buildLightningRushSection(context, allProducts),
              ),

              // 9. Bestsellers Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '⚡ Bestsellers in 10 Mins',
                            style: TanizTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: TanizColors.greenContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: TanizColors.greenBorder),
                            ),
                            child: Text(
                              'Express Delivery',
                              style: TanizTypography.caption.copyWith(
                                color: TanizColors.rapidGreenDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TanizTappable(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListingScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TanizTypography.labelMedium.copyWith(
                            color: TanizColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 10. Bestsellers Horizontal Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Consumer<CartState>(
                    builder: (context, cart, _) {
                      return AnimationLimiter(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: bestsellers.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final product = bestsellers[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: TanizMotion.entranceDuration,
                              child: SlideAnimation(
                                horizontalOffset: 40.0,
                                curve: TanizMotion.entranceCurve,
                                child: FadeInAnimation(
                                  curve: TanizMotion.entranceCurve,
                                  child: ProductCard(
                                    width: 164,
                                    product: product,
                                    quantity: cart.getQuantity(product.id),
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
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 11. Daily Kitchen Staples Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Daily Kitchen Staples',
                            style: TanizTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Text(
                              'Wholesale Rates',
                              style: TanizTypography.caption.copyWith(
                                color: const Color(0xFF1D4ED8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TanizTappable(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListingScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TanizTypography.labelMedium.copyWith(
                            color: TanizColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 12. Daily Staples Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Consumer<CartState>(
                    builder: (context, cart, _) {
                      return AnimationLimiter(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: allProducts.reversed.take(5).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final product = allProducts.reversed.take(5).toList()[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: TanizMotion.entranceDuration,
                              child: SlideAnimation(
                                horizontalOffset: 40.0,
                                curve: TanizMotion.entranceCurve,
                                child: FadeInAnimation(
                                  curve: TanizMotion.entranceCurve,
                                  child: ProductCard(
                                    width: 164,
                                    product: product,
                                    quantity: cart.getQuantity(product.id),
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
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 13. The Tanizkart Promise (Trust Bento Grid)
              SliverToBoxAdapter(
                child: _buildTrustBentoGrid(),
              ),

              // 14. Verified Customer Social Proof Banner
              SliverToBoxAdapter(
                child: _buildCustomerProofBanner(),
              ),

              // Extra padding for floating cart bar and bottom navigation
              const SliverToBoxAdapter(
                child: SizedBox(height: 110),
              ),
            ],
          ),

          // Floating Cart Bar (Appears when items are in cart)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingCartBar(
              onViewCart: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets & Builders
  // ---------------------------------------------------------------------------

  Widget _buildStoriesRail(BuildContext context) {
    final stories = [
      {'icon': '⚡', 'label': '10m Rush', 'color': TanizColors.goldenAmber},
      {'icon': '🥦', 'label': 'Farm Fresh', 'color': TanizColors.rapidGreen},
      {'icon': '🥛', 'label': 'Dairy Hub', 'color': TanizColors.primaryBlue},
      {'icon': '🍿', 'label': 'Munchies', 'color': const Color(0xFFEC4899)},
      {'icon': '₹99', 'label': 'Under ₹99', 'color': const Color(0xFFEF4444)},
      {'icon': '🧊', 'label': 'Ice Cold', 'color': const Color(0xFF06B6D4)},
      {'icon': '☕', 'label': 'Chai Time', 'color': const Color(0xFFD97706)},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: stories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final story = stories[index];
            final color = story['color'] as Color;
            return TanizTappable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListingScreen()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        story['icon'] as String,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    story['label'] as String,
                    style: TanizTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: TanizColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLightningRushSection(BuildContext context, List<Product> allProducts) {
    final rushProducts = allProducts.take(3).toList();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3).withValues(alpha: 0.4),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: TanizColors.goldenAmber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: TanizColors.goldenAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⚡ Lightning Rush Deals',
                      style: TanizTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TanizColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TanizColors.goldenAmber,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Ending in ${_formatRushTimer()}',
                        style: TanizTypography.caption.copyWith(
                          fontWeight: FontWeight.w900,
                          color: TanizColors.midnightNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                TanizTappable(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductListingScreen()),
                    );
                  },
                  child: Text(
                    'All Deals',
                    style: TanizTypography.labelMedium.copyWith(
                      color: TanizColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: Consumer<CartState>(
              builder: (context, cart, _) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: rushProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = rushProducts[index];
                    return ProductCard(
                      width: 164,
                      product: product,
                      quantity: cart.getQuantity(product.id),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBentoGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0038A8).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE TANIZKART PROMISE',
                      style: TanizTypography.caption.copyWith(
                        color: TanizColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Why Lawyerpet Trusts Us Daily',
                      style: TanizTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TanizColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TanizColors.greenContainer,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: TanizColors.greenBorder),
                  ),
                  child: Text(
                    '⭐ 4.8 / 5 Rating',
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.rapidGreenDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard('⚡', '10-15 Min SLA', 'Packed in 180s flat'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBentoCard('❄️', 'Sub-4°C Cold Chain', 'Ice-bag sealed dairy'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard('💰', 'Wholesale Rates', 'Factory direct savings'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBentoCard('🛡️', '1-Tap Refund', 'No questions asked'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard(String icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TanizTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TanizColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: TanizColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerProofBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TanizColors.midnightNavy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TanizColors.midnightNavy.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: TanizColors.goldenAmber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '12,500+ Happy Orders Delivered',
                    style: TanizTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Across Lawyerpet, Trunk Road & Ongole Hub',
                    style: TanizTypography.caption.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
