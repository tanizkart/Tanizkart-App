import 'cart_item_model.dart';
import '../../core/pricing/pricing_engine.dart';

enum OrderStatus {
  placed,
  inTransit,
  shipped,
  accepted,
  packing,
  readyForDispatch,
  partnerAssigned,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get displayTitle {
    switch (this) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        return 0;
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        return 1;
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  String get stepDescription {
    switch (this) {
      case OrderStatus.placed:
      case OrderStatus.inTransit:
        return 'Order packed and dispatched from dark store';
      case OrderStatus.packing:
      case OrderStatus.readyForDispatch:
      case OrderStatus.shipped:
        return 'Processed and shipped through logistics hub';
      case OrderStatus.accepted:
      case OrderStatus.partnerAssigned:
      case OrderStatus.outForDelivery:
        return 'Delivery partner is en route to your address';
      case OrderStatus.delivered:
        return 'Package safely delivered at doorstep';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMethod {
  upi,
  card,
  cod,
}

class OrderLocation {
  final double latitude;
  final double longitude;
  final String label;

  const OrderLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

class DeliveryPartner {
  final String id;
  final String name;
  final double rating;
  final int totalDeliveries;
  final String phone;
  final String vehicleType;
  final bool isThermalBagVerified;
  final OrderLocation? currentLocation;
  final String? photoUrl;

  const DeliveryPartner({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalDeliveries,
    required this.phone,
    this.vehicleType = 'Electric Scooter',
    this.isThermalBagVerified = true,
    this.currentLocation,
    this.photoUrl,
  });

  String get currentDistanceText {
    if (currentLocation == null) return 'Nearby';
    return '1.1 km away';
  }
}

class OrderTimelineEvent {
  final OrderStatus status;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const OrderTimelineEvent({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}

class Order {
  final String id;
  final String idempotencyKey;
  final List<CartItem> items;
  final BillSummary billSummary;
  final String deliveryAddress;
  final List<String> deliveryInstructions;
  final String? customInstruction;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final OrderStatus status;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final String? deliveryOtp; // 4-digit code generated only for this order
  final DeliveryPartner? deliveryPartner; // null until genuine partner is assigned!
  final OrderLocation hubLocation;
  final OrderLocation customerLocation;
  final List<OrderTimelineEvent> timeline;

  const Order({
    required this.id,
    required this.idempotencyKey,
    required this.items,
    required this.billSummary,
    required this.deliveryAddress,
    this.deliveryInstructions = const [],
    this.customInstruction,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    required this.status,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.deliveryOtp,
    this.deliveryPartner,
    required this.hubLocation,
    required this.customerLocation,
    this.timeline = const [],
  });

  // Backward-compatible helpers
  double get subtotal => billSummary.itemsSubtotal;
  double get deliveryFee => billSummary.deliveryFee;
  double get handlingFee => billSummary.handlingFee;
  double get discount => billSummary.couponDiscount;
  double get total => billSummary.totalPayable;

  String get estimatedArrivalText {
    if (status == OrderStatus.delivered) {
      return 'Delivered';
    }
    if (status == OrderStatus.cancelled) {
      return 'Order Cancelled';
    }
    if (estimatedDeliveryTime != null) {
      final diff = estimatedDeliveryTime!.difference(DateTime.now()).inMinutes;
      final displayMins = diff > 0 ? diff : 2;
      final hour = estimatedDeliveryTime!.hour > 12
          ? estimatedDeliveryTime!.hour - 12
          : (estimatedDeliveryTime!.hour == 0 ? 12 : estimatedDeliveryTime!.hour);
      final minute = estimatedDeliveryTime!.minute.toString().padLeft(2, '0');
      final period = estimatedDeliveryTime!.hour >= 12 ? 'PM' : 'AM';
      return '$displayMins mins • Arriving by $hour:$minute $period';
    }
    return '10–12 mins from Lawyerpet Hub';
  }

  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DeliveryPartner? deliveryPartner,
    bool clearDeliveryPartner = false,
    DateTime? estimatedDeliveryTime,
    String? deliveryOtp,
    List<OrderTimelineEvent>? timeline,
  }) {
    return Order(
      id: id,
      idempotencyKey: idempotencyKey,
      items: items,
      billSummary: billSummary,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions,
      customInstruction: customInstruction,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      status: status ?? this.status,
      orderTime: orderTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      deliveryPartner: clearDeliveryPartner ? null : (deliveryPartner ?? this.deliveryPartner),
      hubLocation: hubLocation,
      customerLocation: customerLocation,
      timeline: timeline ?? this.timeline,
    );
  }
}
