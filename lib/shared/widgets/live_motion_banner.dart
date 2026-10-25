import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';

/// Hero Banner with strictly 135° Blue→Gold gradient, pulsing live beacon,
/// and animated motion graphics per design brief.
class LiveMotionOfferBanner extends StatefulWidget {
  final VoidCallback onShopNow;

  const LiveMotionOfferBanner({
    super.key,
    required this.onShopNow,
  });

  @override
  State<LiveMotionOfferBanner> createState() => _LiveMotionOfferBannerState();
}

class _LiveMotionOfferBannerState extends State<LiveMotionOfferBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  Timer? _countdownTimer;
  int _secondsRemaining = 9 * 60 + 42;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _animController, curve: TanizMotion.stateCurve),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _secondsRemaining = 15 * 60;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 154,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // Strict 16px card
            gradient: TanizColors.blueGoldGradient, // Strict 135° Blue->Gold gradient
            boxShadow: [
              BoxShadow(
                color: TanizColors.primaryBlue.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Soft background sparkles
                Positioned(
                  right: 16,
                  bottom: 8,
                  child: Opacity(
                    opacity: 0.20,
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16), // Strict 16px padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Live Beacon & Ticker
                      Row(
                        children: [
                          // Live Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: TanizColors.errorRed,
                              borderRadius: BorderRadius.circular(999), // 999px pill
                              boxShadow: [
                                BoxShadow(
                                  color: TanizColors.errorRed.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: _pulseAnim.value,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'LIVE OFFER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Countdown timer pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(999), // 999px pill
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: TanizColors.accentGold,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ends in ${_formatTimer(_secondsRemaining)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Promo Coupon Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Code: SAVE40',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Punchy Headline (Plus Jakarta Sans)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mega Dark Store Savings',
                            style: TanizTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Direct from Hub #304 • Up to 50% OFF daily staples',
                            style: TanizTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Bottom CTA Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Freshness Guaranteed',
                                style: TanizTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Primary CTA with Blue->Gold gradient & 12px radius
                          TanizTappable(
                            onTap: widget.onShopNow,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12), // 12px button
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shop Now',
                                    style: TanizTypography.labelMedium.copyWith(
                                      color: TanizColors.primaryDeep,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: TanizColors.primaryDeep,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
