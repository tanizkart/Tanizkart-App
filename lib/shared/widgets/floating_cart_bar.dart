import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/utils/currency_formatter.dart';
import '../../state/cart_state.dart';

/// Ultra-Modern Liquid Floating Cart Bar
/// Features authentic liquid glassmorphism (frosted backdrop blur, specular gloss highlights),
/// an animated flowing liquid sheen across the CTA, spring-scaled item counters,
/// and quick-commerce delivery speed badges.
class FloatingCartBar extends StatefulWidget {
  final VoidCallback onViewCart;

  const FloatingCartBar({
    super.key,
    required this.onViewCart,
  });

  @override
  State<FloatingCartBar> createState() => _FloatingCartBarState();
}

class _FloatingCartBarState extends State<FloatingCartBar> with SingleTickerProviderStateMixin {
  late final AnimationController _liquidController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _liquidController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cart, child) {
        if (cart.isEmpty) return const SizedBox.shrink();

        final distinct = cart.distinctProducts;
        final previewItems = distinct.take(3).toList();

        return AnimatedSlide(
          offset: cart.isEmpty ? const Offset(0, 1.2) : Offset.zero,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: TanizTappable(
                onTap: widget.onViewCart,
                scaleTo: 0.98,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      // Liquid Deep Glow (Emerald & Midnight Tint)
                      BoxShadow(
                        color: const Color(0xFF0C831F).withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                        decoration: BoxDecoration(
                          // Liquid Translucent Frosted Glass
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.95),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // 1. Overlapping Circular Product Thumbnails
                            if (previewItems.isNotEmpty)
                              SizedBox(
                                width: previewItems.length == 1
                                    ? 40
                                    : 40 + (previewItems.length - 1) * 22.0,
                                height: 40,
                                child: Stack(
                                  children: List.generate(previewItems.length, (index) {
                                    return Positioned(
                                      left: index * 22.0,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.12),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: previewItems[index].imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (c, u) => const TanizShimmerBox(
                                              width: 40,
                                              height: 40,
                                              borderRadius: 20,
                                            ),
                                            errorWidget: (c, u, e) => const Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 20,
                                              color: Color(0xFF0C831F),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            const SizedBox(width: 12),

                            // 2. Center Info: Total Price, Item Count & 10m SLA
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(cart.subtotal),
                                        style: TanizTypography.titleMedium.copyWith(
                                          color: const Color(0xFF0F172A),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('⚡', style: TextStyle(fontSize: 10)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '10m',
                                              style: TanizTypography.caption.copyWith(
                                                color: const Color(0xFF166534),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'} in basket',
                                    style: TanizTypography.caption.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3. Right: Authentic GLOSSY LIQUID GLASS CTA Button
                            AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981), // Emerald glass highlight
                                        Color(0xFF0C831F), // Blinkit Signature Rich Green
                                        Color(0xFF065F46), // Deep jewel base
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.65), // Specular reflection border
                                      width: 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0C831F).withValues(alpha: 0.45),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, -1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Stack(
                                      children: [
                                        // Curved Gloss Reflection Lens on Top Half (Physical Glass Effect)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: 18,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.50),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Liquid Sheen Sweep Effect
                                        Positioned.fill(
                                          child: ShaderMask(
                                            shaderCallback: (bounds) {
                                              return LinearGradient(
                                                begin: Alignment(_shimmerAnimation.value - 1.0, 0),
                                                end: Alignment(_shimmerAnimation.value, 0),
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.0),
                                                  Colors.white.withValues(alpha: 0.45),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                                stops: const [0.0, 0.5, 1.0],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.srcATop,
                                            child: Container(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),

                                        // Button Content
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'View Cart',
                                                style: TanizTypography.labelLarge.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                  letterSpacing: 0.3,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withValues(alpha: 0.3),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
