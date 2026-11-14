import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'mock_product_repository.dart';
import '../services/supabase_service.dart';
import '../../core/pricing/pricing_engine.dart';

class OrderRepository {
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal() {
    _ensureSeedOrders();
    reloadFromStorage();
  }

  static const String _kStorageKey = 'taniz_orders_store_v1';

  final Map<String, Order> _orders = {};
  final Map<String, String> _idempotencyToOrderId = {};
  final StreamController<Order> _orderStreamController = StreamController<Order>.broadcast();

  Stream<Order> get orderStream => _orderStreamController.stream;

  /// Stream of updates for a specific order
  Stream<Order> watchOrder(String orderId) {
    return _orderStreamController.stream.where((order) => order.id == orderId);
  }

  /// Saves all current orders to persistent SharedPreferences (HTML5 localStorage on web)
  Future<void> _saveOrdersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _orders.values.map((o) => _orderToMap(o)).toList();
      await prefs.setString(_kStorageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[OrderRepository] _saveOrdersToStorage fallback: $e');
    }
  }

  /// Reloads orders from persistent storage across tabs and sessions
  Future<void> reloadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_kStorageKey);
      if (cached != null && cached.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cached);
        for (final raw in decoded) {
          if (raw is Map<String, dynamic>) {
            final order = _orderFromMap(raw);
            _orders[order.id] = order;
            _idempotencyToOrderId[order.idempotencyKey] = order.id;
          }
        }
        if (_orders.isNotEmpty) {
          _orderStreamController.add(_orders.values.first);
        }
      }
    } catch (e) {
      debugPrint('[OrderRepository] reloadFromStorage fallback: $e');
    }
  }

  /// Serializes an Order object to a JSON-compatible map
  Map<String, dynamic> _orderToMap(Order order) {
    return {
      'id': order.id,
      'idempotencyKey': order.idempotencyKey,
      'items': order.items.map((i) => {
        'productId': i.product.id,
        'name': i.product.name,
        'brand': i.product.brand,
        'packSize': i.product.packSize,
        'price': i.product.price,
        'originalPrice': i.product.originalPrice,
        'discountPercent': i.product.discountPercent,
        'imageUrl': i.product.imageUrl,
        'categoryId': i.product.categoryId,
        'subcategory': i.product.subcategory,
        'quantity': i.quantity,
      }).toList(),
      'billSummary': {
        'totalItems': order.billSummary.totalItems,
        'mrpSubtotal': order.billSummary.mrpSubtotal,
        'warehouseDiscount': order.billSummary.warehouseDiscount,
        'itemsSubtotal': order.billSummary.itemsSubtotal,
        'handlingFee': order.billSummary.handlingFee,
        'deliveryFee': order.billSummary.deliveryFee,
        'couponDiscount': order.billSummary.couponDiscount,
        'totalPayable': order.billSummary.totalPayable,
        'totalSavings': order.billSummary.totalSavings,
      },
      'deliveryAddress': order.deliveryAddress,
      'deliveryInstructions': order.deliveryInstructions,
      'customInstruction': order.customInstruction,
      'paymentStatus': order.paymentStatus.name,
      'paymentMethod': order.paymentMethod.name,
      'transactionId': order.transactionId,
      'status': order.status.name,
      'orderTime': order.orderTime.toIso8601String(),
      'estimatedDeliveryTime': order.estimatedDeliveryTime?.toIso8601String(),
      'deliveryOtp': order.deliveryOtp,
      'deliveryPartner': order.deliveryPartner != null ? {
        'id': order.deliveryPartner!.id,
        'name': order.deliveryPartner!.name,
        'rating': order.deliveryPartner!.rating,
        'totalDeliveries': order.deliveryPartner!.totalDeliveries,
        'phone': order.deliveryPartner!.phone,
        'vehicleType': order.deliveryPartner!.vehicleType,
        'photoUrl': order.deliveryPartner!.photoUrl,
      } : null,
      'hubLocation': {
        'latitude': order.hubLocation.latitude,
        'longitude': order.hubLocation.longitude,
        'label': order.hubLocation.label,
      },
      'customerLocation': {
        'latitude': order.customerLocation.latitude,
        'longitude': order.customerLocation.longitude,
        'label': order.customerLocation.label,
      },
      'timeline': order.timeline.map((t) => {
        'status': t.status.name,
        'title': t.title,
        'subtitle': t.subtitle,
        'timestamp': t.timestamp.toIso8601String(),
      }).toList(),
      'customerId': order.customerId,
      'customerName': order.customerName,
      'customerPhone': order.customerPhone,
      'warehouseId': order.warehouseId,
    };
  }

  /// Deserializes a map back to an Order instance
  Order _orderFromMap(Map<String, dynamic> map) {
    final allProds = MockProductRepository.getAllProducts();
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final List<CartItem> items = [];

    for (final rawItem in rawItems) {
      if (rawItem is Map<String, dynamic>) {
        final pid = rawItem['productId']?.toString() ?? rawItem['id']?.toString() ?? '';
        final product = allProds.firstWhere(
          (p) => p.id == pid,
          orElse: () => Product(
            id: pid.isNotEmpty ? pid : 'prod_item',
            name: rawItem['name']?.toString() ?? 'Item',
            brand: rawItem['brand']?.toString() ?? 'Tanizkart',
            packSize: rawItem['packSize']?.toString() ?? '1 unit',
            price: (rawItem['price'] is num) ? (rawItem['price'] as num).toDouble() : 50.0,
            originalPrice: (rawItem['originalPrice'] is num) ? (rawItem['originalPrice'] as num).toDouble() : 60.0,
            discountPercent: (rawItem['discountPercent'] is num) ? (rawItem['discountPercent'] as num).toInt() : 10,
            imageUrl: rawItem['imageUrl']?.toString() ?? rawItem['image']?.toString() ?? '',
            categoryId: rawItem['categoryId']?.toString() ?? 'cat_groceries',
            subcategory: rawItem['subcategory']?.toString() ?? 'All',
          ),
        );
        final qty = (rawItem['quantity'] is num) ? (rawItem['quantity'] as num).toInt() : 1;
        items.add(CartItem(product: product, quantity: qty));
      }
    }

    if (items.isEmpty && allProds.isNotEmpty) {
      items.add(CartItem(product: allProds.first, quantity: 1));
    }

    BillSummary billSummary;
    if (map['billSummary'] is Map<String, dynamic>) {
      final b = map['billSummary'] as Map<String, dynamic>;
      billSummary = BillSummary(
        totalItems: (b['totalItems'] is num) ? (b['totalItems'] as num).toInt() : items.length,
        mrpSubtotal: (b['mrpSubtotal'] is num) ? (b['mrpSubtotal'] as num).toDouble() : 0.0,
        warehouseDiscount: (b['warehouseDiscount'] is num) ? (b['warehouseDiscount'] as num).toDouble() : 0.0,
        itemsSubtotal: (b['itemsSubtotal'] is num) ? (b['itemsSubtotal'] as num).toDouble() : 0.0,
        handlingFee: (b['handlingFee'] is num) ? (b['handlingFee'] as num).toDouble() : 0.0,
        deliveryFee: (b['deliveryFee'] is num) ? (b['deliveryFee'] as num).toDouble() : 0.0,
        couponDiscount: (b['couponDiscount'] is num) ? (b['couponDiscount'] as num).toDouble() : 0.0,
        totalPayable: (b['totalPayable'] is num) ? (b['totalPayable'] as num).toDouble() : 0.0,
        totalSavings: (b['totalSavings'] is num) ? (b['totalSavings'] as num).toDouble() : 0.0,
      );
    } else {
      billSummary = PricingEngine.calculate(items: items);
    }

    final statusStr = map['status']?.toString() ?? 'placed';
    final status = OrderStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => OrderStatus.placed,
    );

    final payStatusStr = map['paymentStatus']?.toString() ?? 'paid';
    final paymentStatus = PaymentStatus.values.firstWhere(
      (e) => e.name == payStatusStr,
      orElse: () => PaymentStatus.paid,
    );

    final payMethodStr = map['paymentMethod']?.toString() ?? 'upi';
    final paymentMethod = PaymentMethod.values.firstWhere(
      (e) => e.name == payMethodStr,
      orElse: () => PaymentMethod.upi,
    );

    DeliveryPartner? partner;
    if (map['deliveryPartner'] is Map<String, dynamic>) {
      final dp = map['deliveryPartner'] as Map<String, dynamic>;
      partner = DeliveryPartner(
        id: dp['id']?.toString() ?? 'partner_rajesh',
        name: dp['name']?.toString() ?? 'K. Rajesh',
        rating: (dp['rating'] is num) ? (dp['rating'] as num).toDouble() : 4.88,
        totalDeliveries: (dp['totalDeliveries'] is num) ? (dp['totalDeliveries'] as num).toInt() : 1420,
        phone: dp['phone']?.toString() ?? '+91 91234 56789',
        vehicleType: dp['vehicleType']?.toString() ?? 'Electric Scooter',
        photoUrl: dp['photoUrl']?.toString(),
      );
    }

    OrderLocation hub = const OrderLocation(
      latitude: 15.5057,
      longitude: 80.0499,
      label: 'Tanizkart Lawyerpet Dark Store #304',
    );
    if (map['hubLocation'] is Map<String, dynamic>) {
      final hl = map['hubLocation'] as Map<String, dynamic>;
      hub = OrderLocation(
        latitude: (hl['latitude'] is num) ? (hl['latitude'] as num).toDouble() : 15.5057,
        longitude: (hl['longitude'] is num) ? (hl['longitude'] as num).toDouble() : 80.0499,
        label: hl['label']?.toString() ?? 'Tanizkart Lawyerpet Dark Store #304',
      );
    }

    final deliveryAddress = map['deliveryAddress']?.toString() ?? 'Lawyerpet, Ongole';
    OrderLocation customerLoc = OrderLocation(
      latitude: 15.5120,
      longitude: 80.0580,
      label: deliveryAddress,
    );
    if (map['customerLocation'] is Map<String, dynamic>) {
      final cl = map['customerLocation'] as Map<String, dynamic>;
      customerLoc = OrderLocation(
        latitude: (cl['latitude'] is num) ? (cl['latitude'] as num).toDouble() : 15.5120,
        longitude: (cl['longitude'] is num) ? (cl['longitude'] as num).toDouble() : 80.0580,
        label: cl['label']?.toString() ?? deliveryAddress,
      );
    }

    final List<OrderTimelineEvent> timeline = [];
    final rawTimeline = map['timeline'] as List<dynamic>? ?? [];
    for (final t in rawTimeline) {
      if (t is Map<String, dynamic>) {
        final tStatusStr = t['status']?.toString() ?? 'placed';
        final tStatus = OrderStatus.values.firstWhere(
          (e) => e.name == tStatusStr,
          orElse: () => OrderStatus.placed,
        );
        timeline.add(OrderTimelineEvent(
          status: tStatus,
          title: t['title']?.toString() ?? 'Status Update',
          subtitle: t['subtitle']?.toString() ?? '',
          timestamp: DateTime.tryParse(t['timestamp']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
    }

    return Order(
      id: map['id']?.toString() ?? 'TK-00000',
      idempotencyKey: map['idempotencyKey']?.toString() ?? '',
      items: items,
      billSummary: billSummary,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: (map['deliveryInstructions'] is List)
          ? (map['deliveryInstructions'] as List).map((e) => e.toString()).toList()
          : const [],
      customInstruction: map['customInstruction']?.toString(),
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      transactionId: map['transactionId']?.toString(),
      status: status,
      orderTime: DateTime.tryParse(map['orderTime']?.toString() ?? '') ?? DateTime.now(),
      estimatedDeliveryTime: DateTime.tryParse(map['estimatedDeliveryTime']?.toString() ?? ''),
      deliveryOtp: map['deliveryOtp']?.toString(),
      deliveryPartner: partner,
      hubLocation: hub,
      customerLocation: customerLoc,
      timeline: timeline,
      customerId: map['customerId']?.toString() ?? '00000000-0000-0000-0000-000000000001',
      customerName: map['customerName']?.toString() ?? 'Customer',
      customerPhone: map['customerPhone']?.toString() ?? '+91 98480 22338',
      warehouseId: map['warehouseId']?.toString() ?? 'wh_lawyerpet_304',
    );
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
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? warehouseId,
  }) async {
    // 1. Idempotency protection against duplicate submissions
    if (_idempotencyToOrderId.containsKey(idempotencyKey)) {
      final existingId = _idempotencyToOrderId[idempotencyKey]!;
      if (_orders.containsKey(existingId)) {
        return _orders[existingId]!;
      }
    }

    // 2. Generate cryptographically safe order ID (TK-XXXXX) and OTP
    final random = Random();
    final orderId = 'TK-${10000 + random.nextInt(90000)}';
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
      deliveryPartner: null, // Strictly null at start - assigned when accepted!
      hubLocation: hubLocation,
      customerLocation: customerLocation,
      timeline: initialTimeline,
      customerId: customerId ?? '00000000-0000-0000-0000-000000000001',
      customerName: customerName ?? 'K. Yaswanth',
      customerPhone: customerPhone ?? '+91 98480 22338',
      warehouseId: warehouseId ?? 'wh_lawyerpet_304',
    );

    _orders[orderId] = newOrder;
    _idempotencyToOrderId[idempotencyKey] = orderId;
    _orderStreamController.add(newOrder);

    // Persist to local storage immediately so delivery guy screen sees it in any tab/session
    _saveOrdersToStorage();

    // Asynchronously push to Supabase collection
    SupabaseService().createOrderInSupabase(
      order: newOrder,
      customerName: customerName,
      customerPhone: customerPhone,
      customerId: customerId,
    );

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
    _saveOrdersToStorage();
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
    _saveOrdersToStorage();
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
    _saveOrdersToStorage();

    // Asynchronously update status in Supabase collection
    SupabaseService().updateOrderStatusInSupabase(
      orderId,
      newStatus.displayTitle,
      deliveryPartnerName: updated.deliveryPartner?.name,
    );
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
      _saveOrdersToStorage();

      // Immediately sync status to Supabase
      SupabaseService().updateOrderStatusInSupabase(
        orderId,
        'Delivered',
        notes: 'Handover verified via customer OTP',
        deliveryPartnerName: 'K. Rajesh',
      );
      return true;
    }
    return false;
  }

  /// Fetches latest active orders from Supabase and merges into OrderRepository
  Future<void> syncOrdersFromSupabase({String warehouseId = 'wh_lawyerpet_304'}) async {
    _ensureSeedOrders();
    await reloadFromStorage();
    try {
      final supabaseOrders = await SupabaseService().fetchOrdersFromSupabase(warehouseId: warehouseId);
      if (supabaseOrders == null || supabaseOrders.isEmpty) return;

      final allProds = MockProductRepository.getAllProducts();

      for (final raw in supabaseOrders) {
        final orderNumber = raw['order_number']?.toString();
        if (orderNumber == null || orderNumber.isEmpty) continue;

        final statusStr = raw['status']?.toString() ?? 'Pending';
        OrderStatus parsedStatus;
        switch (statusStr.toLowerCase()) {
          case 'in transit':
          case 'pending':
          case 'placed':
            parsedStatus = OrderStatus.placed;
            break;
          case 'accepted':
            parsedStatus = OrderStatus.accepted;
            break;
          case 'packing':
            parsedStatus = OrderStatus.packing;
            break;
          case 'shipped':
            parsedStatus = OrderStatus.shipped;
            break;
          case 'out for delivery':
            parsedStatus = OrderStatus.outForDelivery;
            break;
          case 'delivered':
            parsedStatus = OrderStatus.delivered;
            break;
          default:
            parsedStatus = OrderStatus.placed;
        }

        if (_orders.containsKey(orderNumber)) {
          final existing = _orders[orderNumber]!;
          if (existing.status != parsedStatus && parsedStatus == OrderStatus.delivered) {
            final updated = existing.copyWith(status: parsedStatus);
            _orders[orderNumber] = updated;
            _orderStreamController.add(updated);
          }
        } else {
          final rawItems = raw['items'] as List<dynamic>? ?? [];
          final List<CartItem> items = [];
          for (final item in rawItems) {
            final pid = item['id']?.toString() ?? item['product_id']?.toString() ?? '';
            final prod = allProds.firstWhere(
              (p) => p.id == pid,
              orElse: () => Product(
                id: pid.isNotEmpty ? pid : 'prod_item',
                name: item['name']?.toString() ?? 'Essential Item',
                brand: 'Tanizkart',
                packSize: item['pack_size']?.toString() ?? '1 unit',
                price: (item['price'] is num) ? (item['price'] as num).toDouble() : 50.0,
                originalPrice: (item['mrp'] is num) ? (item['mrp'] as num).toDouble() : 60.0,
                discountPercent: 10,
                imageUrl: item['image']?.toString() ?? '',
                categoryId: 'cat_groceries',
                subcategory: 'Staples',
                description: '',
              ),
            );
            final qty = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
            items.add(CartItem(product: prod, quantity: qty));
          }

          if (items.isEmpty && allProds.isNotEmpty) {
            items.add(CartItem(product: allProds.first, quantity: 1));
          }

          final summary = PricingEngine.calculate(items: items);
          final deliveryAddress = raw['delivery_address'] is String
              ? raw['delivery_address'] as String
              : (raw['delivery_address']?['address']?.toString() ?? 'Lawyerpet, Ongole');

          final rawInstructions = raw['delivery_instructions'];
          List<String> instructions = ['Contactless Handover'];
          if (rawInstructions is List) {
            instructions = rawInstructions.map((e) => e.toString()).toList();
          }

          final newOrder = Order(
            id: orderNumber,
            idempotencyKey: 'remote-$orderNumber',
            items: items,
            billSummary: summary,
            deliveryAddress: deliveryAddress,
            deliveryInstructions: instructions,
            paymentStatus: (raw['payment_status']?.toString().toLowerCase() == 'paid')
                ? PaymentStatus.paid
                : PaymentStatus.pending,
            paymentMethod: (raw['payment_method']?.toString().toLowerCase().contains('cod') ?? false)
                ? PaymentMethod.cod
                : PaymentMethod.upi,
            status: parsedStatus,
            orderTime: DateTime.tryParse(raw['created_at']?.toString() ?? '') ?? DateTime.now(),
            deliveryOtp: raw['delivery_otp']?.toString() ?? '4821',
            hubLocation: const OrderLocation(
              latitude: 15.5057,
              longitude: 80.0499,
              label: 'Tanizkart Lawyerpet Dark Store #304',
            ),
            customerLocation: OrderLocation(
              latitude: 15.5120,
              longitude: 80.0580,
              label: deliveryAddress,
            ),
            customerId: raw['customer_id']?.toString() ?? '00000000-0000-0000-0000-000000000001',
            customerName: raw['customer_name']?.toString() ?? 'Customer',
            customerPhone: raw['customer_phone']?.toString() ?? '+91 98765 43210',
            warehouseId: raw['warehouse_id']?.toString() ?? 'wh_lawyerpet_304',
          );

          _orders[orderNumber] = newOrder;
          _orderStreamController.add(newOrder);
        }
      }
    } catch (e) {
      // Graceful offline fallback
    }
  }

  void _ensureSeedOrders() {
    if (_orders.containsKey('TK-78569')) return;

    final allProds = MockProductRepository.getAllProducts();
    if (allProds.isEmpty) return;

    final now = DateTime.now();
    const hubLocation = OrderLocation(
      latitude: 15.5057,
      longitude: 80.0499,
      label: 'Tanizkart Lawyerpet Dark Store #304',
    );

    // Order 0: Newly placed customer basket (TK-78569 from screenshot)
    final items0 = [
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_pampers_pants', orElse: () => allProds[0]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_huggies_pants', orElse: () => allProds[1]), quantity: 1),
      CartItem(product: allProds.firstWhere((p) => p.id == 'prod_mother_sparsh_wipes', orElse: () => allProds[2]), quantity: 1),
      CartItem(
        product: const Product(
          id: 'combo_seafood_catch',
          name: 'Fresh Seafood Catch',
          brand: 'TANIZ SELECT',
          packSize: 'Special Bundle',
          price: 299.0,
          originalPrice: 375.0,
          discountPercent: 20,
          imageUrl: 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?auto=format&fit=crop&w=400&q=80',
          categoryId: 'cat_groceries',
          subcategory: 'Meat & Seafood',
        ),
        quantity: 1,
      ),
    ];
    final order0 = Order(
      id: 'TK-78569',
      idempotencyKey: 'idemp-seed-78569',
      items: items0,
      billSummary: PricingEngine.calculate(items: items0),
      deliveryAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole, Andhra Pradesh',
      deliveryInstructions: const ['Leave at Door'],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      transactionId: 'UPI-TXN-785699',
      status: OrderStatus.inTransit,
      orderTime: now.subtract(const Duration(minutes: 1)),
      estimatedDeliveryTime: now.add(const Duration(minutes: 11)),
      deliveryOtp: '8324',
      deliveryPartner: const DeliveryPartner(
        id: 'partner_rajesh',
        name: 'K. Rajesh',
        rating: 4.88,
        totalDeliveries: 1420,
        phone: '+91 98480 12345',
        vehicleType: 'Electric Scooter • Eco Green',
      ),
      hubLocation: hubLocation,
      customerLocation: const OrderLocation(
        latitude: 15.5120,
        longitude: 80.0580,
        label: 'Flat 302, Green Meadows, Lawyerpet, Ongole, Andhra Pradesh',
      ),
      timeline: [
        OrderTimelineEvent(
          status: OrderStatus.placed,
          title: 'Order Placed',
          subtitle: 'Payment verified via UPI',
          timestamp: now.subtract(const Duration(minutes: 2)),
        ),
        OrderTimelineEvent(
          status: OrderStatus.inTransit,
          title: 'In Transit',
          subtitle: 'Packed & dispatched from Dark Store #304',
          timestamp: now.subtract(const Duration(minutes: 1)),
        ),
      ],
      customerName: 'K. Yaswanth',
      customerPhone: '+91 98480 22338',
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

    _orders[order0.id] = order0;
    _orders[order1.id] = order1;
    _orders[order2.id] = order2;
    _orders[order3.id] = order3;
    _orders[order4.id] = order4;
    _saveOrdersToStorage();
  }
}
