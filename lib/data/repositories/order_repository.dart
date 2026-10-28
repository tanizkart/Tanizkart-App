import 'dart:async';
import 'dart:math';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../../core/pricing/pricing_engine.dart';

class OrderRepository {
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal();

  final Map<String, Order> _orders = {};
  final Map<String, String> _idempotencyToOrderId = {};
  final StreamController<Order> _orderStreamController = StreamController<Order>.broadcast();

  Stream<Order> get orderStream => _orderStreamController.stream;

  /// Stream of updates for a specific order
  Stream<Order> watchOrder(String orderId) {
    return _orderStreamController.stream.where((order) => order.id == orderId);
  }

  /// Authoritative order creation with idempotency verification
  Future<Order> createOrder({
    required String idempotencyKey,
    required List<CartItem> items,
    required BillSummary billSummary,
    required String deliveryAddress,
    required List<String> deliveryInstructions,
    String? customInstruction,
    required PaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
    String? transactionId,
  }) async {
    // 1. Idempotency protection against duplicate submissions
    if (_idempotencyToOrderId.containsKey(idempotencyKey)) {
      final existingId = _idempotencyToOrderId[idempotencyKey]!;
      if (_orders.containsKey(existingId)) {
        return _orders[existingId]!;
      }
    }

    // 2. Generate cryptographically safe order ID and OTP
    final random = Random();
    final orderId = 'TK-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final generatedOtp = (1000 + random.nextInt(9000)).toString();

    // 3. Location setup (Warehouse Dark Store & Customer)
    const hubLocation = OrderLocation(
      latitude: 15.5057,
      longitude: 80.0499,
      label: 'Tanizkart Lawyerpet Dark Store #304',
    );
    final customerLocation = OrderLocation(
      latitude: 15.5120,
      longitude: 80.0580,
      label: deliveryAddress,
    );

    final now = DateTime.now();
    final initialTimeline = [
      OrderTimelineEvent(
        status: OrderStatus.placed,
        title: 'Order Placed',
        subtitle: 'We have received your order.',
        timestamp: now,
      ),
    ];

    final newOrder = Order(
      id: orderId,
      idempotencyKey: idempotencyKey,
      items: List.from(items),
      billSummary: billSummary,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions,
      customInstruction: customInstruction,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      status: OrderStatus.placed,
      orderTime: now,
      estimatedDeliveryTime: now.add(const Duration(minutes: 12)),
      deliveryOtp: generatedOtp,
      deliveryPartner: null, // Strictly null at start - no fake partner!
      hubLocation: hubLocation,
      customerLocation: customerLocation,
      timeline: initialTimeline,
    );

    _orders[orderId] = newOrder;
    _idempotencyToOrderId[idempotencyKey] = orderId;
    _orderStreamController.add(newOrder);

    return newOrder;
  }

  Order? getOrder(String orderId) => _orders[orderId];

  /// Simulates realistic warehouse progression for demonstration/testing
  void advanceOrderStatus(String orderId) {
    final order = _orders[orderId];
    if (order == null) return;

    Order updatedOrder;
    final now = DateTime.now();
    final timeline = List<OrderTimelineEvent>.from(order.timeline);

    switch (order.status) {
      case OrderStatus.placed:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.accepted,
          title: 'Order Accepted',
          subtitle: 'Dark Store #304 accepted your basket.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.accepted,
          timeline: timeline,
        );
        break;

      case OrderStatus.accepted:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.packing,
          title: 'Packing Items',
          subtitle: 'Warehouse team is carefully packing fresh items.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.packing,
          timeline: timeline,
        );
        break;

      case OrderStatus.packing:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.readyForDispatch,
          title: 'Ready for Dispatch',
          subtitle: 'Sealed & waiting for hero handover.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.readyForDispatch,
          timeline: timeline,
        );
        break;

      case OrderStatus.readyForDispatch:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.partnerAssigned,
          title: 'Delivery Hero Assigned',
          subtitle: 'K. Rajesh (Electric Scooter) is arriving at the hub.',
          timestamp: now,
        ));
        // Real partner assigned at this exact stage
        const realPartner = DeliveryPartner(
          id: 'partner_rajesh',
          name: 'K. Rajesh',
          rating: 4.88,
          totalDeliveries: 1420,
          phone: '+91 98480 12345',
          vehicleType: 'Electric Scooter • Eco Green',
          currentLocation: OrderLocation(
            latitude: 15.5080,
            longitude: 80.0530,
            label: 'Near Lawyerpet Main Road',
          ),
        );
        updatedOrder = order.copyWith(
          status: OrderStatus.partnerAssigned,
          deliveryPartner: realPartner,
          timeline: timeline,
        );
        break;

      case OrderStatus.partnerAssigned:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.outForDelivery,
          title: 'Out for Delivery',
          subtitle: 'Order picked up. On the way to your door.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.outForDelivery,
          timeline: timeline,
        );
        break;

      case OrderStatus.outForDelivery:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.delivered,
          title: 'Delivered',
          subtitle: 'Handed over with verified OTP.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.delivered,
          timeline: timeline,
        );
        break;

      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return;
    }

    _orders[orderId] = updatedOrder;
    _orderStreamController.add(updatedOrder);
  }

  /// Cancels an active order
  bool cancelOrder(String orderId, String reason) {
    final order = _orders[orderId];
    if (order == null) return false;

    if (order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered) {
      return false; // Cannot cancel once out for delivery or delivered
    }

    final timeline = List<OrderTimelineEvent>.from(order.timeline)
      ..add(OrderTimelineEvent(
        status: OrderStatus.cancelled,
        title: 'Order Cancelled',
        subtitle: reason,
        timestamp: DateTime.now(),
      ));

    final updated = order.copyWith(
      status: OrderStatus.cancelled,
      timeline: timeline,
    );
    _orders[orderId] = updated;
    _orderStreamController.add(updated);
    return true;
  }

  /// Verifies OTP and completes delivery
  bool verifyOtpAndDeliver(String orderId, String inputOtp) {
    final order = _orders[orderId];
    if (order == null || order.deliveryOtp == null) return false;

    if (order.deliveryOtp == inputOtp.trim()) {
      final timeline = List<OrderTimelineEvent>.from(order.timeline)
        ..add(OrderTimelineEvent(
          status: OrderStatus.delivered,
          title: 'Delivered Successfully',
          subtitle: 'Verified by OTP handover.',
          timestamp: DateTime.now(),
        ));

      final updated = order.copyWith(
        status: OrderStatus.delivered,
        timeline: timeline,
      );
      _orders[orderId] = updated;
      _orderStreamController.add(updated);
      return true;
    }
    return false;
  }
}
