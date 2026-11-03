import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/mock_order_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/widgets/taniz_image.dart';

/// Production Live Order Tracking & Comprehensive Details Screen
/// Replaces the static simulated map with a 4-step status timeline:
/// [In Transit] -> [Shipped] -> [Out for Delivery] -> [Delivered]
/// accompanied by complete itemized order details, delivery partner info, and handover OTP.
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
  bool _isItemsExpanded = true;

  @override
  void initState() {
    super.initState();
    _order = widget.order ?? MockOrderRepository.getActiveOrder();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Subscribe to authoritative real-time order updates from OrderRepository / Supabase
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
    await Future.delayed(const Duration(milliseconds: 500));
    final fetched = OrderRepository().getOrder(_order.id);
    if (mounted) {
      setState(() {
        if (fetched != null) _order = fetched;
        _isRefreshing = false;
      });
    }
  }

  int get _currentStepIndex {
    return _order.status.stepIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Midnight Navy
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  _order.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusBadgeBg(_order.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _order.status.displayTitle.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusBadgeColor(_order.status),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              _order.estimatedArrivalText,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: _isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshOrderStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // 1. 4-STAGE TIMELINE: In Transit -> Shipped -> Out for Delivery -> Delivered
            // =================================================================
            _buildStatusTimelineCard(),

            const SizedBox(height: 14),

            // =================================================================
            // 2. DELIVERY HANDOVER OTP & DELIVERY PARTNER CARD
            // =================================================================
            _buildDeliveryPartnerCard(),

            const SizedBox(height: 14),

            // =================================================================
            // 3. VIEW DETAILS OF THAT ORDER (Full Item Breakdown)
            // =================================================================
            _buildOrderItemsDetailCard(),

            const SizedBox(height: 14),

            // =================================================================
            // 4. DELIVERY ADDRESS & INSTRUCTIONS
            // =================================================================
            _buildAddressAndInstructionsCard(),

            const SizedBox(height: 14),

            // =================================================================
            // 5. BILL SUMMARY BREAKDOWN
            // =================================================================
            _buildBillSummaryCard(),

            const SizedBox(height: 14),

            // =================================================================
            // 6. 24x7 CUSTOMER SUPPORT ASSISTANCE
            // =================================================================
            _buildSupportHelpBanner(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. STATUS TIMELINE COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildStatusTimelineCard() {
    final activeIndex = _currentStepIndex;

    final steps = [
      {
        'title': 'In Transit',
        'subtitle': 'Packed & dispatched from Dark Store #304',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'Shipped',
        'subtitle': 'Processed through Ongole distribution center',
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Delivery partner arriving at your doorstep in 10 mins',
        'icon': Icons.two_wheeler_rounded,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Order safely handed over & verified by OTP',
        'icon': Icons.check_circle_outline_rounded,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline_rounded, color: TanizColors.primaryBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Order Status Timeline',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '10-MIN EXPRESS',
                  style: TextStyle(
                    color: TanizColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vertical timeline with active rail
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) {
              final isPassed = index < activeIndex;
              return Container(
                margin: const EdgeInsets.only(left: 17),
                width: 2.5,
                height: 24,
                color: isPassed ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
              );
            },
            itemBuilder: (context, index) {
              final isDone = index < activeIndex;
              final isCurrent = index == activeIndex;

              Color circleBg;
              Color circleBorder;
              Widget iconWidget;

              if (isDone) {
                circleBg = const Color(0xFF059669);
                circleBorder = const Color(0xFF059669);
                iconWidget = const Icon(Icons.check, size: 16, color: Colors.white);
              } else if (isCurrent) {
                circleBg = const Color(0xFF0284C7);
                circleBorder = const Color(0xFF38BDF8);
                iconWidget = AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(steps[index]['icon'] as IconData, size: 16, color: Colors.white),
                    );
                  },
                );
              } else {
                circleBg = const Color(0xFFF1F5F9);
                circleBorder = const Color(0xFFCBD5E1);
                iconWidget = Icon(steps[index]['icon'] as IconData, size: 16, color: const Color(0xFF94A3B8));
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: circleBorder, width: isCurrent ? 2 : 1),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(child: iconWidget),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              steps[index]['title'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                color: isCurrent
                                    ? const Color(0xFF0284C7)
                                    : (isDone ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'IN PROGRESS',
                                  style: TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          steps[index]['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isCurrent
                                ? const Color(0xFF475569)
                                : (isDone ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. DELIVERY PARTNER & OTP CARD
  // ---------------------------------------------------------------------------
  Widget _buildDeliveryPartnerCard() {
    final partner = _order.deliveryPartner ??
        const DeliveryPartner(
          id: 'partner_rajesh',
          name: 'K. Rajesh',
          rating: 4.88,
          totalDeliveries: 1420,
          phone: '+91 91234 56789',
          vehicleType: 'Electric Scooter • Eco Green',
        );

    final rawOtp = _order.deliveryOtp ?? '4821';
    final spacedOtp = rawOtp.split('').join('  ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handover OTP Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY OTP HANDOVER',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Share with delivery partner upon arrival',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  ),
                  child: Text(
                    spacedOtp,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Partner Details
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🛵', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          partner.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD97706)),
                              const SizedBox(width: 2),
                              Text(
                                '${partner.rating}',
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${partner.vehicleType} • ${partner.totalDeliveries}+ deliveries',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_rounded, size: 18, color: Color(0xFF16A34A)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling partner ${partner.name} (${partner.phone})...'),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ORDER ITEMS VIEW DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildOrderItemsDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: TanizColors.primaryBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Items Ordered (${_order.items.length})',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => _isItemsExpanded = !_isItemsExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      _isItemsExpanded ? 'Hide' : 'View Details',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: TanizColors.primaryBlue,
                      ),
                    ),
                    Icon(
                      _isItemsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: TanizColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isItemsExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _order.items[index];
                final itemTotal = item.product.price * item.quantity;
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: TanizImage(
                          imageUrl: item.product.imageUrl,
                          fit: BoxFit.cover,
                          fallbackEmoji: '🛒',
                          fallbackLabel: item.product.name,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.product.packSize} • ₹${item.product.price.toStringAsFixed(0)} each',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. DELIVERY ADDRESS & INSTRUCTIONS CARD
  // ---------------------------------------------------------------------------
  Widget _buildAddressAndInstructionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _order.deliveryAddress,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _order.hubLocation.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_order.deliveryInstructions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Instructions: ${_order.deliveryInstructions.join(" • ")}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. BILL SUMMARY BREAKDOWN
  // ---------------------------------------------------------------------------
  Widget _buildBillSummaryCard() {
    final summary = _order.billSummary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: TanizColors.primaryBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Bill Details',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _order.paymentMethod == PaymentMethod.cod
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _order.paymentMethod == PaymentMethod.cod ? '💵 COD' : '💳 UPI PAID',
                  style: TextStyle(
                    color: _order.paymentMethod == PaymentMethod.cod
                        ? const Color(0xFFEA580C)
                        : const Color(0xFF16A34A),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBillRow('Items Total (MRP)', CurrencyFormatter.format(summary.mrpSubtotal)),
          const SizedBox(height: 6),
          if (summary.warehouseDiscount > 0) ...[
            _buildBillRow(
              'Warehouse Direct Discount',
              '- ${CurrencyFormatter.format(summary.warehouseDiscount)}',
              isGreen: true,
            ),
            const SizedBox(height: 6),
          ],
          _buildBillRow('Items Subtotal', CurrencyFormatter.format(summary.itemsSubtotal)),
          const SizedBox(height: 6),
          _buildBillRow('Delivery Fee', summary.deliveryFee == 0 ? 'FREE' : CurrencyFormatter.format(summary.deliveryFee), isGreen: summary.deliveryFee == 0),
          const SizedBox(height: 6),
          _buildBillRow('Handling Fee', CurrencyFormatter.format(summary.handlingFee)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                CurrencyFormatter.format(_order.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: TanizColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isGreen ? FontWeight.w800 : FontWeight.w700,
            color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. 24x7 CUSTOMER SUPPORT ASSISTANCE
  // ---------------------------------------------------------------------------
  Widget _buildSupportHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded, size: 28, color: TanizColors.primaryBlue),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with this order?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Chat with Tanizkart Ongole support team 24/7',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to Ongole Dark Store Support...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TanizColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Chat', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Color _getStatusBadgeBg(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        return const Color(0xFFFEF3C7);
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        return const Color(0xFFE0F2FE);
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return const Color(0xFFDBEAFE);
      case OrderStatus.delivered:
        return const Color(0xFFDCFCE7);
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusBadgeColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        return const Color(0xFFD97706);
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        return const Color(0xFF0284C7);
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return const Color(0xFF1D4ED8);
      case OrderStatus.delivered:
        return const Color(0xFF16A34A);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }
}
