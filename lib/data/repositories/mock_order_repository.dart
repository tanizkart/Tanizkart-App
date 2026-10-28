import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'mock_product_repository.dart';
import '../../core/pricing/pricing_engine.dart';
import 'order_repository.dart';

class MockOrderRepository {
  static Order getActiveOrder() {
    // If order repository already has an active order, return it
    final repo = OrderRepository();
    final products = MockProductRepository.getAllProducts();
    final items = [
      CartItem(product: products[0], quantity: 1), // Amul Butter ₹58
      CartItem(product: products[1], quantity: 1), // Amul Milk ₹34
      CartItem(product: products[2], quantity: 2), // Fortune Oil or Veg
    ];

    final summary = PricingEngine.calculate(items: items);
    const hubLocation = OrderLocation(
      latitude: 15.5057,
      longitude: 80.0499,
      label: 'Tanizkart Lawyerpet Dark Store #304',
    );
    const customerLocation = OrderLocation(
      latitude: 15.5120,
      longitude: 80.0580,
      label: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
    );

    final now = DateTime.now();

    final order = Order(
      id: 'TK-89421',
      idempotencyKey: 'idemp-initial-active',
      items: items,
      billSummary: summary,
      deliveryAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole',
      deliveryInstructions: const ['Leave at Door', 'Call Upon Arrival'],
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.upi,
      transactionId: 'UPI-TXN-884920',
      status: OrderStatus.partnerAssigned,
      orderTime: now.subtract(const Duration(minutes: 6)),
      estimatedDeliveryTime: now.add(const Duration(minutes: 6)),
      deliveryOtp: '4821',
      deliveryPartner: const DeliveryPartner(
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
      ),
      hubLocation: hubLocation,
      customerLocation: customerLocation,
      timeline: [
        OrderTimelineEvent(
          status: OrderStatus.placed,
          title: 'Order Placed',
          subtitle: 'Payment verified via UPI',
          timestamp: now.subtract(const Duration(minutes: 6)),
        ),
        OrderTimelineEvent(
          status: OrderStatus.accepted,
          title: 'Order Accepted',
          subtitle: 'Dark Store #304 accepted your basket.',
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        OrderTimelineEvent(
          status: OrderStatus.packing,
          title: 'Packing Items',
          subtitle: 'Warehouse team packed all items.',
          timestamp: now.subtract(const Duration(minutes: 3)),
        ),
        OrderTimelineEvent(
          status: OrderStatus.partnerAssigned,
          title: 'Delivery Hero Assigned',
          subtitle: 'K. Rajesh on the way to pickup location.',
          timestamp: now.subtract(const Duration(minutes: 1)),
        ),
      ],
    );

    return repo.getOrder('TK-89421') ?? order;
  }
}
