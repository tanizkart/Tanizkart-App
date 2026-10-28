import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../state/cart_state.dart';
import '../../../state/navigation_state.dart';
import '../../listing/screens/product_listing_screen.dart';
import '../../cart/screens/cart_checkout_screen.dart';
import '../../detail/screens/product_detail_screen.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../search/screens/product_search_screen.dart';

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
  late final List<Product> _munchies;
  late final List<Product> _lightningDeals;

  String _selectedFilter = 'All';
  final List<String> _filterTabs = const ['All', 'Fruits', 'Vegetables', 'Snacks', 'Meat', 'Bakery'];

  // Showcase Cards matching the user's reference mockup
  final List<Map<String, dynamic>> _showcaseItems = const [
    {
      'id': 'showcase_snacks',
      'title': 'Tasty Snacks',
      'subtitle': 'Crispy, fresh, and ready to enjoy',
      'price': 99.0,
      'category': 'Snacks',
      'imageUrl': 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?auto=format&fit=crop&w=500&q=80',
      'emoji': '🍿',
      'productId': 'prod_lays_chips',
    },
    {
      'id': 'showcase_meat',
      'title': 'Quality Meat',
      'subtitle': 'Premium meat cuts, fresh and ready to cook',
      'price': 249.0,
      'category': 'Meat',
      'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=500&q=80',
      'emoji': '🥩',
      'productId': 'prod_farm_eggs',
    },
    {
      'id': 'showcase_veggies',
      'title': 'Garden Fresh',
      'subtitle': 'Healthy vegetables picked fresh every day',
      'price': 79.0,
      'category': 'Vegetables',
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=500&q=80',
      'emoji': '🥦',
      'productId': 'prod_fresh_tomato',
    },
    {
      'id': 'showcase_bakery',
      'title': 'Sweet Bakery',
      'subtitle': 'Delicious baked treats, fresh from our oven',
      'price': 129.0,
      'category': 'Bakery',
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=500&q=80',
      'emoji': '🍩',
      'productId': 'prod_britannia_bread',
    },
    {
      'id': 'showcase_seafood',
      'title': 'Fresh Seafood',
      'subtitle': 'Fresh seafood for delicious home-cooked meals',
      'price': 349.0,
      'category': 'Meat',
      'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=500&q=80',
      'emoji': '🐟',
      'productId': 'prod_farm_eggs',
    },
    {
      'id': 'showcase_fruits',
      'title': 'Fresh & Juicy',
      'subtitle': 'Fresh, juicy fruits for every occasion',
      'price': 149.0,
      'category': 'Fruits',
      'imageUrl': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?auto=format&fit=crop&w=500&q=80',
      'emoji': '🍎',
      'productId': 'prod_fresh_apple',
    },
  ];

  @override
  void initState() {
    super.initState();
    _categories = MockCategoryRepository.getAllCategories();
    _allProducts = MockProductRepository.getAllProducts();

    _bestsellers = _allProducts.where((p) => p.ratingCount >= 5000).toList();
    _freshProduce = _allProducts.where((p) => p.categoryId == 'cat_produce').toList();
    _munchies = _allProducts.where((p) => p.categoryId == 'cat_snacks' || p.categoryId == 'cat_instant').toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TanizColors.canvasBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Shaded Blurry Gradient Header (No leaves, realistic ambient blur, greeting, cart, search & circular categories)
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
                    onSearchTap: _navigateToAllProducts,
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

              // 6. 🌿 Fresh Fruits & Vegetables
              SliverToBoxAdapter(
                child: _buildProductSection(
                  title: 'Fresh Fruits & Veggies',
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

              // 7. 🍿 Munchies & Quick Bites
              SliverToBoxAdapter(
                child: _buildProductSection(
                  title: 'Munchies & Quick Bites',
                  badgeText: '🍿 10m Party',
                  badgeBg: const Color(0xFFFFF7ED),
                  badgeBorder: const Color(0xFFFED7AA),
                  badgeColor: const Color(0xFFC2410C),
                  products: _munchies,
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
          ),

          // 10. Glossy Liquid Glass Floating Cart Bar
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
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Container(
        color: const Color(0xFFF8FAFC),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0C831F)),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Text(
            fallbackEmoji ?? '🛒',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
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
