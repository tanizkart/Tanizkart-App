import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/motion.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/widgets/taniz_image.dart';
import '../../../state/auth_state.dart';
import '../../auth/screens/login_screen.dart';
import '../../main_navigation_shell.dart';

enum DeliveryStatusFilter { all, pending, accepted, onRoad, delivered }

class DeliveryOrdersScreen extends StatefulWidget {
  const DeliveryOrdersScreen({super.key});

  @override
  State<DeliveryOrdersScreen> createState() => _DeliveryOrdersScreenState();
}

class _DeliveryOrdersScreenState extends State<DeliveryOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderRepository _orderRepo = OrderRepository();
  DeliveryStatusFilter _selectedFilter = DeliveryStatusFilter.all;

  bool _isOnDuty = true;
  bool _audioAlertsEnabled = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _pulseOpacityAnimation;

  StreamSubscription<Order>? _orderSub;
  Timer? _periodicSyncTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 0.9, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.8, end: 0.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initial sync with remote Supabase orders table & persistent storage
    _orderRepo.reloadFromStorage();
    _orderRepo.syncOrdersFromSupabase();

    // Listen to real-time order updates
    _orderSub = _orderRepo.orderStream.listen((_) {
      if (mounted) setState(() {});
    });

    // Periodic check to capture orders placed in other tabs / background
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _orderRepo.reloadFromStorage();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _periodicSyncTimer?.cancel();
    _orderSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    setState(() => _isRefreshing = true);
    await _orderRepo.reloadFromStorage();
    await _orderRepo.syncOrdersFromSupabase();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryOrderDetailScreen(
          orderId: order.id,
          orderRepo: _orderRepo,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = _orderRepo.getAllOrders();

    final pendingOrders = allOrders
        .where((o) =>
            o.status == OrderStatus.placed || o.status == OrderStatus.inTransit)
        .toList();

    final acceptedOrders = allOrders
        .where((o) =>
            o.status == OrderStatus.accepted ||
            o.status == OrderStatus.packing ||
            o.status == OrderStatus.readyForDispatch ||
            o.status == OrderStatus.shipped)
        .toList();

    final onRoadOrders = allOrders
        .where((o) =>
            o.status == OrderStatus.partnerAssigned ||
            o.status == OrderStatus.outForDelivery)
        .toList();

    final deliveredOrders =
        allOrders.where((o) => o.status == OrderStatus.delivered).toList();

    final activeOrdersCount = pendingOrders.length + acceptedOrders.length + onRoadOrders.length;
    final todayEarnings = 240 + (deliveredOrders.length * 40);

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
      case DeliveryStatusFilter.onRoad:
        filteredOrders = onRoadOrders;
        break;
      case DeliveryStatusFilter.delivered:
        filteredOrders = deliveredOrders;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Swiggy-style clean light surface
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshOrders,
          color: const Color(0xFFEA580C),
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ---------------------------------------------------------------
              // 1. SWIGGY-STYLE LIGHT THEME NAVBAR & SHIFT DASHBOARD HEADER
              // ---------------------------------------------------------------
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    children: [
                      // Tier 1: Rider Profile Identity & Action Utilities
                      Row(
                        children: [
                          // Rider Profile Avatar with Emerald Active Dot
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED), // Swiggy soft peach
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFDBA74),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Color(0xFFEA580C),
                                    size: 22,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _isOnDuty ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Rider Name & Store Details
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'K. Rajesh',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.storefront_rounded, size: 13, color: Color(0xFF0284C7)),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Hub #304 • Lawyerpet Dark Store',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Top Utility Controls (SOS, Sound, Logout)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // SOS Pill Button
                              TanizTappable(
                                onTap: () => _showEmergencySupportSheet(context),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.emergency_rounded, size: 14, color: Color(0xFFEF4444)),
                                      SizedBox(width: 4),
                                      Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Sound Alert Toggle
                              TanizTappable(
                                onTap: () {
                                  setState(() => _audioAlertsEnabled = !_audioAlertsEnabled);
                                  HapticFeedback.lightImpact();
                                  _showToast(
                                    context,
                                    _audioAlertsEnabled
                                        ? '🔔 Order Sound Alerts Enabled'
                                        : '🔕 Sound Alerts Muted',
                                  );
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Icon(
                                    _audioAlertsEnabled
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: _audioAlertsEnabled
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF64748B),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Switch to Customer Store Button
                              Tooltip(
                                message: 'Switch to Customer App',
                                child: TanizTappable(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: Color(0xFF0284C7),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Logout Button
                              TanizTappable(
                                onTap: () => _showLogoutDialog(context),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFF64748B),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Tier 2: Dedicated Light Duty Command Strip
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isOnDuty ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isOnDuty ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status label with live pulsating indicator
                            Row(
                              children: [
                                if (_isOnDuty)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Transform.scale(
                                            scale: _pulseScaleAnimation.value,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: _pulseOpacityAnimation.value),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                else
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isOnDuty ? 'ONLINE FOR DELIVERIES' : 'OFFLINE (DUTY PAUSED)',
                                      style: TextStyle(
                                        color: _isOnDuty ? const Color(0xFF059669) : const Color(0xFF64748B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Text(
                                      _isOnDuty
                                          ? 'Ready to accept incoming dark store orders'
                                          : 'Switch online to receive delivery tasks',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Interactive Switch Toggle
                            _buildDutyTogglePill(),
                          ],
                        ),
                      ),

                      // Tier 3: Shift Performance KPI Cards (Light Swiggy Style)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            _buildShiftMetricTile(
                              title: 'Today’s Earnings',
                              value: '₹$todayEarnings',
                              sub: '₹40/order bonus',
                              color: const Color(0xFF059669),
                              icon: Icons.currency_rupee_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildShiftMetricTile(
                              title: 'Delivered',
                              value: '${deliveredOrders.length}',
                              sub: '100% on time',
                              color: const Color(0xFF0284C7),
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildShiftMetricTile(
                              title: 'Active Orders',
                              value: '$activeOrdersCount',
                              sub: activeOrdersCount > 0 ? 'Assigned to you' : 'Idle',
                              color: const Color(0xFFEA580C),
                              icon: Icons.two_wheeler_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 2. STATUS FILTER TABS
              // ---------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                          label: 'To Accept',
                          count: pendingOrders.length,
                          filter: DeliveryStatusFilter.pending,
                          icon: Icons.flash_on_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Dark Store',
                          count: acceptedOrders.length,
                          filter: DeliveryStatusFilter.accepted,
                          icon: Icons.storefront_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'On Road',
                          count: onRoadOrders.length,
                          filter: DeliveryStatusFilter.onRoad,
                          icon: Icons.two_wheeler_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Delivered',
                          count: deliveredOrders.length,
                          filter: DeliveryStatusFilter.delivered,
                          icon: Icons.verified_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 3. SECTION SUB-HEADER WITH LIVE SYNC FEED
              // ---------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_getFilterTitle(_selectedFilter)} (${filteredOrders.length})',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isRefreshing ? 'Syncing...' : 'Live Feed',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              // 4. COMPACT ORDERS LIST (SHOWING ORDER ID & SMALL WORDS)
              // ---------------------------------------------------------------
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.inbox_rounded, size: 36, color: Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No ${_getFilterTitle(_selectedFilter)}',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isOnDuty
                                ? 'Stay online. New dark store orders will appear here.'
                                : 'You are currently OFFLINE. Switch online to receive tasks.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
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
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = filteredOrders[index];
                        return _buildCompactSwiggyOrderTile(order);
                      },
                      childCount: filteredOrders.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE ONLINE / OFFLINE TOGGLE WITH PULSE
  // ---------------------------------------------------------------------------
  Widget _buildDutyTogglePill() {
    return TanizTappable(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _isOnDuty = !_isOnDuty);
        _showToast(
          context,
          _isOnDuty
              ? '🟢 You are now ONLINE & ready for orders!'
              : '⚪ You are now OFFLINE (Shift paused)',
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _isOnDuty ? const Color(0xFF10B981) : const Color(0xFF64748B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_isOnDuty)
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isOnDuty ? 'ONLINE' : 'OFFLINE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isOnDuty ? Icons.check_rounded : Icons.close_rounded,
                size: 10,
                color: _isOnDuty ? const Color(0xFF059669) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHIFT KPI CHIPS (LIGHT THEME)
  // ---------------------------------------------------------------------------
  Widget _buildShiftMetricTile({
    required String title,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER CHIP
  // ---------------------------------------------------------------------------
  Widget _buildFilterChip({
    required String label,
    required int count,
    required DeliveryStatusFilter filter,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == filter;
    return TanizTappable(
      onTap: () {
        HapticFeedback.selectionClick();
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
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
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
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPACT SWIGGY-STYLE ORDER CARD (ORDER ID & SMALL WORDS)
  // Tapping card opens the dedicated Specific Order Screen!
  // ===========================================================================
  Widget _buildCompactSwiggyOrderTile(Order order) {
    final isCOD = order.paymentMethod == PaymentMethod.cod;
    final totalItems = order.items.fold(0, (sum, i) => sum + i.quantity);
    final bagCount = (totalItems > 4) ? 2 : 1;

    Color statusBadgeColor;
    String statusLabel;
    switch (order.status) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        statusBadgeColor = const Color(0xFFEA580C); // Swiggy Orange
        statusLabel = 'To Accept';
        break;
      case OrderStatus.accepted:
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        statusBadgeColor = const Color(0xFF0284C7); // Sky Blue
        statusLabel = 'At Dark Store';
        break;
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        statusBadgeColor = const Color(0xFF8B5CF6); // Purple/Violet
        statusLabel = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        statusBadgeColor = const Color(0xFF059669); // Emerald
        statusLabel = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusBadgeColor = const Color(0xFFEF4444);
        statusLabel = 'Cancelled';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToOrderDetail(order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Order ID (small words) + Status Badge + Payment Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${_formatTimeAgo(order.orderTime)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        // Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: statusBadgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusBadgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Payment Badge
                        if (isCOD)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFEA580C), width: 1),
                            ),
                            child: Text(
                              'COLLECT CASH: ₹${order.total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFEA580C),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981), width: 1),
                            ),
                            child: const Text(
                              'PREPAID (DO NOT COLLECT)',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Drop Location in concise small words
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Drop: ${order.deliveryAddress} • ${order.customerName}',
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Pickup Hub & Trip Distance in small words
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 13, color: Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    Text(
                      'Hub #304 • 1.4 km • $totalItems items',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Bottom Quick Action Buttons Row
                Row(
                  children: [
                    // Dedicated View Order Items Button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () => _showPackageInspectionSheet(context, order, bagCount),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFF0284C7)),
                            const SizedBox(width: 5),
                            const Text(
                              'View Order Items',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${order.items.length}',
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tap to Open Specific Order Screen
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: () => _navigateToOrderDetail(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero,
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Open Order Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
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
      ),
    );
  }

  // ===========================================================================
  // PACKAGE INSPECTION BOTTOM SHEET
  // ===========================================================================
  void _showPackageInspectionSheet(BuildContext context, Order order, int bagCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Package Checklist (${order.items.length} Items)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Order #${order.id} • Packed in $bagCount Tamper-Evident Bag${bagCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total ₹${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 12, color: Color(0xFFF8FAFC)),
                      itemBuilder: (c, i) {
                        final item = order.items[i];
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
                                      color: Color(0xFF1E293B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.product.packSize} • Qty: ${item.quantity}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Done Inspecting Bags',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // EMERGENCY / HUB ASSISTANCE SHEET
  // ---------------------------------------------------------------------------
  void _showEmergencySupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
                SizedBox(width: 10),
                Text(
                  'Rider SOS & Emergency Hub',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Select immediate assistance option. Your live GPS coordinates will be shared with the dispatcher.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            _buildSupportActionTile(
              title: 'Call Dark Store #304 Hub Manager',
              subtitle: 'K. Subba Rao • +91 98480 00304',
              icon: Icons.storefront_rounded,
              color: const Color(0xFF0284C7),
              onTap: () {
                Navigator.pop(ctx);
                _showToast(context, 'Connecting to Hub Manager...');
              },
            ),
            const SizedBox(height: 8),
            _buildSupportActionTile(
              title: 'Tanizkart Fleet 24x7 Helpline',
              subtitle: 'Toll-free 1800-425-8899',
              icon: Icons.headset_mic_rounded,
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(ctx);
                _showToast(context, 'Calling Rider Fleet Helpline...');
              },
            ),
            const SizedBox(height: 8),
            _buildSupportActionTile(
              title: 'Police Emergency Assistance (112)',
              subtitle: 'Immediate law enforcement response',
              icon: Icons.local_police_rounded,
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(ctx);
                _showToast(context, 'Emergency trigger initiated');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
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
        return 'Orders to Accept';
      case DeliveryStatusFilter.accepted:
        return 'Dark Store Pickup';
      case DeliveryStatusFilter.onRoad:
        return 'On-Road Deliveries';
      case DeliveryStatusFilter.delivered:
        return 'Completed Deliveries';
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
        duration: const Duration(milliseconds: 1600),
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
          OutlinedButton.icon(
            icon: const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF0284C7)),
            label: const Text('Customer App', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationShell()),
              );
            },
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

// =============================================================================
// SPECIFIC ORDER SCREEN (DELIVERY ORDER DETAIL SCREEN - SWIGGY PARTNER STYLE)
// Opened when the delivery partner clicks an order ID / order card
// =============================================================================
class DeliveryOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final OrderRepository orderRepo;

  const DeliveryOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.orderRepo,
  });

  @override
  State<DeliveryOrderDetailScreen> createState() => _DeliveryOrderDetailScreenState();
}

class _DeliveryOrderDetailScreenState extends State<DeliveryOrderDetailScreen> {
  StreamSubscription<Order>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.orderRepo.orderStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  void _openOtpVerificationModal(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerOtpVerificationSheet(
        order: order,
        onVerified: () {
          widget.orderRepo.verifyOtpAndDeliver(order.id, order.deliveryOtp ?? '1234');
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderRepo.getOrder(widget.orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 1,
        ),
        body: const Center(child: Text('Order not found')),
      );
    }

    final isPending = order.status == OrderStatus.placed || order.status == OrderStatus.inTransit;
    final isAccepted = order.status == OrderStatus.accepted;
    final isPacking = order.status == OrderStatus.packing ||
        order.status == OrderStatus.readyForDispatch ||
        order.status == OrderStatus.shipped;
    final isOutForDelivery = order.status == OrderStatus.partnerAssigned ||
        order.status == OrderStatus.outForDelivery;
    final isDelivered = order.status == OrderStatus.delivered;
    final isCOD = order.paymentMethod == PaymentMethod.cod;
    final totalItems = order.items.fold(0, (sum, i) => sum + i.quantity);
    final bagCount = (totalItems > 4) ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        title: Text(
          'Order #${order.id}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Order #${order.id}: ${order.deliveryAddress}'));
              _showToast('📋 Order summary copied');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Payment Alert Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isCOD ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCOD ? const Color(0xFFFDBA74) : const Color(0xFFA7F3D0),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCOD ? Icons.payments_rounded : Icons.check_circle_rounded,
                    color: isCOD ? const Color(0xFFEA580C) : const Color(0xFF059669),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCOD
                              ? 'COLLECT CASH: ₹${order.total.toStringAsFixed(0)}'
                              : 'PREPAID ORDER (DO NOT COLLECT CASH)',
                          style: TextStyle(
                            color: isCOD ? const Color(0xFFEA580C) : const Color(0xFF065F46),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          isCOD
                              ? 'Collect full cash before handing over the parcel.'
                              : 'Payment is already settled online via UPI/Card.',
                          style: TextStyle(
                            color: isCOD ? const Color(0xFF9A3412) : const Color(0xFF047857),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Order Route Progression (Pickup Hub to Drop Location)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Hub
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PICKUP FROM HUB',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Dark Store Hub #304',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Lawyerpet Main Road, Ongole',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Route Line
                  Container(
                    margin: const EdgeInsets.only(left: 14, top: 4, bottom: 4),
                    width: 2,
                    height: 24,
                    color: const Color(0xFFCBD5E1),
                  ),

                  // Drop Destination
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DELIVER TO CUSTOMER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFEF4444),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.deliveryAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customer: ${order.customerName} (${order.customerPhone})',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Map & Call Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: order.deliveryAddress));
                            _showToast('🗺️ Opening navigation to ${order.deliveryAddress}');
                          },
                          icon: const Icon(Icons.near_me_rounded, size: 15, color: Color(0xFF0284C7)),
                          label: const Text('Google Maps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0284C7),
                            side: const BorderSide(color: Color(0xFF0284C7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: order.customerPhone));
                            _showToast('📞 Dialing ${order.customerPhone}...');
                          },
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 15, color: Color(0xFF059669)),
                          label: const Text('Call Customer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF059669),
                            side: const BorderSide(color: Color(0xFF059669)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (order.deliveryInstructions.isNotEmpty || order.customInstruction != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 16, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delivery Note: ${[...order.deliveryInstructions, if (order.customInstruction != null) order.customInstruction!].join(" • ")}',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 3. Package & Items Breakdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Items (${order.items.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$bagCount Bag${bagCount > 1 ? 's' : ''} Sealed',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
                    itemBuilder: (ctx, i) {
                      final item = order.items[i];
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
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${item.product.packSize} • Qty: ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bill Amount',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '₹${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
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
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: _buildSpecificOrderAction(
            order: order,
            isPending: isPending,
            isAccepted: isAccepted,
            isPacking: isPacking,
            isOutForDelivery: isOutForDelivery,
            isDelivered: isDelivered,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificOrderAction({
    required Order order,
    required bool isPending,
    required bool isAccepted,
    required bool isPacking,
    required bool isOutForDelivery,
    required bool isDelivered,
  }) {
    if (isPending) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.orderRepo.cancelOrder(order.id, 'Declined by delivery hero');
                Navigator.pop(context);
              },
              child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.orderRepo.setOrderStatus(order.id, OrderStatus.accepted);
                setState(() {});
                _showToast('🎉 Order #${order.id} Accepted! Head to Dark Store #304');
              },
              child: const Text('Swipe to Accept Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      );
    }

    if (isAccepted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.storefront_rounded, color: Colors.white),
          label: const Text('Reached Dark Store Hub #304', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            widget.orderRepo.setOrderStatus(order.id, OrderStatus.packing);
            setState(() {});
            _showToast('🏢 Reached Dark Store Hub. Awaiting sealed bags.');
          },
        ),
      );
    }

    if (isPacking) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          label: const Text('Confirm Bag Pickup & Sealed QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            HapticFeedback.heavyImpact();
            widget.orderRepo.setOrderStatus(order.id, OrderStatus.outForDelivery);
            setState(() {});
            _showToast('📦 Order is now Out for Delivery!');
          },
        ),
      );
    }

    if (isOutForDelivery) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.key_rounded, color: Color(0xFFF59E0B)),
          label: const Text('Enter Customer OTP to Deliver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _openOtpVerificationModal(order),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Order Delivered Successfully • +₹40 added to wallet',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// IOS-STYLE NUMERIC OTP VERIFICATION MODAL SHEET
// =============================================================================
class CustomerOtpVerificationSheet extends StatefulWidget {
  final Order order;
  final VoidCallback onVerified;

  const CustomerOtpVerificationSheet({
    super.key,
    required this.order,
    required this.onVerified,
  });

  @override
  State<CustomerOtpVerificationSheet> createState() =>
      _CustomerOtpVerificationSheetState();
}

class _CustomerOtpVerificationSheetState
    extends State<CustomerOtpVerificationSheet> {
  String _enteredPin = '';
  bool _isSuccess = false;
  String? _errorMessage;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        _validateOtp();
      }
    }
  }

  void _onBackspaceTap() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _validateOtp() async {
    final expectedOtp = widget.order.deliveryOtp?.trim() ?? '1234';

    // Allow expected OTP or master demo OTP 4821
    if (_enteredPin == expectedOtp || _enteredPin == '4821') {
      HapticFeedback.heavyImpact();
      setState(() {
        _isSuccess = true;
        _errorMessage = null;
      });

      widget.onVerified();

      _dismissTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _errorMessage = 'Invalid OTP. Ask customer to check their Tanizkart app.';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _isSuccess ? _buildSuccessView() : _buildKeypadView(),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF10B981), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF059669),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Order Delivered Successfully!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 6),
              Text(
                '+₹40 added to your wallet',
                style: TextStyle(
                  color: Color(0xFF065F46),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildKeypadView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Customer Handover Verification',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ask customer for the 4-digit OTP shown on their screen',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // 4 PIN Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < _enteredPin.length;
            final isCurrent = index == _enteredPin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 54,
              height: 58,
              decoration: BoxDecoration(
                color: isFilled ? const Color(0xFFF1F5F9) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFF0284C7)
                      : (isFilled ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
                  width: isCurrent || isFilled ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  isFilled ? _enteredPin[index] : '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Custom iOS-style Numeric Keypad
        _buildNumericKeypad(),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            _buildKeypadButton('0'),
            Expanded(
              child: InkWell(
                onTap: _onBackspaceTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFF475569),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _onDigitTap(digit),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
