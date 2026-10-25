import 'cart_item_model.dart';

enum OrderStatus {
  confirmed,
  packed,
  outForDelivery,
  delivered,
}

class DeliveryPartner {
  final String name;
  final double rating;
  final int totalDeliveries;
  final String phone;
  final String currentDistance;
  final String vehicleType;
  final bool isThermalBagVerified;

  const DeliveryPartner({
    required this.name,
    required this.rating,
    required this.totalDeliveries,
    required this.phone,
    required this.currentDistance,
    this.vehicleType = 'Electric Scooter',
    this.isThermalBagVerified = true,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double handlingFee;
  final double discount;
  final double total;
  final String deliveryOtp;
  final DeliveryPartner deliveryPartner;
  final OrderStatus status;
  final String estimatedArrival;
  final String deliveryAddress;
  final DateTime orderTime;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.handlingFee = 5.0,
    this.discount = 20.0,
    required this.total,
    this.deliveryOtp = '4821',
    required this.deliveryPartner,
    this.status = OrderStatus.outForDelivery,
    this.estimatedArrival = '12 mins • 12:42 PM',
    this.deliveryAddress = 'Flat 302, Green Meadows, Lawyerpet, Ongole',
    required this.orderTime,
  });
}
