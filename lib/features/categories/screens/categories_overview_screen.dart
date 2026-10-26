import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/utils/cart_navigation.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../state/cart_state.dart';
import '../../detail/screens/product_detail_screen.dart';
import '../../listing/screens/product_listing_screen.dart';

class CategoriesOverviewScreen extends StatefulWidget {
  const CategoriesOverviewScreen({super.key});

  @override
  State<CategoriesOverviewScreen> createState() => _CategoriesOverviewScreenState();
}

class _CategoriesOverviewScreenState extends State<CategoriesOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isSearchActive = false;
  List<Product> _searchResults = [];
  int _searchRequestId = 0;
  double _savedScrollOffset = 0.0;

  final List<String> _popularSuggestions = [
    'Milk',
    'Farm Eggs',
    'Whole Wheat Bread',
    'Cow Ghee',
    'Greek Yogurt',
    'Sunflower Oil',
    'Chakki Atta',
    'Tomato',
    'Coconut',
    'Chips',
  ];

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
      _searchController.clear();
      _searchResults = [];
    });
    _restoreScrollPosition();
  }

  void _onSearchChanged(String query) {
    final clean = query.trim();
    final currentId = ++_searchRequestId;

    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      _restoreScrollPosition();
      return;
    }

    // Async query resolution with request-ID guard to prevent older responses from overwriting newer ones
    Future.microtask(() {
      if (currentId != _searchRequestId) return;
      final results = MockProductRepository.searchProducts(clean);
      if (mounted && currentId == _searchRequestId) {
        setState(() {
          _searchResults = results;
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

  List<String> _getMatchingSuggestions(String query) {
    if (query.trim().isEmpty) return const [];
    final q = query.trim().toLowerCase();
    final Set<String> matches = {};

    for (final term in _popularSuggestions) {
      if (term.toLowerCase().contains(q)) {
        matches.add(term);
      }
    }

    for (final product in MockProductRepository.getAllProducts()) {
      if (product.name.toLowerCase().contains(q)) {
        matches.add(product.name);
      } else if (product.brand.toLowerCase().contains(q)) {
        matches.add(product.brand);
      }
      if (matches.length >= 6) break;
    }

    return matches.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = MockCategoryRepository.getAllCategories();

    // Group categories matching Image 5 structure
    final groceryAndKitchen = allCategories.where((c) =>
      c.id == 'cat_produce' || c.id == 'cat_staples' || c.id == 'cat_dairy' || c.id == 'cat_instant'
    ).toList();

    final snacksAndDrinks = allCategories.where((c) =>
      c.id == 'cat_snacks' || c.id == 'cat_drinks'
    ).toList();

    final householdAndCare = allCategories.where((c) =>
      c.id == 'cat_cleaning' || c.id == 'cat_care'
    ).toList();

    final isQueryActive = _isSearchActive && _searchController.text.trim().isNotEmpty;
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
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Top Header with Live Inline Search Bar (Image 1 & Image 4 reference)
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFF3B0),
                          Color(0xFFFFFBEA),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Delivery Details (Visible in normal mode)
                            if (!_isSearchActive) ...[
                              Row(
                                children: [
                                  Text(
                                    'Fastest at your location! 🚀',
                                    style: TanizTypography.caption.copyWith(
                                      color: TanizColors.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Tanizkart in ',
                                            style: TanizTypography.titleMedium.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            '10 minutes',
                                            style: TanizTypography.titleMedium.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: TanizColors.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: TanizColors.blueContainer,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '1.2 km away',
                                              style: TanizTypography.caption.copyWith(
                                                color: TanizColors.primaryBlue,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      TanizTappable(
                                        onTap: () => AddressBottomSheet.show(context),
                                        child: Row(
                                          children: [
                                            Text(
                                              'HOME - Door No: 403, Devi sri APT',
                                              style: TanizTypography.labelSmall.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: TanizColors.textPrimary,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TanizTappable(
                                    onTap: () => CartNavigation.openCart(context),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: TanizColors.borderSubtle),
                                        boxShadow: [TanizColors.cardShadow],
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: TanizColors.primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Inline Search Field (Active in place on the same screen)
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isSearchActive
                                      ? TanizColors.primaryBlue
                                      : TanizColors.borderSubtle,
                                  width: _isSearchActive ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (_isSearchActive)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: TanizColors.textPrimary,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: _closeSearch,
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4, right: 6),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: TanizColors.primaryBlue,
                                        size: 22,
                                      ),
                                    ),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      onTap: _activateSearch,
                                      onChanged: (text) {
                                        if (!_isSearchActive) {
                                          setState(() => _isSearchActive = true);
                                        }
                                        _onSearchChanged(text);
                                      },
                                      style: TanizTypography.bodyMedium.copyWith(
                                        color: TanizColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search for atta, dal, milk and more',
                                        hintStyle: TanizTypography.bodyMedium.copyWith(
                                          color: TanizColors.textMuted,
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: TanizColors.textMuted),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                        _searchFocusNode.requestFocus();
                                      },
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.mic_none_rounded,
                                        color: TanizColors.textSecondary,
                                        size: 20,
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
                ),

                // -------------------------------------------------------------
                // Content Body: Inline Search Results OR Normal Categories Grid
                // -------------------------------------------------------------
                if (isQueryActive) ...[
                  // Suggestions Row (Reference Image 4)
                  Builder(
                    builder: (context) {
                      final matchingSuggestions = _getMatchingSuggestions(_searchController.text);
                      if (matchingSuggestions.isEmpty) {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.search_rounded, size: 14, color: TanizColors.primaryBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Suggestions',
                                    style: TanizTypography.caption.copyWith(
                                      color: TanizColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: matchingSuggestions.map((s) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: TanizTappable(
                                        onTap: () {
                                          _searchController.text = s;
                                          _onSearchChanged(s);
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: TanizColors.surfaceLow,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: TanizColors.borderSubtle),
                                          ),
                                          child: Text(
                                            s,
                                            style: TanizTypography.caption.copyWith(
                                              color: TanizColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Divider(height: 1, color: TanizColors.borderSubtle),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Case B: Query is active and no results found
                  if (_searchResults.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: TanizColors.surfaceLow,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: TanizColors.borderSubtle),
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: TanizColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TanizTypography.titleLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TanizColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No items matching "${_searchController.text.trim()}". Try checking spelling or search items like milk, bread or eggs.',
                                textAlign: TextAlign.center,
                                style: TanizTypography.bodyMedium.copyWith(
                                  color: TanizColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TanizTappable(
                                onTap: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  _searchFocusNode.requestFocus();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: TanizColors.blueContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Clear Search',
                                    style: TanizTypography.labelLarge.copyWith(
                                      color: TanizColors.primaryBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Case C: Query has matching products -> 2-Column Product Grid
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          '${_searchResults.length} ${_searchResults.length == 1 ? 'item' : 'items'} found for "${_searchController.text.trim()}"',
                          style: TanizTypography.bodySmall.copyWith(
                            color: TanizColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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
                                  final product = _searchResults[index];
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
                                childCount: _searchResults.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ] else ...[
                  // -----------------------------------------------------------
                  // Normal Categories Overview (Image 1 / Image 5 Reference)
                  // Shown when query is empty, cleared, or search is closed.
                  // -----------------------------------------------------------
                  if (_isSearchActive)
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trending_up_rounded, size: 14, color: TanizColors.primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'Popular Searches',
                                  style: TanizTypography.caption.copyWith(
                                    color: TanizColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _popularSuggestions.map((term) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: TanizTappable(
                                      onTap: () {
                                        _searchController.text = term;
                                        _onSearchChanged(term);
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: TanizColors.surfaceLow,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: TanizColors.borderSubtle),
                                        ),
                                        child: Text(
                                          term,
                                          style: TanizTypography.caption.copyWith(
                                            color: TanizColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Divider(height: 1, color: TanizColors.borderSubtle),
                          ],
                        ),
                      ),
                    ),
                  // Tapping any category tile opens its category product listing!
                  // -----------------------------------------------------------

                  // Section 1: Grocery & Kitchen
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Grocery & Kitchen',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: TanizColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = groceryAndKitchen[index];
                          return _buildCategoryGridTile(context, category);
                        },
                        childCount: groceryAndKitchen.length,
                      ),
                    ),
                  ),

                  // Section 2: Snacks & Drinks
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        'Snacks & Drinks',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: TanizColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = snacksAndDrinks[index];
                          return _buildCategoryGridTile(context, category);
                        },
                        childCount: snacksAndDrinks.length,
                      ),
                    ),
                  ),

                  // Section 3: Household & Personal Care
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Text(
                        'Household & Personal Care',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: TanizColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = householdAndCare[index];
                          return _buildCategoryGridTile(context, category);
                        },
                        childCount: householdAndCare.length,
                      ),
                    ),
                  ),
                ],

                // Extra bottom padding for floating cart pill
                const SliverToBoxAdapter(
                  child: SizedBox(height: 130),
                ),
              ],
            ),

            // Compact Floating View Cart Pill (Matching Image 5)
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

  Widget _buildCategoryGridTile(BuildContext context, Category category) {
    return TanizTappable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(selectedCategory: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      scaleTo: 0.95,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(category.backgroundColorValue).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(category.backgroundColorValue),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: category.iconUrl,
                    fit: BoxFit.contain,
                    placeholder: (c, u) => Container(color: Colors.white.withValues(alpha: 0.5)),
                    errorWidget: (c, u, e) => const Icon(
                      Icons.category_rounded,
                      color: TanizColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TanizTypography.caption.copyWith(
              color: TanizColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
