import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/mock_order_repository.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Order? order;

  const LiveTrackingScreen({super.key, this.order});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late Order _order;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderRepository.getActiveOrder();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Stack(
        children: [
          // 1. Full Canvas Vector Simulation Map
          Positioned.fill(
            child: CustomPaint(
              painter: _MapCanvasPainter(),
            ),
          ),

          // 2. Interactive Map Waypoint Markers
          _buildMapWaypoints(),

          // 3. Top Floating Glassmorphic Header (16px radius, cardShadow)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                  boxShadow: [TanizColors.cardShadow],
                ),
                child: Row(
                  children: [
                    if (Navigator.canPop(context)) ...[
                      TanizTappable(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: TanizColors.rapidGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Your order is on the way',
                                style: TanizTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estimated arrival: 12 mins • Arriving by 12:42 PM',
                            style: TanizTypography.bodySmall.copyWith(
                              color: TanizColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TanizTappable(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TanizColors.blueContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.support_agent_rounded, size: 16, color: TanizColors.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Help',
                              style: TanizTypography.labelSmall.copyWith(
                                color: TanizColors.primaryBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Delivery Card / Bottom Sheet
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: _buildFloatingDeliveryCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWaypoints() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Position coordinates
        final warehouseOffset = Offset(w * 0.22, h * 0.26);
        final riderOffset = Offset(w * 0.50, h * 0.36);
        final customerOffset = Offset(w * 0.78, h * 0.44);

        return Stack(
          children: [
            // Waypoint 1: Tanizkart Dark Store Warehouse
            Positioned(
              left: warehouseOffset.dx - 45,
              top: warehouseOffset.dy - 50,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TanizColors.midnightNavy,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Tanizkart Hub #304',
                      style: TanizTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TanizColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: TanizColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Waypoint 2: Delivery Partner Rajesh K. 🚴 (Pulsing marker)
            Positioned(
              left: riderOffset.dx - 55,
              top: riderOffset.dy - 60,
              child: Column(
                children: [
                  // Floating Distance Tooltip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: TanizColors.rapidGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rajesh is 1.2 km away',
                          style: TanizTypography.labelSmall.copyWith(
                            color: TanizColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated pulse ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: TanizColors.primaryBlue.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: TanizColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: TanizColors.primaryBlue.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.two_wheeler_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Waypoint 3: Customer Location 📍 (Flat 302)
            Positioned(
              left: customerOffset.dx - 35,
              top: customerOffset.dy - 45,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: TanizColors.goldenAmber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: TanizColors.goldenAmber.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: TanizColors.borderSubtle),
                    ),
                    child: Text(
                      'Flat 302',
                      style: TanizTypography.labelSmall.copyWith(
                        color: TanizColors.textPrimary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingDeliveryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TanizColors.borderSubtle),
        boxShadow: [TanizColors.floatingShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),

          // 1. Delivery OTP Card (Prominent 4-digit code)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: TanizColors.amberContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TanizColors.goldenAmber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 16, color: TanizColors.goldenAmberDark),
                          const SizedBox(width: 4),
                          Text(
                            'DELIVERY OTP',
                            style: TanizTypography.labelSmall.copyWith(
                              color: TanizColors.goldenAmberDark,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share with delivery partner upon arrival',
                        style: TanizTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: TanizColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TanizColors.goldenAmber, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: TanizColors.goldenAmber.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    _order.deliveryOtp.split('').join('  '),
                    style: TanizTypography.titleLarge.copyWith(
                      color: TanizColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Rider Details Row (Rajesh K. ⭐ 4.8)
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TanizColors.blueContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: TanizColors.primaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_order.deliveryPartner.name} is delivering',
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.electric_moped_rounded, size: 14, color: TanizColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Delivery Hero',
                          style: TanizTypography.bodySmall.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded, size: 14, color: TanizColors.goldenAmber),
                        Text(
                          '${_order.deliveryPartner.rating}',
                          style: TanizTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call & Message Action Buttons (TanizTappable, 12px radius)
              Row(
                children: [
                  TanizTappable(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TanizColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TanizColors.borderSubtle),
                      ),
                      child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: TanizColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TanizTappable(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TanizColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [TanizColors.softShadow],
                      ),
                      child: const Icon(Icons.phone_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 24, color: TanizColors.borderSubtle),

          // 3. Order Timeline
          _buildTimelineRow(),
        ],
      ),
    );
  }

  Widget _buildTimelineRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimelineStep('Confirmed', Icons.check_circle_rounded, isDone: true),
        _buildTimelineLine(isDone: true),
        _buildTimelineStep('Packed', Icons.inventory_2_rounded, isDone: true),
        _buildTimelineLine(isDone: true),
        _buildTimelineStep('On Way', Icons.two_wheeler_rounded, isCurrent: true),
        _buildTimelineLine(isDone: false),
        _buildTimelineStep('Delivered', Icons.home_rounded, isDone: false),
      ],
    );
  }

  Widget _buildTimelineStep(String label, IconData icon, {bool isDone = false, bool isCurrent = false}) {
    Color color;
    if (isDone) {
      color = TanizColors.rapidGreenDark;
    } else if (isCurrent) {
      color = TanizColors.primaryBlue;
    } else {
      color = TanizColors.textMuted;
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCurrent ? TanizColors.blueContainer : (isDone ? TanizColors.greenContainer : TanizColors.surfaceLow),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TanizTypography.labelSmall.copyWith(
            fontSize: 9.5,
            color: color,
            fontWeight: isCurrent || isDone ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDone ? TanizColors.rapidGreen : TanizColors.borderSubtle,
      ),
    );
  }
}

/// Custom painter for vector streets, blocks, and route path
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F4F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // City street grid
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke;

    final secondaryStreetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = const Color(0xFFE4E9F2)
      ..style = PaintingStyle.fill;

    // Draw suburban blocks
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 80, size.width * 0.4, 90), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.5, 90, size.width * 0.42, 100), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 220, size.width * 0.35, 120), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.45, 230, size.width * 0.48, 140), const Radius.circular(8)), blockPaint);

    // Main streets
    final p1 = Path()
      ..moveTo(-20, size.height * 0.3)
      ..lineTo(size.width + 20, size.height * 0.3);
    canvas.drawPath(p1, streetPaint);

    final p2 = Path()
      ..moveTo(-20, size.height * 0.45)
      ..lineTo(size.width + 20, size.height * 0.45);
    canvas.drawPath(p2, streetPaint);

    final pVertical = Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.42, size.height);
    canvas.drawPath(pVertical, streetPaint);

    final pDiagonal = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.9, size.height * 0.6);
    canvas.drawPath(pDiagonal, secondaryStreetPaint);

    // Active Route Line (Warehouse ➔ Rider ➔ Customer)
    final routePath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.26)
      ..lineTo(size.width * 0.42, size.height * 0.3)
      ..lineTo(size.width * 0.50, size.height * 0.36)
      ..lineTo(size.width * 0.65, size.height * 0.40)
      ..lineTo(size.width * 0.78, size.height * 0.44);

    // Route Outer Glow
    final glowPaint = Paint()
      ..color = TanizColors.primaryBlue.withValues(alpha: 0.25)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Route Core Line
    final corePaint = Paint()
      ..color = TanizColors.primaryBlue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
