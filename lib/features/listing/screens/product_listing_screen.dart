import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/utils/cart_navigation.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../state/cart_state.dart';
import '../../detail/screens/product_detail_screen.dart';
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

  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  double _savedScrollOffset = 0.0;
  int _searchRequestId = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory ?? MockCategoryRepository.getAllCategories().first;
    _selectedSubcategory = 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _activateSearch() {
    if (!_isSearchActive) {
      if (_scrollController.hasClients) {
        _savedScrollOffset = _scrollController.offset;
      }
      setState(() {
        _isSearchActive = true;
      });
    }
    _searchFocusNode.requestFocus();
  }

  void _closeSearch() {
    _searchRequestId++;
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchActive = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _restoreScrollPosition();
  }

  void _onSearchChanged(String query) {
    final clean = query.trim();
    final currentId = ++_searchRequestId;

    if (clean.isEmpty) {
      setState(() {
        _searchQuery = '';
      });
      _restoreScrollPosition();
      return;
    }

    Future.microtask(() {
      if (currentId != _searchRequestId) return;
      if (mounted) {
        setState(() {
          _searchQuery = clean;
        });
      }
    });
  }

  void _restoreScrollPosition() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final target = _savedScrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(target);
        }
      });
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
                // Only remaining options: Popularity, Price: Low to High, Price: High to Low, Highest Discount
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
    // 1. Strictly fetch products belonging to this category to prevent unrelated products leakage
    final categoryProducts = MockProductRepository.getProductsByCategory(_category.id);

    // 2. Filter strictly by active subcategory
    final List<Product> subcatFiltered = _selectedSubcategory == 'All'
        ? categoryProducts
        : categoryProducts.where((p) => p.subcategory == _selectedSubcategory).toList();

    // 3. Search within selected category and respect active subcategory
    final List<Product> searchFiltered;
    if (_searchQuery.isEmpty) {
      searchFiltered = subcatFiltered;
    } else {
      final q = _searchQuery.toLowerCase();
      searchFiltered = subcatFiltered.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.subcategory.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }

    // 4. Sort according to selected sort option (preserves category/subcategory/search)
    final displayProducts = MockProductRepository.sortProducts(searchFiltered, _selectedSort);

    // 5. Derive active label & product count text correctly
    final activeLabel = _selectedSubcategory == 'All'
        ? _category.name
        : _selectedSubcategory;

    final count = displayProducts.length;
    final countText = _searchQuery.isNotEmpty
        ? '$count ${count == 1 ? 'item' : 'items'} found in $activeLabel'
        : '$count ${count == 1 ? 'item' : 'items'} in $activeLabel';

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: !_isSearchActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
          return;
        }
        _closeSearch();
      },
      child: Scaffold(
        backgroundColor: TanizColors.canvasBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: TanizColors.textPrimary,
            ),
            onPressed: () {
              if (_isSearchActive) {
                _closeSearch();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          titleSpacing: 0,
          title: _isSearchActive
              ? Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: TanizColors.surfaceLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TanizColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: TanizColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          autofocus: true,
                          style: TanizTypography.bodyMedium.copyWith(
                            color: TanizColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search in ${_selectedSubcategory == 'All' ? _category.name : _selectedSubcategory}...',
                            hintStyle: TanizTypography.bodyMedium.copyWith(
                              color: TanizColors.textMuted,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            _searchFocusNode.requestFocus();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: TanizColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _category.name,
                      style: TanizTypography.titleMedium.copyWith(
                        color: TanizColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Consumer<LocationState>(
                      builder: (context, locState, _) {
                        final addr = locState.selectedAddress;
                        return TanizTappable(
                          onTap: () => AddressBottomSheet.show(context),
                          child: Row(
                            children: [
                              Text(
                                'Deliver to ${addr.tag} • ${addr.label}',
                                style: TanizTypography.caption.copyWith(
                                  color: TanizColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: TanizColors.textSecondary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
          actions: [
            // Search Icon -> Activates inline search header within current screen
            if (!_isSearchActive)
              IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: TanizColors.textPrimary,
                ),
                onPressed: _activateSearch,
              ),
            // Top-Right Cart Icon with synchronized badge & fast non-blocking navigation
            Consumer<CartState>(
              builder: (context, cart, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: TanizColors.primaryBlue,
                      ),
                      onPressed: () => CartNavigation.openCart(context),
                    ),
                    if (cart.isNotEmpty)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: TanizColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.totalItemCount}',
                              style: const TextStyle(
                                color: TanizColors.primaryDeep,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // Left Column: Vertical Subcategory Rail (Reference Image 4)
              // -------------------------------------------------------------
              Container(
                width: 78,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    right: BorderSide(color: TanizColors.borderSubtle, width: 1),
                  ),
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _category.subcategories.length,
                  itemBuilder: (context, index) {
                    final subcat = _category.subcategories[index];
                    final isSelected = subcat == _selectedSubcategory;

                    return TanizTappable(
                      onTap: () {
                        setState(() {
                          _selectedSubcategory = subcat;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: isSelected
                              ? const Border(
                                  left: BorderSide(
                                    color: TanizColors.rapidGreenDark,
                                    width: 3.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? TanizColors.greenContainer
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? TanizColors.greenBorder
                                      : TanizColors.borderSubtle,
                                ),
                              ),
                              child: Center(
                                child: _buildSubcategoryIcon(subcat, isSelected),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subcat,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TanizTypography.caption.copyWith(
                                color: isSelected
                                    ? TanizColors.textPrimary
                                    : TanizColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                fontSize: 10,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // -------------------------------------------------------------
              // Right Column: Products Content Area
              // -------------------------------------------------------------
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Subcategory Name, Count & Sort Bar (Reference Image 4 & Issue 6)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                countText,
                                style: TanizTypography.bodySmall.copyWith(
                                  color: TanizColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sort Button
                            TanizTappable(
                              onTap: () => _showSortSheet(context),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: TanizColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: TanizColors.borderSubtle),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sort_rounded,
                                      size: 14,
                                      color: TanizColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedSort.label,
                                      style: TanizTypography.caption.copyWith(
                                        color: TanizColors.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
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

                    const SliverToBoxAdapter(
                      child: Divider(height: 1, color: TanizColors.borderSubtle),
                    ),

                    if (displayProducts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: TanizColors.surfaceLow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off_rounded
                                        : Icons.inventory_2_outlined,
                                    size: 28,
                                    color: TanizColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No products found'
                                      : 'No items in $activeLabel',
                                  style: TanizTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No items matching "$_searchQuery" in $activeLabel.'
                                      : 'Fresh stocks arriving soon at your warehouse.',
                                  textAlign: TextAlign.center,
                                  style: TanizTypography.caption.copyWith(
                                    color: TanizColors.textSecondary,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  TanizTappable(
                                    onTap: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                      _searchFocusNode.requestFocus();
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: TanizColors.blueContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Clear Search',
                                        style: TanizTypography.caption.copyWith(
                                          color: TanizColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      // 2-Column Product Grid (Image 4 Reference)
                      SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: Consumer<CartState>(
                          builder: (context, cart, _) {
                            return AnimationLimiter(
                              child: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.65,
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

                    // Extra bottom padding so last products can scroll freely into view
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 130),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // -----------------------------------------------------------------
          // Compact Floating View Cart Pill (Matching Image 5)
          // -----------------------------------------------------------------
          if (!isKeyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingCartBar(
                onViewCart: () => CartNavigation.openCart(context),
              ),
            ),
        ],
      ),
    ),
  );
  }

  Widget _buildSubcategoryIcon(String subcat, bool isSelected) {
    IconData icon;
    if (subcat == 'All') {
      icon = Icons.grid_view_rounded;
    } else if (subcat.contains('Milk') || subcat.contains('Curd') || subcat.contains('Dairy')) {
      icon = Icons.local_drink_rounded;
    } else if (subcat.contains('Egg')) {
      icon = Icons.egg_rounded;
    } else if (subcat.contains('Bread') || subcat.contains('Pav') || subcat.contains('Bakery')) {
      icon = Icons.bakery_dining_rounded;
    } else if (subcat.contains('Butter') || subcat.contains('Ghee') || subcat.contains('Oil')) {
      icon = Icons.opacity_rounded;
    } else if (subcat.contains('Fruit')) {
      icon = Icons.apple_rounded;
    } else if (subcat.contains('Veg') || subcat.contains('Herb')) {
      icon = Icons.eco_rounded;
    } else if (subcat.contains('Atta') || subcat.contains('Rice') || subcat.contains('Dal')) {
      icon = Icons.grain_rounded;
    } else if (subcat.contains('Snack') || subcat.contains('Chip')) {
      icon = Icons.fastfood_rounded;
    } else {
      icon = Icons.category_outlined;
    }

    return Icon(
      icon,
      size: 20,
      color: isSelected ? TanizColors.rapidGreenDark : TanizColors.textSecondary,
    );
  }
}
