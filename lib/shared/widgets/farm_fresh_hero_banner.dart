import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';

/// 3 Premium Watermark-Free Commercial Product Banners Carousel
/// Features:
/// 1. Fresh Farm Produce (Vegetables, Fruits, Direct from Andhra Farms)
/// 2. Artisan Dairy & Bakery (Cold Fresh Milk, Sourdough Bread, Butter, Cheese)
/// 3. Gourmet Snacks & Beverages (Cold-Pressed Smoothies, Artisan Popcorn, Nuts)
/// Full-bleed photography, subtle readability vignette, elegant typography, Shop Now CTA, exactly 3 dots.
class FarmFreshHeroBanner extends StatefulWidget {
  final VoidCallback onShopNow;

  const FarmFreshHeroBanner({
    super.key,
    required this.onShopNow,
  });

  @override
  State<FarmFreshHeroBanner> createState() => _FarmFreshHeroBannerState();
}

class _FarmFreshHeroBannerState extends State<FarmFreshHeroBanner> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isInteracting = false;

  final List<Map<String, dynamic>> _campaigns = const [
    {
      'title': 'Fresh Finds at\nYour Fingertips',
      'subtitle': 'Farm-picked vegetables & fruits in 10 mins',
      'badge': '100% FARM FRESH',
      'cta': 'Shop Produce',
      'image': 'assets/banner_fresh_produce.jpg',
      'badgeColor': Color(0xFF0C831F),
    },
    {
      'title': 'Morning Pure Dairy\n& Artisan Bakery',
      'subtitle': 'Cold farm milk, sourdough bread & butter',
      'badge': 'DAILY MORNING',
      'cta': 'Shop Dairy',
      'image': 'assets/banner_dairy_breakfast.jpg',
      'badgeColor': Color(0xFFB45309),
    },
    {
      'title': 'Gourmet Treats,\nSmoothies & Snacks',
      'subtitle': 'Artisan popcorn, cold smoothies & chocolates',
      'badge': 'PARTY & CRAVINGS',
      'cta': 'Order Snacks',
      'image': 'assets/banner_snacks_beverages.jpg',
      'badgeColor': Color(0xFFC026D3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_isInteracting && mounted) {
        final nextPage = (_currentPage + 1) % _campaigns.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          height: 195,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // PageView for the 3 Banners
                Listener(
                  onPointerDown: (_) => _isInteracting = true,
                  onPointerUp: (_) => _isInteracting = false,
                  onPointerCancel: (_) => _isInteracting = false,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _campaigns.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _campaigns[index];
                      return _buildSlide(item);
                    },
                  ),
                ),

                // Top Left: Sleek translucent pill badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _campaigns[_currentPage]['badge'] as String,
                      style: TanizTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Bottom Left: Headline & Shop Now CTA
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _campaigns[_currentPage]['title'] as String,
                              style: TanizTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                height: 1.15,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _campaigns[_currentPage]['subtitle'] as String,
                              style: TanizTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Glassy Shop Now Button
                      TanizTappable(
                        onTap: widget.onShopNow,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _campaigns[_currentPage]['cta'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Color(0xFF0F172A),
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
        ),

        // Exactly 3 Dot Indicators
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _campaigns.length,
              (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(Map<String, dynamic> item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full Bleed Commercial Photography Banner
        Image.asset(
          item['image'] as String,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF1E293B),
            child: const Center(
              child: Icon(Icons.shopping_bag_outlined, color: Colors.white54, size: 40),
            ),
          ),
        ),

        // Gradient Vignette for Readability (No split half colors)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
