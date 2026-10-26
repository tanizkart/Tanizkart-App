import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/utils/cart_navigation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../state/cart_state.dart';
import '../../detail/screens/product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const ProductSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  List<Product> _results = [];
  bool _hasSearched = false;

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
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();

    if (_controller.text.isNotEmpty) {
      _performSearch(_controller.text);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      final clean = query.trim();
      if (clean.isEmpty) {
        _results = [];
        _hasSearched = false;
      } else {
        _results = MockProductRepository.searchProducts(clean);
        _hasSearched = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TanizColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: TanizColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TanizColors.borderSubtle),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  color: TanizColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: _performSearch,
                    onSubmitted: _performSearch,
                    style: TanizTypography.bodyMedium.copyWith(
                      color: TanizColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for milk, eggs, atta, snacks...',
                      hintStyle: TanizTypography.bodyMedium.copyWith(
                        color: TanizColors.textMuted,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: TanizColors.textMuted),
                    onPressed: () {
                      _controller.clear();
                      _performSearch('');
                      _focusNode.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (!_hasSearched || _controller.text.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Searches',
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: TanizColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _popularSuggestions.map((term) {
                            return TanizTappable(
                              onTap: () {
                                _controller.text = term;
                                _performSearch(term);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: TanizColors.borderSubtle),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      size: 16,
                                      color: TanizColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      term,
                                      style: TanizTypography.bodySmall.copyWith(
                                        color: TanizColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: TanizColors.surfaceLow,
                              shape: BoxShape.circle,
                              border: Border.all(color: TanizColors.borderSubtle),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 40,
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
                          const SizedBox(height: 8),
                          Text(
                            'We couldn\'t find anything matching "${_controller.text}". Try checking for spelling or search general items like milk, eggs or atta.',
                            textAlign: TextAlign.center,
                            style: TanizTypography.bodyMedium.copyWith(
                              color: TanizColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TanizTappable(
                            onTap: () {
                              _controller.clear();
                              _performSearch('');
                              _focusNode.requestFocus();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      '${_results.length} ${_results.length == 1 ? 'item' : 'items'} found for "${_controller.text}"',
                      style: TanizTypography.bodySmall.copyWith(
                        color: TanizColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
                              final product = _results[index];
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
                            childCount: _results.length,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 130),
                ),
              ],
            ],
          ),

          // Floating Cart Bar (Compact pill)
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
    );
  }
}
