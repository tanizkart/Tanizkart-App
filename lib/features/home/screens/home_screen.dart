import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/mock_category_repository.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/taniz_leafy_header.dart';
import '../../../shared/widgets/farm_fresh_hero_banner.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/lightning_countdown_badge.dart';
import '../../../shared/widgets/taniz_image.dart';
import '../../../state/cart_state.dart';
import '../../../state/navigation_state.dart';
import '../../listing/screens/product_listing_screen.dart';
import '../../detail/screens/product_detail_screen.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../../core/utils/cart_navigation.dart';

/// Classy & High-End Home Screen for Tanizkart
/// Designed to match the modern iOS reference design:
/// - Shaded blurry ambient gradient header without leaves
/// - 3 Watermark-Free Commercial Product Banners
/// - "Smart Combo Picks" Asymmetric Bento Showcase (Fruit Pack + Combos + Daily Picks)
/// - Interactive Category Filter Tabs (All, Fruits, Vegetables, Snacks, Meat, Bakery)
/// - 2-Column Classy Showcase Grid with instant Add-to-Cart
/// - Curated Express Shelves & Delivery Assurance Footer
/// - Liquid Glossy Glass Floating Cart Bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Category> _categories;
  late final List<Product> _allProducts;
  late final List<Product> _bestsellers;
  late final List<Product> _freshProduce;
  late final List<Product> _dairyProducts;
  late final List<Product> _groceries;
  late final List<Product> _lightningDeals;

  String _selectedFilter = 'All';
  final List<String> _filterTabs = const [
    'All',
    'Baby care',
    'Personal care',
    'Groceries',
    'Home essentials',
    'Dairy',
    'Vegetables',
  ];

  // Inline Search State
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<Product> _searchResults = [];
  Timer? _searchDebounceTimer;
  int _searchRequestId = 0;

  static const List<String> _searchSuggestions = [
    'Milk',
    'Butter',
    'Eggs',
    'Bread',
    'Atta',
    'Chips',
    'Cola',
    'Tomato',
    'Apple',
    'Paneer',
    'Rice',
    'Ghee',
  ];

  // Showcase Cards matching the 6 main categories
  final List<Map<String, dynamic>> _showcaseItems = const [
    {
      'id': 'showcase_veggies',
      'title': 'Garden Fresh',
      'subtitle': 'Healthy vegetables picked fresh every day',
      'price': 38.0,
      'category': 'Vegetables',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=500&q=80',
      'emoji': '🥦',
      'productId': 'prod_tomato',
    },
    {
      'id': 'showcase_dairy',
      'title': 'Dairy Fresh',
      'subtitle': 'Pure butter, rich milk & farm eggs',
      'price': 58.0,
      'category': 'Dairy',
      'imageUrl': 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=500&q=80',
      'emoji': '🧈',
      'productId': 'prod_amul_butter',
    },
    {
      'id': 'showcase_groceries',
      'title': 'Chakki Atta',
      'subtitle': '100% whole wheat grains from MP fields',
      'price': 245.0,
      'category': 'Groceries',
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=500&q=80',
      'emoji': '🌾',
      'productId': 'prod_aashirvaad_atta',
    },
    {
      'id': 'showcase_baby_care',
      'title': 'Baby Dry Pants',
      'subtitle': 'Aloe vera gentle anti-rash protection',
      'price': 549.0,
      'category': 'Baby care',
      'imageUrl': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=500&q=80',
      'emoji': '👶',
      'productId': 'prod_pampers_pants',
    },
    {
      'id': 'showcase_personal_care',
      'title': 'Deep Moisture',
      'subtitle': 'Dove nourishing body wash for soft skin',
      'price': 199.0,
      'category': 'Personal care',
      'imageUrl': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=500&q=80',
      'emoji': '🧴',
      'productId': 'prod_dove_bodywash',
    },
    {
      'id': 'showcase_home_essentials',
      'title': 'Floor & Surface',
      'subtitle': 'Lizol citrus fresh germ protection',
      'price': 185.0,
      'category': 'Home essentials',
      'imageUrl': 'https://images.unsplash.com/photo-1585421514738-01798e348b17?auto=format&fit=crop&w=500&q=80',
      'emoji': '🧼',
      'productId': 'prod_lizol_cleaner',
    },
  ];

  @override
  void initState() {
    super.initState();
    _categories = MockCategoryRepository.getAllCategories();
    _allProducts = MockProductRepository.getAllProducts();

    _bestsellers = _allProducts.where((p) => p.ratingCount >= 10000).toList();
    _freshProduce = _allProducts.where((p) => p.categoryId == 'cat_vegetables').toList();
    _dairyProducts = _allProducts.where((p) => p.categoryId == 'cat_dairy').toList();
    _groceries = _allProducts.where((p) => p.categoryId == 'cat_groceries').toList();
    _lightningDeals = _allProducts.where((p) => p.discountPercent >= 15).toList();
  }

  void _navigateToCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListingScreen(selectedCategory: category),
      ),
    );
  }

  void _navigateToAllProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductListingScreen(),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _addShowcaseItemToCart(Map<String, dynamic> item) {
    final cart = Provider.of<CartState>(context, listen: false);
    final prodId = item['productId'] as String?;
    final existing = _allProducts.firstWhere(
      (p) => p.id == prodId,
      orElse: () => _allProducts.first,
    );

    // Create a personalized product representation matching the showcase card
    final showcaseProduct = Product(
      id: item['id'] as String,
      name: item['title'] as String,
      brand: 'TANIZ SELECT',
      packSize: 'Special Bundle',
      price: (item['price'] as num).toDouble(),
      originalPrice: (item['price'] as num).toDouble() * 1.25,
      discountPercent: 20,
      imageUrl: item['imageUrl'] as String,
      categoryId: existing.categoryId,
      subcategory: item['category'] as String,
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 1840,
      description: item['subtitle'] as String,
    );

    cart.addItem(showcaseProduct);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item['emoji'] as String? ?? '🛒', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '${item['title']} added to your basket!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0C831F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addFruitPackToCart() {
    final cart = Provider.of<CartState>(context, listen: false);
    final fruitPack = Product(
      id: 'combo_fruit_pack',
      name: 'Smart Fruit Pack (Apple + Lime + Strawberry)',
      brand: 'TANIZ FRESH',
      packSize: '3-in-1 Combo Box',
      price: 149.0,
      originalPrice: 199.0,
      discountPercent: 25,
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=500&q=80',
      categoryId: 'cat_produce',
      subcategory: 'Fresh Combos',
      deliveryTimeMins: 10,
      rating: 4.9,
      ratingCount: 3200,
      description: 'Handpicked fresh crisp apples, zesty limes, and sweet juicy farm strawberries.',
    );
    cart.addItem(fruitPack);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🍓', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'Smart Fruit Pack added to cart!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0C831F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _activateSearch() {
    if (!_isSearchActive) {
      setState(() {
        _isSearchActive = true;
      });
    }
    _searchFocusNode.requestFocus();
  }

  void _closeSearch() {
    _searchDebounceTimer?.cancel();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchActive = false;
      _searchQuery = '';
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
    _searchFocusNode.requestFocus();
  }

  void _onSearchChanged(String query) {
    final clean = query.trim();
    _searchDebounceTimer?.cancel();
    final currentId = ++_searchRequestId;

    if (clean.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults = [];
      });
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (currentId != _searchRequestId) return;
      if (!mounted) return;

      final results = MockProductRepository.searchProducts(clean);
      setState(() {
        _searchQuery = clean;
        _searchResults = results;
      });
    });
  }

  List<Widget> _buildInlineSearchResults() {
    final cart = Provider.of<CartState>(context);
    final count = _searchResults.length;

    return [
      // Quick search suggestions chips
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: TanizColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    'Popular Searches',
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _searchSuggestions.map((s) {
                    final isCurrent = _searchQuery.toLowerCase() == s.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TanizTappable(
                        onTap: () {
                          _searchController.text = s;
                          _onSearchChanged(s);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isCurrent ? TanizColors.primaryBlue : TanizColors.surfaceLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrent ? TanizColors.primaryBlue : TanizColors.borderSubtle,
                            ),
                          ),
                          child: Text(
                            s,
                            style: TanizTypography.caption.copyWith(
                              color: isCurrent ? Colors.white : TanizColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // Header result count bar
      if (_searchQuery.isNotEmpty)
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: TanizColors.canvasBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count > 0
                      ? 'Showing $count ${count == 1 ? 'result' : 'results'} for "$_searchQuery"'
                      : 'No results for "$_searchQuery"',
                  style: TanizTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TanizColors.textPrimary,
                    fontSize: 12.5,
                  ),
                ),
                TanizTappable(
                  onTap: _closeSearch,
                  child: Text(
                    'Exit Search',
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      // Empty State or Product Grid
      if (_searchQuery.isNotEmpty && _searchResults.isEmpty)
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
                    decoration: const BoxDecoration(
                      color: TanizColors.surfaceLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 34,
                      color: TanizColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TanizTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We couldn\'t find any items matching "$_searchQuery".\nTry checking the spelling or searching another item.',
                    textAlign: TextAlign.center,
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TanizTappable(
                    onTap: _clearSearch,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: TanizColors.blueContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Clear Search',
                        style: TanizTypography.labelLarge.copyWith(
                          color: TanizColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else if (_searchResults.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _searchResults[index];
                return ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  quantity: cart.getQuantity(product.id),
                  onTap: () => _navigateToProductDetail(product),
                  onAdd: () => cart.addItem(product),
                  onIncrement: () => cart.addItem(product),
                  onDecrement: () => cart.removeItem(product),
                );
              },
              childCount: _searchResults.length,
            ),
          ),
        )
      else
        // Search is active but no query typed yet -> show popular items
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _allProducts[index];
                return ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  quantity: cart.getQuantity(product.id),
                  onTap: () => _navigateToProductDetail(product),
                  onAdd: () => cart.addItem(product),
                  onIncrement: () => cart.addItem(product),
                  onDecrement: () => cart.removeItem(product),
                );
              },
              childCount: _allProducts.length.clamp(0, 8),
            ),
          ),
        ),

      const SliverToBoxAdapter(
        child: SizedBox(height: 130),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Shaded Blurry Gradient Header with live inline search
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: TanizLeafyHeader(
                      onProfileTap: () {
                        Provider.of<NavigationState>(context, listen: false).setIndex(3);
                      },
                      onNotificationTap: () {},
                      onLocationTap: () {
                        AddressBottomSheet.show(context);
                      },
                      isSearchActive: _isSearchActive,
                      searchController: _searchController,
                      searchFocusNode: _searchFocusNode,
                      onSearchTap: _activateSearch,
                      onSearchChanged: _onSearchChanged,
                      onSearchClear: _clearSearch,
                      onSearchClose: _closeSearch,
                      onCategoryTap: (categoryName) {
                        final match = _categories.firstWhere(
                          (c) => c.name.toLowerCase().contains(categoryName.toLowerCase()),
                          orElse: () => _categories.first,
                        );
                        _navigateToCategory(match);
                      },
                    ),
                  ),
                ),

                if (_isSearchActive)
                  ..._buildInlineSearchResults()
                else ...[
                  // 2. Exactly 3 Full-Bleed Watermark-Free Product Banners (Auto-playing with 3 dots)
                  SliverToBoxAdapter(
                    child: FarmFreshHeroBanner(
                      onShopNow: _navigateToAllProducts,
                    ),
                  ),

                  // 3. "Smart Combo Picks" Asymmetric Bento Layout (From Reference Image 1)
                  SliverToBoxAdapter(
                    child: _buildSmartComboPicksSection(),
                  ),

                  // 4. Category Filter Tabs & 2-Column Classy Showcase Grid (From Reference Image 2)
                  SliverToBoxAdapter(
                    child: _buildCategoryFilterShowcaseSection(),
                  ),

                  // 5. ⚡ Bestsellers in 10 Mins (Express)
                  SliverToBoxAdapter(
                    child: _buildProductSection(
                      title: 'Bestsellers in 10m',
                      badgeText: '⚡ Express',
                      badgeBg: const Color(0xFFDCFCE7),
                      badgeBorder: const Color(0xFF86EFAC),
                      badgeColor: const Color(0xFF166534),
                      products: _bestsellers,
                    ),
                  ),

                  // 6. 🥦 Fresh Vegetables
                  SliverToBoxAdapter(
                    child: _buildProductSection(
                      title: 'Fresh Vegetables',
                      badgeText: '🥦 Farm Direct',
                      badgeBg: const Color(0xFFECFDF5),
                      badgeBorder: const Color(0xFFA7F3D0),
                      badgeColor: const Color(0xFF047857),
                      products: _freshProduce,
                    ),
                  ),

                  // 6. ⚡ Lightning Rush Deals (if any)
                  if (_lightningDeals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildLightningRushSection(),
                    ),

                  // 7. 🥛 Pure Dairy & Eggs
                  SliverToBoxAdapter(
                    child: _buildProductSection(
                      title: 'Pure Dairy & Eggs',
                      badgeText: '🥛 Farm Fresh',
                      badgeBg: const Color(0xFFEFF6FF),
                      badgeBorder: const Color(0xFFBFDBFE),
                      badgeColor: const Color(0xFF1D4ED8),
                      products: _dairyProducts,
                    ),
                  ),

                  // 8. 🌾 Kitchen Groceries & Staples
                  SliverToBoxAdapter(
                    child: _buildProductSection(
                      title: 'Kitchen Groceries',
                      badgeText: '🌾 Wholesale',
                      badgeBg: const Color(0xFFFEF9C3),
                      badgeBorder: const Color(0xFFFDE047),
                      badgeColor: const Color(0xFF854D0E),
                      products: _groceries,
                    ),
                  ),

                  // 8. Popular Brands Spotlight
                  SliverToBoxAdapter(
                    child: _buildBrandsSpotlight(),
                  ),

                  // 9. Quick-Commerce Assurance Footer
                  SliverToBoxAdapter(
                    child: _buildQuickCommerceFooter(),
                  ),

                  // Clearance for Floating Cart Bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ],
            ),

            // 10. Glossy Liquid Glass Floating Cart Bar
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

  // ---------------------------------------------------------------------------
  // 1. SMART COMBO PICKS ASYMMETRIC BENTO UI (Reference Screen 1)
  // ---------------------------------------------------------------------------
  Widget _buildSmartComboPicksSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smart Combo Picks',
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 10)),
                    SizedBox(width: 3),
                    Text(
                      'Up to 40% OFF',
                      style: TextStyle(
                        color: Color(0xFF6D28D9),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Asymmetric Bento Grid
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT: Tall "Fruit Pack" Card
                Expanded(
                  flex: 11,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF), // Soft Lilac
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE9D5FF).withValues(alpha: 0.6),
                          blurRadius: 12,
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
                            Text(
                              'Fruit Pack',
                              style: TanizTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '3-in-1',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7E22CE),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Inner items list container
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFruitPackItem('🍎', 'Apple', 'Fresh, crisp, sweet'),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                _buildFruitPackItem('🍋', 'Lime', 'Zesty, juicy, tangy'),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                _buildFruitPackItem('🍓', 'Strawberry', 'Sweet, soft, fresh'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Price & Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹149',
                                  style: TanizTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '₹199',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            TanizTappable(
                              onTap: _addFruitPackToCart,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C831F),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0C831F).withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 2),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // RIGHT COLUMN: 2 Small Top Cards + 1 Wide Bottom Card
                Expanded(
                  flex: 13,
                  child: Column(
                    children: [
                      // Top Row: "Top Combo" & "Seafood"
                      Row(
                        children: [
                          // Top Combo
                          Expanded(
                            child: _buildBentoSmallCard(
                              title: 'Top Combo',
                              price: '₹199',
                              discount: '40% OFF',
                              imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80',
                              emoji: '🧺',
                              onAdd: () {
                                _addShowcaseItemToCart({
                                  'id': 'combo_top_groceries',
                                  'title': 'Top Grocery Combo',
                                  'subtitle': 'Curated daily essentials pack',
                                  'price': 199.0,
                                  'category': 'Combos',
                                  'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80',
                                  'emoji': '🧺',
                                  'productId': 'prod_aashirvaad_atta',
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Seafood
                          Expanded(
                            child: _buildBentoSmallCard(
                              title: 'Seafood',
                              price: '₹299',
                              discount: '20% OFF',
                              imageUrl: 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=400&q=80',
                              emoji: '🦐',
                              onAdd: () {
                                _addShowcaseItemToCart({
                                  'id': 'combo_seafood_catch',
                                  'title': 'Fresh Seafood Catch',
                                  'subtitle': 'Sub-4°C cleaned fish & prawns',
                                  'price': 299.0,
                                  'category': 'Meat',
                                  'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=400&q=80',
                                  'emoji': '🦐',
                                  'productId': 'prod_farm_eggs',
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Bottom Card: "Fresh Daily Picks" (Wide)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Fresh Daily Picks',
                                      style: TanizTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Fresh fruits, veggies, meat & eggs',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '₹399',
                                          style: TanizTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TanizTappable(
                                          onTap: () {
                                            _addShowcaseItemToCart({
                                              'id': 'combo_fresh_daily_picks',
                                              'title': 'Fresh Daily Picks Box',
                                              'subtitle': 'Fresh fruits, veggies, meat & eggs',
                                              'price': 399.0,
                                              'category': 'Produce',
                                              'imageUrl': 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=400&q=80',
                                              'emoji': '🥗',
                                              'productId': 'prod_fresh_spinach',
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0C831F),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Visual thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: _buildResilientImage(
                                    'https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=400&q=80',
                                    fallbackEmoji: '🥗',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitPackItem(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoSmallCard({
    required String title,
    required String price,
    required String discount,
    required String imageUrl,
    required String emoji,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 48,
                width: 58,
                child: _buildResilientImage(imageUrl, fallbackEmoji: emoji),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              TanizTappable(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C831F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. CATEGORY FILTER TABS & 2-COLUMN SHOWCASE GRID (Reference Screen 2)
  // ---------------------------------------------------------------------------
  Widget _buildCategoryFilterShowcaseSection() {
    final filtered = _selectedFilter == 'All'
        ? _showcaseItems
        : _showcaseItems.where((i) => (i['category'] as String).toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs (All, Fruits, Vegetables, Snacks, Meat, Bakery)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filterTabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _filterTabs[index];
                final isSelected = tab == _selectedFilter;

                return TanizTappable(
                  onTap: () {
                    setState(() {
                      _selectedFilter = tab;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 2-Column Responsive Showcase Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filtered.map((item) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildClassyShowcaseCard(item),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassyShowcaseCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final subtitle = item['subtitle'] as String;
    final price = item['price'] as double;
    final imageUrl = item['imageUrl'] as String;
    final emoji = item['emoji'] as String? ?? '🛒';

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TanizTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Product Image & Price + Add Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Price & Add Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${price.toInt()}',
                    style: TanizTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TanizTappable(
                    onTap: () => _addShowcaseItemToCart(item),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C831F),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C831F).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 2),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // High-Res Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 66,
                  height: 66,
                  child: _buildResilientImage(imageUrl, fallbackEmoji: emoji),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. RESILIENT NETWORK IMAGE BUILDER (100% Guaranteed Load & Fallback)
  // ---------------------------------------------------------------------------
  Widget _buildResilientImage(String url, {String? fallbackEmoji, BoxFit fit = BoxFit.cover}) {
    return TanizImage(
      imageUrl: url,
      fit: fit,
      fallbackEmoji: fallbackEmoji ?? '🛒',
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CURATED GROCERY SHELVES
  // ---------------------------------------------------------------------------
  Widget _buildProductSection({
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeBorder,
    required Color badgeColor,
    required List<Product> products,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: badgeBorder),
                      ),
                      child: Text(
                        badgeText,
                        style: TanizTypography.caption.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TanizTappable(
                onTap: _navigateToAllProducts,
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TanizTypography.labelMedium.copyWith(
                        color: TanizColors.royalBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: TanizColors.royalBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Product Cards Carousel
        SizedBox(
          height: 258,
          child: Consumer<CartState>(
            builder: (context, cart, _) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    width: 164,
                    product: product,
                    quantity: cart.getQuantity(product.id),
                    onTap: () => _navigateToProductDetail(product),
                    onAdd: () => cart.addItem(product),
                    onIncrement: () => cart.addItem(product),
                    onDecrement: () => cart.removeItem(product),
                    heroTag: '${title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${product.id}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLightningRushSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '⚡ Lightning Deals',
                    style: TanizTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LightningCountdownBadge(
                    initialSeconds: 2 * 3600 + 45 * 60,
                  ),
                ],
              ),
              TanizTappable(
                onTap: _navigateToAllProducts,
                child: Text(
                  'View All',
                  style: TanizTypography.labelMedium.copyWith(
                    color: TanizColors.royalBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 258,
          child: Consumer<CartState>(
            builder: (context, cart, _) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _lightningDeals.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = _lightningDeals[index];
                  return ProductCard(
                    width: 164,
                    product: product,
                    quantity: cart.getQuantity(product.id),
                    onTap: () => _navigateToProductDetail(product),
                    onAdd: () => cart.addItem(product),
                    onIncrement: () => cart.addItem(product),
                    onDecrement: () => cart.removeItem(product),
                    heroTag: 'deal_${product.id}',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsSpotlight() {
    const brands = [
      {'name': 'Amul', 'desc': 'The Taste of India', 'color': Color(0xFFEFF6FF), 'border': Color(0xFFBFDBFE)},
      {'name': 'Aashirvaad', 'desc': 'Pure Whole Wheat', 'color': Color(0xFFFEF9C3), 'border': Color(0xFFFDE047)},
      {'name': 'Cadbury', 'desc': 'Real Dairy Milk', 'color': Color(0xFFFCE7F3), 'border': Color(0xFFFBCFE8)},
      {'name': 'Britannia', 'desc': 'Eat Healthy, Think Better', 'color': Color(0xFFECFDF5), 'border': Color(0xFFA7F3D0)},
      {'name': 'Tata Tea', 'desc': 'Desh Ki Chai', 'color': Color(0xFFFFF7ED), 'border': Color(0xFFFED7AA)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Brand',
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
              TanizTappable(
                onTap: _navigateToAllProducts,
                child: Text(
                  'Explore All',
                  style: TanizTypography.labelMedium.copyWith(
                    color: TanizColors.royalBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: brands.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final b = brands[index];
              return TanizTappable(
                onTap: _navigateToAllProducts,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: b['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: b['border'] as Color, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        b['name'] as String,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b['desc'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCommerceFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanizkart Superfast Delivery',
                        style: TanizTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '10-15 Min Express Delivery across Lawyerpet & Ongole',
                        style: TanizTypography.caption.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrustIcon('🌿', '100% Fresh'),
                _buildTrustIcon('🛡️', 'Instant Refund'),
                _buildTrustIcon('❄️', 'Sub-4°C Chain'),
                _buildTrustIcon('₹', 'Best Price'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustIcon(String emoji, String text) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
