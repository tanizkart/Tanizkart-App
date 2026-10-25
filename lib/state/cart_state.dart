import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/mock_product_repository.dart';

class CartState extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  CartState() {
    // Seed with initial items for instant interactive feel
    final allProducts = MockProductRepository.getAllProducts();
    if (allProducts.isNotEmpty) {
      _items[allProducts[0].id] = CartItem(product: allProducts[0], quantity: 1); // Amul Taaza ₹28
    }
    if (allProducts.length > 1) {
      _items[allProducts[1].id] = CartItem(product: allProducts[1], quantity: 1); // Eggs ₹58
    }
    if (allProducts.length > 2) {
      _items[allProducts[2].id] = CartItem(product: allProducts[2], quantity: 1); // Bread ₹45
    }
  }

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  List<CartItem> get itemsList => _items.values.toList();

  List<Product> get distinctProducts => _items.values.map((i) => i.product).toList();

  int get totalItemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.values.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get originalSubtotal => _items.values.fold(0.0, (sum, i) => sum + i.totalOriginalPrice);

  double get totalSavings => originalSubtotal - subtotal;

  final double handlingFee = 5.0;
  final double deliveryFee = 0.0; // Free delivery

  String _appliedCouponCode = 'SAVE40';
  double _appliedCouponDiscount = 40.0;
  bool _hasCoupon = true;

  bool get hasCoupon => _hasCoupon;
  String get appliedCouponCode => _appliedCouponCode;
  double get appliedCouponDiscount => _hasCoupon ? _appliedCouponDiscount : 0.0;

  double get grandTotal {
    final computed = subtotal + handlingFee + deliveryFee - appliedCouponDiscount;
    return computed > 0 ? computed : 0;
  }

  void toggleCoupon() {
    _hasCoupon = !_hasCoupon;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'SAVE40') {
      _appliedCouponCode = 'SAVE40';
      _appliedCouponDiscount = 40.0;
      _hasCoupon = true;
      notifyListeners();
      return true;
    } else if (clean == 'WELCOME50') {
      _appliedCouponCode = 'WELCOME50';
      _appliedCouponDiscount = 50.0;
      _hasCoupon = true;
      notifyListeners();
      return true;
    } else if (clean == 'TANIZ100') {
      _appliedCouponCode = 'TANIZ100';
      _appliedCouponDiscount = 100.0;
      _hasCoupon = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _hasCoupon = false;
    notifyListeners();
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _items.remove(product.id);
    } else {
      if (_items.containsKey(product.id)) {
        _items[product.id]!.quantity = quantity;
      } else {
        _items[product.id] = CartItem(product: product, quantity: quantity);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Order placeOrder({required String deliveryAddress}) {
    final newOrder = Order(
      id: 'OD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      items: List.from(_items.values),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      handlingFee: handlingFee,
      discount: appliedCouponDiscount,
      total: grandTotal,
      deliveryOtp: '4821',
      deliveryPartner: const DeliveryPartner(
        name: 'Rajesh K.',
        rating: 4.8,
        totalDeliveries: 1420,
        phone: '+91 98491 88210',
        currentDistance: '1.2 km away',
      ),
      deliveryAddress: deliveryAddress,
      orderTime: DateTime.now(),
    );

    clearCart();
    return newOrder;
  }
}
