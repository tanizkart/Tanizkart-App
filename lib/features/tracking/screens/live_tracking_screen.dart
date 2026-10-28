import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/mock_order_repository.dart';
import '../../../data/repositories/order_repository.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Order? order;

  const LiveTrackingScreen({super.key, this.order});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late Order _order;
  StreamSubscription<Order>? _orderSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderRepository.getActiveOrder();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Subscribe to authoritative real-time order stream
    _orderSubscription = OrderRepository().watchOrder(_order.id).listen((updatedOrder) {
      if (mounted) {
        setState(() {
          _order = updatedOrder;
        });
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrderStatus() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final fetched = OrderRepository().getOrder(_order.id);
    if (mounted) {
      setState(() {
        if (fetched != null) _order = fetched;
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPartner = _order.deliveryPartner != null;
    final isOutForDelivery = _order.status == OrderStatus.outForDelivery;
    final isDelivered = _order.status == OrderStatus.delivered;
    final isCancelled = _order.status == OrderStatus.cancelled;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic Map or Fulfillment Hub Radar (Fills background canvas)
          hasPartner
              ? _buildActiveRouteMap()
              : _buildFulfillmentRadarView(),

          // 2. Top Status Panel (Anchored to top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildTopStatusPanel(),
              ),
            ),
          ),

          // 3. Floating Bottom Delivery Sheet (Anchored to bottom)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: _buildDeliveryStatusCard(
                hasPartner: hasPartner,
                isOutForDelivery: isOutForDelivery,
                isDelivered: isDelivered,
                isCancelled: isCancelled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
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
                      decoration: BoxDecoration(
                        color: _getStatusColor(_order.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getStatusHeadline(_order.status),
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _order.estimatedArrivalText,
                  style: TanizTypography.bodySmall.copyWith(
                    color: TanizColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Refresh & Help Buttons
          Row(
            children: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: TanizColors.primaryBlue),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20, color: TanizColors.primaryBlue),
                onPressed: _refreshOrderStatus,
                tooltip: 'Refresh Status',
              ),
              TanizTappable(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showHelpBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ],
      ),
    );
  }

  /// Fulfillment Radar View shown when partner is NOT yet assigned (honest state)
  Widget _buildFulfillmentRadarView() {
    return Container(
      color: const Color(0xFFF3F6FA),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 140 * _pulseAnimation.value,
                        height: 140 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TanizColors.primaryBlue.withValues(alpha: 0.08),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [TanizColors.cardShadow],
                      border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Icon(
                      _order.status == OrderStatus.packing
                          ? Icons.inventory_2_rounded
                          : Icons.store_rounded,
                      size: 42,
                      color: TanizColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _order.hubLocation.label,
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _getFulfillmentSubtext(_order.status),
                  style: TanizTypography.bodySmall.copyWith(
                    color: TanizColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TanizColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.radar_rounded, size: 14, color: TanizColors.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Dispatch Radar: Finding Nearby Heroes',
                      style: TanizTypography.labelSmall.copyWith(
                        color: TanizColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Active Route Map shown when real partner is assigned
  Widget _buildActiveRouteMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _LiveRoutePainter(),
            ),
            _buildMapWaypoints(constraints),
          ],
        );
      },
    );
  }

  Widget _buildMapWaypoints(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;

    final warehouseOffset = Offset(w * 0.22, h * 0.28);
    final riderOffset = Offset(w * 0.50, h * 0.38);
    final customerOffset = Offset(w * 0.78, h * 0.45);
    final partner = _order.deliveryPartner!;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Dark Store Hub Waypoint
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
                ),
                child: Text(
                  'Lawyerpet Hub #304',
                  style: TanizTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TanizColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.warehouse_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),

        // 2. Real Delivery Partner Waypoint (Pulsing marker)
        Positioned(
          left: riderOffset.dx - 55,
          top: riderOffset.dy - 60,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
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
                      '${partner.name} (${partner.currentDistanceText})',
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
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TanizColors.primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TanizColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.electric_moped_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Customer Delivery Address Waypoint
        Positioned(
          left: customerOffset.dx - 40,
          top: customerOffset.dy - 45,
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: TanizColors.metallicGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.home_rounded, color: TanizColors.textPrimary, size: 18),
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
                  'My Location',
                  style: TanizTypography.labelSmall.copyWith(
                    color: TanizColors.textPrimary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStatusCard({
    required bool hasPartner,
    required bool isOutForDelivery,
    required bool isDelivered,
    required bool isCancelled,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TanizColors.borderSubtle),
        boxShadow: [TanizColors.floatingShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),

          // 1. Delivery OTP Card (Only when assigned or out for delivery)
          if ((hasPartner || isOutForDelivery) && !isDelivered && !isCancelled) ...[
            _buildOtpCard(),
            const SizedBox(height: 14),
          ],

          // 2. Delivery Partner / Warehouse Hero Status
          if (hasPartner)
            _buildPartnerDetailsRow(_order.deliveryPartner!)
          else
            _buildFindingPartnerRow(),

          const Divider(height: 22, color: TanizColors.borderSubtle),

          // 3. Order Status Timeline (Rendered strictly from real order states)
          _buildTimelineRow(),

          // 4. Developer / Demo State Simulator (Lets reviewer advance order state)
          const SizedBox(height: 12),
          _buildOrderActionToolbar(),
        ],
      ),
    );
  }

  Widget _buildOtpCard() {
    final otp = _order.deliveryOtp ?? '----';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TanizColors.amberContainer,
        borderRadius: BorderRadius.circular(14),
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
                  'Share with delivery hero at your doorstep',
                  style: TanizTypography.bodySmall.copyWith(
                    fontSize: 10.5,
                    color: TanizColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TanizColors.goldenAmber, width: 1.5),
            ),
            child: Text(
              otp.split('').join('  '),
              style: TanizTypography.titleLarge.copyWith(
                color: TanizColors.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerDetailsRow(DeliveryPartner partner) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: TanizColors.blueContainer,
            shape: BoxShape.circle,
            border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          child: const Icon(
            Icons.person_pin_rounded,
            color: TanizColors.primaryBlue,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${partner.name} is delivering',
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.electric_moped_rounded, size: 13, color: TanizColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    partner.vehicleType,
                    style: TanizTypography.bodySmall.copyWith(fontSize: 10.5),
                  ),
                  const SizedBox(width: 6),
                  const Text('•', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 6),
                  const Icon(Icons.star_rounded, size: 14, color: TanizColors.goldenAmber),
                  Text(
                    '${partner.rating}',
                    style: TanizTypography.labelSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            TanizTappable(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening chat with ${partner.name}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TanizColors.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TanizColors.borderSubtle),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, size: 17, color: TanizColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 8),
            TanizTappable(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Calling ${partner.name} (${partner.phone})...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TanizColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_rounded, size: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFindingPartnerRow() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: TanizColors.blueContainer,
            shape: BoxShape.circle,
            border: Border.all(color: TanizColors.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: const Icon(
            Icons.access_time_filled_rounded,
            color: TanizColors.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigning Delivery Partner',
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Searching available heroes near Dark Store #304',
                style: TanizTypography.bodySmall.copyWith(
                  color: TanizColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow() {
    final statusIndex = _getStatusStepIndex(_order.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimelineStep('Placed', Icons.check_circle_rounded, isDone: statusIndex >= 0, isCurrent: statusIndex == 0),
        _buildTimelineLine(isDone: statusIndex >= 1),
        _buildTimelineStep('Packed', Icons.inventory_2_rounded, isDone: statusIndex >= 1, isCurrent: statusIndex == 1),
        _buildTimelineLine(isDone: statusIndex >= 2),
        _buildTimelineStep('Hero', Icons.two_wheeler_rounded, isDone: statusIndex >= 2, isCurrent: statusIndex == 2),
        _buildTimelineLine(isDone: statusIndex >= 3),
        _buildTimelineStep('Delivered', Icons.home_rounded, isDone: statusIndex >= 3, isCurrent: statusIndex == 3),
      ],
    );
  }

  int _getStatusStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
        return 1;
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Widget _buildTimelineStep(String label, IconData icon, {required bool isDone, required bool isCurrent}) {
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
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isCurrent
                ? TanizColors.blueContainer
                : (isDone ? TanizColors.greenContainer : TanizColors.surfaceLow),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, size: 13, color: color),
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
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? TanizColors.rapidGreen : TanizColors.borderSubtle,
      ),
    );
  }

  Widget _buildOrderActionToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order ID: ${_order.id}',
          style: TanizTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: TanizColors.textSecondary,
          ),
        ),
        // Interactive lifecycle test trigger
        if (_order.status != OrderStatus.delivered && _order.status != OrderStatus.cancelled)
          TextButton.icon(
            onPressed: () {
              OrderRepository().advanceOrderStatus(_order.id);
            },
            icon: const Icon(Icons.fast_forward_rounded, size: 14, color: TanizColors.primaryBlue),
            label: Text(
              _getNextActionLabel(_order.status),
              style: TanizTypography.labelSmall.copyWith(
                color: TanizColors.primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          )
        else
          Text(
            _order.status == OrderStatus.delivered ? 'Completed' : 'Cancelled',
            style: TanizTypography.labelSmall.copyWith(
              color: _order.status == OrderStatus.delivered ? TanizColors.rapidGreenDark : TanizColors.errorRed,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }

  String _getNextActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Accept Basket';
      case OrderStatus.accepted:
        return 'Pack Items';
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
        return 'Assign Hero';
      case OrderStatus.partnerAssigned:
        return 'Start Trip';
      case OrderStatus.outForDelivery:
        return 'Verify & Deliver';
      default:
        return 'Next Step';
    }
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanizkart Support & Order Help', style: TanizTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.call_rounded, color: TanizColors.primaryBlue),
                title: const Text('Call Lawyerpet Dark Store Manager'),
                subtitle: const Text('+91 8592 248210 • Hub #304'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded, color: TanizColors.rapidGreenDark),
                title: const Text('Live Chat with Support'),
                subtitle: const Text('Instant answers on order delays & missing items'),
                onTap: () => Navigator.pop(context),
              ),
              if (_order.status == OrderStatus.placed || _order.status == OrderStatus.accepted)
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: TanizColors.errorRed),
                  title: const Text('Cancel Order', style: TextStyle(color: TanizColors.errorRed, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Only eligible before items are packed'),
                  onTap: () {
                    OrderRepository().cancelOrder(_order.id, 'Cancelled by customer from Help menu');
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return TanizColors.rapidGreenDark;
      case OrderStatus.cancelled:
        return TanizColors.errorRed;
      default:
        return TanizColors.primaryBlue;
    }
  }

  String _getStatusHeadline(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Dark Store Accepted Basket';
      case OrderStatus.packing:
        return 'Packing Fresh Items';
      case OrderStatus.readyForDispatch:
        return 'Ready for Dispatch';
      case OrderStatus.partnerAssigned:
        return 'Delivery Partner Assigned';
      case OrderStatus.outForDelivery:
        return 'Your Order is on the Way';
      case OrderStatus.delivered:
        return 'Order Delivered Successfully';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String _getFulfillmentSubtext(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Dark store team is verifying product availability and temperature standards.';
      case OrderStatus.accepted:
      case OrderStatus.packing:
        return 'Cold-chain items and fresh groceries are being packed into verified thermal bags.';
      case OrderStatus.readyForDispatch:
        return 'Package is sealed and ready for handover to nearby delivery hero.';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
      default:
        return 'Fulfillment underway at Tanizkart Dark Store #304.';
    }
  }
}

class _LiveRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F4F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = const Color(0xFFE5EAF2)
      ..style = PaintingStyle.fill;

    // Suburban street blocks
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 80, size.width * 0.4, 90), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.5, 90, size.width * 0.42, 100), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 220, size.width * 0.35, 120), const Radius.circular(8)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.45, 230, size.width * 0.48, 140), const Radius.circular(8)), blockPaint);

    // Streets
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

    // Active Route Line
    final routePath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.28)
      ..lineTo(size.width * 0.42, size.height * 0.32)
      ..lineTo(size.width * 0.50, size.height * 0.38)
      ..lineTo(size.width * 0.65, size.height * 0.42)
      ..lineTo(size.width * 0.78, size.height * 0.45);

    // Glow
    final glowPaint = Paint()
      ..color = TanizColors.primaryBlue.withValues(alpha: 0.25)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Core
    final corePaint = Paint()
      ..color = TanizColors.primaryBlue
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
