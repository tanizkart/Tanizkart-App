import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/widgets/taniz_image.dart';
import '../../../state/auth_state.dart';
import '../../auth/screens/login_screen.dart';

enum DeliveryStatusFilter { all, pending, accepted, delivered }

class DeliveryOrdersScreen extends StatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  State<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends State<DeliveryOrdersScreen> {
  final OrderRepository _orderRepo = OrderRepository();
  DeliveryStatusFilter _selectedFilter = DeliveryStatusFilter.all;
  bool _isOnDuty = true;

  @override
  Widget build(BuildContext context) {
    final allOrders = _orderRepo.getAllOrders();

    final pendingOrders = allOrders.where((o) =>
        o.status == OrderStatus.placed ||
        o.status == OrderStatus.packing ||
        o.status == OrderStatus.readyForDispatch).toList();

    final acceptedOrders = allOrders.where((o) =>
        o.status == OrderStatus.accepted ||
        o.status == OrderStatus.partnerAssigned ||
        o.status == OrderStatus.outForDelivery).toList();

    final deliveredOrders = allOrders.where((o) => o.status == OrderStatus.delivered).toList();

    List<Order> filteredOrders;
    switch (_selectedFilter) {
      case DeliveryStatusFilter.all:
        filteredOrders = allOrders;
        break;
      case DeliveryStatusFilter.pending:
        filteredOrders = pendingOrders;
        break;
      case DeliveryStatusFilter.accepted:
        filteredOrders = acceptedOrders;
        break;
      case DeliveryStatusFilter.delivered:
        filteredOrders = deliveredOrders;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate surface
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Dark slate navy
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TanizColors.primaryEmerald.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: TanizColors.primaryEmerald, width: 1.5),
              ),
              child: const Center(
                child: Text('🛵', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Delivery Hero Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isOnDuty ? const Color(0xFF059669) : const Color(0xFF64748B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'K. Rajesh • Dark Store #304 Lawyerpet',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Switch duty toggle
          IconButton(
            icon: Icon(
              _isOnDuty ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: _isOnDuty ? TanizColors.accentGold : const Color(0xFF94A3B8),
              size: 22,
            ),
            tooltip: 'Toggle Duty Status',
            onPressed: () {
              setState(() => _isOnDuty = !_isOnDuty);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isOnDuty ? 'You are now ON DUTY' : 'You are now OFF DUTY'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _isOnDuty ? const Color(0xFF059669) : const Color(0xFF475569),
                ),
              );
            },
          ),
          // Logout / Switch Account
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
            tooltip: 'Switch to Customer Account',
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Hero Stats Header Strip
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildMetricTile(
                        label: 'Pending',
                        count: '${pendingOrders.length}',
                        color: const Color(0xFFF59E0B),
                        icon: Icons.hourglass_top_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        label: 'Accepted',
                        count: '${acceptedOrders.length}',
                        color: const Color(0xFF38BDF8),
                        icon: Icons.two_wheeler_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricTile(
                        label: 'Delivered',
                        count: '${deliveredOrders.length}',
                        color: const Color(0xFF10B981),
                        icon: Icons.check_circle_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Status Filter Tabs (All, Pending, Accepted, Delivered)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All Orders',
                      count: allOrders.length,
                      filter: DeliveryStatusFilter.all,
                      icon: Icons.list_alt_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Pending',
                      count: pendingOrders.length,
                      filter: DeliveryStatusFilter.pending,
                      icon: Icons.hourglass_empty_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Accepted',
                      count: acceptedOrders.length,
                      filter: DeliveryStatusFilter.accepted,
                      icon: Icons.delivery_dining_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Delivered',
                      count: deliveredOrders.length,
                      filter: DeliveryStatusFilter.delivered,
                      icon: Icons.done_all_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Section Title & Live Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getFilterTitle(_selectedFilter)} (${filteredOrders.length})',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Auto-sync with Store #304',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Orders List
          if (filteredOrders.isEmpty)
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Icon(Icons.inbox_rounded, size: 36, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No ${_getFilterTitle(_selectedFilter)} Orders',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'New customer orders will automatically show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = filteredOrders[index];
                    return _buildDeliveryOrderCard(order);
                  },
                  childCount: filteredOrders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required DeliveryStatusFilter filter,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == filter;
    return TanizTappable(
      onTap: () {
        setState(() => _selectedFilter = filter);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOrderCard(Order order) {
    final isPending = order.status == OrderStatus.placed ||
        order.status == OrderStatus.packing ||
        order.status == OrderStatus.readyForDispatch;
    final isAccepted = order.status == OrderStatus.accepted ||
        order.status == OrderStatus.partnerAssigned ||
        order.status == OrderStatus.outForDelivery;
    final isDelivered = order.status == OrderStatus.delivered;

    Color badgeColor;
    Color badgeBg;
    String badgeText;
    IconData badgeIcon;

    if (isDelivered) {
      badgeColor = const Color(0xFF059669);
      badgeBg = const Color(0xFFECFDF5);
      badgeText = 'Delivered';
      badgeIcon = Icons.check_circle_rounded;
    } else if (isAccepted) {
      badgeColor = const Color(0xFF0284C7);
      badgeBg = const Color(0xFFF0F9FF);
      badgeText = 'Accepted (On Way)';
      badgeIcon = Icons.two_wheeler_rounded;
    } else {
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFFFBEB);
      badgeText = 'Pending (To Pack/Assign)';
      badgeIcon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAccepted
              ? const Color(0xFF38BDF8)
              : const Color(0xFFE2E8F0),
          width: isAccepted ? 1.5 : 1,
        ),
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
          // Header: Order ID + Status Badge
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.paymentMethod == PaymentMethod.cod ? '💵 COD' : '💳 UPI Paid',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.paymentMethod == PaymentMethod.cod
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customer Address & Destination
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.deliveryInstructions.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Note: ${order.deliveryInstructions.join(" • ")}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (order.deliveryOtp != null)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      'OTP: ${order.deliveryOtp}',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // -------------------------------------------------------------------
          // ITEMS ORDERED SECTION (What the user has ordered)
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ITEMS IN BASKET (${order.items.fold(0, (sum, i) => sum + i.quantity)} Items)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Total: ₹${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Items row list
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: TanizImage(
                              imageUrl: item.product.imageUrl,
                              fit: BoxFit.cover,
                              fallbackEmoji: '🛒',
                              fallbackLabel: item.product.name,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
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
                        const SizedBox(width: 8),
                        Text(
                          '₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // -------------------------------------------------------------------
          // DELIVERY GUY STATUS OPTIONS (Pending, Accepted, Delivered)
          // -------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CHANGE STATUS:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Delivery Partner Actions',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Option 1: Pending
                    Expanded(
                      child: _buildStatusToggleButton(
                        label: 'Pending',
                        icon: Icons.hourglass_empty_rounded,
                        isActive: isPending,
                        activeColor: const Color(0xFFD97706),
                        activeBg: const Color(0xFFFEF3C7),
                        onTap: () {
                          _orderRepo.setOrderStatus(order.id, OrderStatus.placed);
                          setState(() {});
                          _showToast(context, '${order.id} marked as Pending ⏳');
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Option 2: Accepted
                    Expanded(
                      child: _buildStatusToggleButton(
                        label: 'Accepted',
                        icon: Icons.two_wheeler_rounded,
                        isActive: isAccepted,
                        activeColor: const Color(0xFF0284C7),
                        activeBg: const Color(0xFFE0F2FE),
                        onTap: () {
                          _orderRepo.setOrderStatus(order.id, OrderStatus.outForDelivery);
                          setState(() {});
                          _showToast(context, '${order.id} marked as Accepted 🛵');
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Option 3: Delivered
                    Expanded(
                      child: _buildStatusToggleButton(
                        label: 'Delivered',
                        icon: Icons.check_circle_outline_rounded,
                        isActive: isDelivered,
                        activeColor: const Color(0xFF059669),
                        activeBg: const Color(0xFFDCFCE7),
                        onTap: () {
                          _orderRepo.setOrderStatus(order.id, OrderStatus.delivered);
                          setState(() {});
                          _showToast(context, '${order.id} marked as Delivered ✅');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : const Color(0xFF475569),
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterTitle(DeliveryStatusFilter filter) {
    switch (filter) {
      case DeliveryStatusFilter.all:
        return 'All Active Orders';
      case DeliveryStatusFilter.pending:
        return 'Pending Orders';
      case DeliveryStatusFilter.accepted:
        return 'Accepted Orders';
      case DeliveryStatusFilter.delivered:
        return 'Delivered Orders';
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Exit Delivery Portal?'),
        content: const Text(
          'You can switch back to the Customer app or log in with another dummy number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthState>(context, listen: false);
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
