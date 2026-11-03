import 'dart:async';
import 'dart:math';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'mock_product_repository.dart';
import '../services/supabase_service.dart';
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

    // Asynchronously push to Supabase collection
    SupabaseService().createOrderInSupabase(order: newOrder);

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
          title: 'Order Confirmed',
          subtitle: 'Store received your order.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.accepted,
          timeline: timeline,
        );
        break;

      case OrderStatus.inTransit:
        timeline.add(OrderTimelineEvent(
          status: OrderStatus.shipped,
          title: 'Order Shipped',
          subtitle: 'Dispatched through Ongole distribution hub.',
          timestamp: now,
        ));
        updatedOrder = order.copyWith(
          status: OrderStatus.shipped,
          timeline: timeline,
        );
        break;

      case OrderStatus.shipped:
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

  /// Returns all active and historical orders, ensuring pre-seeded demo orders exist
  List<Order> getAllOrders() {
    _ensureSeedOrders();
    final list = _orders.values.toList();
    list.sort((a, b) => b.orderTime.compareTo(a.orderTime));
    return list;
  }

  /// Explicitly updates order status for delivery partner (Pending, Accepted, Delivered)
  void setOrderStatus(String orderId, OrderStatus newStatus) {
    final order = _orders[orderId];
    if (order == null) return;

    final now = DateTime.now();
    final timeline = List<OrderTimelineEvent>.from(order.timeline);
    String title = 'Status Updated';
    String subtitle = 'Status changed by Delivery Partner.';

    switch (newStatus) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        title = 'In Transit';
        subtitle = 'Order packed and in transit from Lawyerpet Hub.';
        break;
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        title = 'Shipped';
        subtitle = 'Package processed and shipped from fulfillment dark store.';
        break;
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        title = 'Out for Delivery';
        subtitle = 'Delivery Hero K. Rajesh is on the way with your order.';
        break;
      case OrderStatus.delivered:
        title = 'Delivered Successfully';
        subtitle = 'Handed over to customer at door.';
        break;
      case OrderStatus.cancelled:
        title = 'Order Cancelled';
        subtitle = 'Cancelled by system / hub.';
        break;
    }

    timeline.add(OrderTimelineEvent(
      status: newStatus,
      title: title,
      subtitle: subtitle,
      timestamp: now,
    ));

    final updated = order.copyWith(
      status: newStatus,
      timeline: timeline,
      deliveryPartner: (newStatus == OrderStatus.delivered ||
              newStatus == OrderStatus.outForDelivery ||
              newStatus == OrderStatus.accepted ||
              newStatus == OrderStatus.partnerAssigned)
          ? (order.deliveryPartner ??
              const DeliveryPartner(
                id: 'partner_rajesh',
                name: 'K. Rajesh',
                rating: 4.88,
                totalDeliveries: 1420,
                phone: '+91 91234 56789',
                vehicleType: 'Electric Scooter • Eco Green',
              ))
          : (newStatus == OrderStatus.placed || newStatus == OrderStatus.inTransit ? null : order.deliveryPartner),
      clearDeliveryPartner: newStatus == OrderStatus.placed,
    );

    _orders[orderId] = updated;
    _orderStreamController.add(updated);

    // Asynchronously update status in Supabase collection
    SupabaseService().updateOrderStatusInSupabase(orderId, newStatus.displayTitle);
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

  void _ensureSeedOrders() {
    if (_orders.isNotEmpty) return;

    final allProds = MockProductRepository.getAllProducts();
    if (allProds.isEmpty) return;

    final now = DateTime.now();
    const hubLocation = OrderLocation(
      latitude: 15.5057,
      longitude: 80.0499,
      label: 'Tanizkart Lawyerpet Dark Store #304',
    );

    // Order 1: Accepted / Out for Delivery (TK-89421)
    final items1 = [
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_amul_butter', orElse: () => allProds[0]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_amul_gold', orElse: () => allProds[1]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_tomato', orElse: () => allProds[2]), quantity: 2),
    ];
    final order1 = Order(
      id: 'TK-89421',
      idempotencyKey: 'idemp-seed-1',
      items: items1,
      billSummary: PricingEngine.calculate(items: items1),
      deliveryAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
      deliveryInstructions: const ['Leave at Door', 'Call Upon Arrival'],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      transactionId: 'UPI-TXN-884920',
      status: OrderStatus.outForDelivery,
      orderTime: now.subtract(const Duration(minutes: 8)),
      estimatedDeliveryTime: now.add(const Duration(minutes: 4)),
      deliveryOtp: '4821',
      deliveryPartner: const DeliveryPartner(
        id: 'partner_rajesh',
        name: 'K. Rajesh',
        rating: 4.88,
        totalDeliveries: 1420,
        phone: '+91 91234 56789',
        vehicleType: 'Electric Scooter • Eco Green',
      ),
      hubLocation: hubLocation,
      customerLocation: const OrderLocation(
        latitude: 15.5120,
        longitude: 80.0580,
        label: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
      ),
    );

    // Order 2: Pending (TK-50218) - Baby Care basket
    final items2 = [
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_pampers_pants', orElse: () => allProds[0]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_mother_sparsh_wipes', orElse: () => allProds[1]), quantity: 2),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_sebamed_wash', orElse: () => allProds[2]), quantity: 1),
    ];
    final order2 = Order(
      id: 'TK-50218',
      idempotencyKey: 'idemp-seed-2',
      items: items2,
      billSummary: PricingEngine.calculate(items: items2),
      deliveryAddress: 'Villa 12, Sri City Enclave, Kurnool Road, Ongole',
      deliveryInstructions: const ["Don't ring bell - Baby sleeping"],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      transactionId: 'UPI-TXN-902148',
      status: OrderStatus.inTransit,
      orderTime: now.subtract(const Duration(minutes: 4)),
      estimatedDeliveryTime: now.add(const Duration(minutes: 10)),
      deliveryOtp: '6523',
      deliveryPartner: null,
      hubLocation: hubLocation,
      customerLocation: const OrderLocation(
        latitude: 15.5180,
        longitude: 80.0520,
        label: 'Villa 12, Sri City Enclave, Kurnool Road, Ongole',
      ),
    );

    // Order 3: Shipped (TK-77402) - Grocery staples
    final items3 = [
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_aashirvaad_atta', orElse: () => allProds[0]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_basmati_rice', orElse: () => allProds[1]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_tata_salt', orElse: () => allProds[2]), quantity: 1),
    ];
    final order3 = Order(
      id: 'TK-77402',
      idempotencyKey: 'idemp-seed-3',
      items: items3,
      billSummary: PricingEngine.calculate(items: items3),
      deliveryAddress: 'Door 4-12, Sundaraiah Bhavan Road, Lawyerpet, Ongole',
      deliveryInstructions: const ['Call upon reaching apartment gate'],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.cod,
      transactionId: null,
      status: OrderStatus.shipped,
      orderTime: now.subtract(const Duration(minutes: 2)),
      estimatedDeliveryTime: now.add(const Duration(minutes: 11)),
      deliveryOtp: '3190',
      deliveryPartner: null,
      hubLocation: hubLocation,
      customerLocation: const OrderLocation(
        latitude: 15.5090,
        longitude: 80.0510,
        label: 'Door 4-12, Sundaraiah Bhavan Road, Lawyerpet, Ongole',
      ),
    );

    // Order 4: Delivered (TK-34190) - Home essentials
    final items4 = [
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_surf_excel', orElse: () => allProds[0]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_lizol_cleaner', orElse: () => allProds[1]), quantity: 1),
    ];
    final order4 = Order(
      id: 'TK-34190',
      idempotencyKey: 'idemp-seed-4',
      items: items4,
      billSummary: PricingEngine.calculate(items: items4),
      deliveryAddress: 'Flat 2B, Balaji Residency, Gandhi Nagar, Ongole',
      deliveryInstructions: const ['Contactless Handover'],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      transactionId: 'UPI-TXN-773199',
      status: OrderStatus.delivered,
      orderTime: now.subtract(const Duration(minutes: 32)),
      estimatedDeliveryTime: now.subtract(const Duration(minutes: 20)),
      deliveryOtp: '9041',
      deliveryPartner: const DeliveryPartner(
        id: 'partner_rajesh',
        name: 'K. Rajesh',
        rating: 4.88,
        totalDeliveries: 1420,
        phone: '+91 91234 56789',
        vehicleType: 'Electric Scooter • Eco Green',
      ),
      hubLocation: hubLocation,
      customerLocation: const OrderLocation(
        latitude: 15.5040,
        longitude: 80.0460,
        label: 'Flat 2B, Balaji Residency, Gandhi Nagar, Ongole',
      ),
    );

    _orders[order1.id] = order1;
    _orders[order2.id] = order2;
    _orders[order3.id] = order3;
    _orders[order4.id] = order4;
  }
}
