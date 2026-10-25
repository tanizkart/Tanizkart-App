import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../state/cart_state.dart';
import '../../detail/screens/product_detail_screen.dart';
import '../../cart/screens/cart_checkout_screen.dart';
import '../../../state/location_state.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';

class ProductListingScreen extends StatefulWidget {
  final Category? selectedCategory;

  const ProductListingScreen({
    super.key,
    this.selectedCategory,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late Category _category;
  String _selectedSubcategory = 'All';
  ProductSortOption _selectedSort = ProductSortOption.popular;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory ?? MockCategoryRepository.getAllCategories().first;
    if (_category.subcategories.isNotEmpty) {
      _selectedSubcategory = _category.subcategories.first;
    }
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Products By',
                      style: TanizTypography.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: TanizColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...ProductSortOption.values.map((option) {
                  final isSelected = option == _selectedSort;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSort = option;
                      });
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.label,
                            style: TanizTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? TanizColors.primaryBlue : TanizColors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: TanizColors.primaryBlue,
                              size: 20,
                            )
                          else
                            const Icon(
                              Icons.radio_button_off_rounded,
                              color: TanizColors.borderSubtle,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = MockProductRepository.getAllProducts();

    // 1. Filter by subcategory
    final filtered = _selectedSubcategory == 'All'
        ? allProducts
        : allProducts.where((p) => p.subcategory == _selectedSubcategory).toList();

    final baseList = filtered.isNotEmpty ? filtered : allProducts;

    // 2. Sort by selected option (verified data flow)
    final displayProducts = MockProductRepository.sortProducts(baseList, _selectedSort);

    return Scaffold(
      backgroundColor: TanizColors.canvasBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky App Header with Back, Title, and Cart
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (Navigator.canPop(context))
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: TanizColors.textPrimary,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  Text(
                                    _category.name,
                                    style: TanizTypography.titleLarge.copyWith(
                                      color: TanizColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search_rounded,
                                      color: TanizColors.textPrimary,
                                    ),
                                    onPressed: () {},
                                  ),
                                  Consumer<CartState>(
                                    builder: (context, cart, _) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: TanizColors.primaryBlue,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const CartCheckoutScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                          if (cart.isNotEmpty)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: ElasticPopBadge(
                                                count: cart.totalItemCount,
                                                backgroundColor: TanizColors.accentGold,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Delivery Location Bar
                        Consumer<LocationState>(
                          builder: (context, locState, _) {
                            final addr = locState.selectedAddress;
                            return TanizTappable(
                              onTap: () => AddressBottomSheet.show(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                color: TanizColors.surfaceLow,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: TanizColors.primaryBlue,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Deliver to ${addr.tag} • ${addr.label}',
                                          style: TanizTypography.labelMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 16,
                                          color: TanizColors.primaryBlue,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Change',
                                      style: TanizTypography.labelSmall.copyWith(
                                        color: TanizColors.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Subcategory Horizontal Pill Rail
                        Container(
                          color: Colors.white,
                          height: 48,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _category.subcategories.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final subcat = _category.subcategories[index];
                              final isSelected = subcat == _selectedSubcategory;
                              return TanizTappable(
                                onTap: () {
                                  setState(() {
                                    _selectedSubcategory = subcat;
                                  });
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? TanizColors.primaryBlue : TanizColors.surfaceLow,
                                    borderRadius: BorderRadius.circular(999), // 999px pill
                                    border: Border.all(
                                      color: isSelected
                                          ? TanizColors.primaryBlue
                                          : TanizColors.borderSubtle,
                                    ),
                                  ),
                                  child: Text(
                                    subcat,
                                    style: TanizTypography.caption.copyWith(
                                      color: isSelected ? Colors.white : TanizColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(height: 1, color: TanizColors.borderSubtle),
                      ],
                    ),
                  ),
                ),
              ),

              // Filter & Sort Interactive Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${displayProducts.length} items in ${_category.name}',
                        style: TanizTypography.bodySmall.copyWith(
                          color: TanizColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Interactive Sort Button
                      TanizTappable(
                        onTap: () => _showSortSheet(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12), // 12px chip
                            border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
                            boxShadow: [TanizColors.cardShadow],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sort_rounded,
                                size: 16,
                                color: TanizColors.primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedSort.label,
                                style: TanizTypography.caption.copyWith(
                                  color: TanizColors.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 16,
                                color: TanizColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Staggered Animated 2-Column Bento Product Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: Consumer<CartState>(
                  builder: (context, cart, _) {
                    return AnimationLimiter(
                      child: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = displayProducts[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: TanizMotion.entranceDuration,
                              columnCount: 2,
                              child: ScaleAnimation(
                                curve: TanizMotion.entranceCurve,
                                child: FadeInAnimation(
                                  curve: TanizMotion.entranceCurve,
                                  child: ProductCard(
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
                          childCount: displayProducts.length,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Extra spacer for floating cart bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Floating Cart Bar
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
}
