import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'mock_product_repository.dart';

class MockOrderRepository {
  static Order getActiveOrder() {
    final products = MockProductRepository.getAllProducts();
    final items = [
      CartItem(product: products[0], quantity: 1), // Amul Taaza ₹28
      CartItem(product: products[1], quantity: 1), // Country Eggs ₹58
      CartItem(product: products[2], quantity: 1), // Britannia Bread ₹45
    ];

    final subtotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    const handlingFee = 5.0;
    const deliveryFee = 0.0; // Free for Tanizkart Member
    const discount = 20.0; // Coupon TANIZSAVE
    final total = subtotal + handlingFee + deliveryFee - discount;

    return Order(
      id: 'TK-89421',
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      handlingFee: handlingFee,
      discount: discount,
      total: total > 0 ? total : subtotal,
      deliveryOtp: '4821',
      deliveryPartner: const DeliveryPartner(
        name: 'Rajesh K.',
        rating: 4.8,
        totalDeliveries: 1420,
        phone: '+91 98480 12345',
        currentDistance: '1.2 km away',
        vehicleType: 'Electric Scooter',
        isThermalBagVerified: true,
      ),
      status: OrderStatus.outForDelivery,
      estimatedArrival: '12 mins • 12:42 PM',
      deliveryAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
      orderTime: DateTime.now().subtract(const Duration(minutes: 8)),
    );
  }
}
