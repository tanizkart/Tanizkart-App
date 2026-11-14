import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/order_model.dart';
import '../data/models/coupon_model.dart';
import '../data/repositories/mock_product_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/services/supabase_service.dart';
import '../core/pricing/pricing_engine.dart';

class CartState extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Coupon? _appliedCoupon;
  String _customerId = '00000000-0000-0000-0000-000000000001';
  Timer? _syncDebounceTimer;

  CartState() {
    // Seed with initial items for instant interactive feel
    final allProducts = MockProductRepository.getAllProducts();
    if (allProducts.isNotEmpty) {
      _items[allProducts[0].id] = CartItem(product: allProducts[0], quantity: 1); // Butter ₹58
    }
    if (allProducts.length > 1) {
      _items[allProducts[1].id] = CartItem(product: allProducts[1], quantity: 1); // Milk ₹34
    }
    if (allProducts.length > 2) {
      _items[allProducts[2].id] = CartItem(product: allProducts[2], quantity: 1); // Bread/Noodles
    }
  }

  String get customerId => _customerId;
  Map<String, CartItem> get items => Map.unmodifiable(_items);
  List<CartItem> get itemsList => _items.values.toList();
  List<Product> get distinctProducts => _items.values.map((i) => i.product).toList();

  // Authoritative bill summary computed on the fly
  BillSummary get billSummary => PricingEngine.calculate(
        items: itemsList,
        coupon: _appliedCoupon,
      );

  int get totalItemCount => billSummary.totalItems;
  double get subtotal => billSummary.itemsSubtotal;
  double get originalSubtotal => billSummary.mrpSubtotal;
  double get totalSavings => billSummary.totalSavings;
  double get handlingFee => billSummary.handlingFee;
  double get deliveryFee => billSummary.deliveryFee;

  bool get hasCoupon => billSummary.hasCoupon;
  Coupon? get appliedCoupon => _appliedCoupon;
  String get appliedCouponCode => _appliedCoupon?.code ?? '';
  double get appliedCouponDiscount => billSummary.couponDiscount;
  String? get couponIneligibilityReason => billSummary.couponIneligibilityReason;

  double get grandTotal => billSummary.totalPayable;
  bool get isLegitimatelyFree => billSummary.isLegitimatelyFree;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  /// Sets active user association and hydrates cart from Supabase / cache
  void setCustomerId(String id) {
    if (_customerId != id) {
      _customerId = id;
      hydrateUserCart(id);
    }
  }

  /// Debounce-sync the active cart state to Supabase
  void _scheduleSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      SupabaseService().syncCartToSupabase(
        customerId: _customerId,
        items: itemsList,
      );
    });
  }

  /// Hydrates user cart from Supabase or persistent local cache on user login
  Future<void> hydrateUserCart(String customerId) async {
    _customerId = customerId;
    try {
      final remoteItems = await SupabaseService().fetchUserCartFromSupabase(customerId);
      if (remoteItems != null && remoteItems.isNotEmpty) {
        final allProducts = MockProductRepository.getAllProducts();
        _items.clear();
        for (final raw in remoteItems) {
          final pid = raw['product_id']?.toString() ?? raw['id']?.toString() ?? '';
          final prod = allProducts.firstWhere(
            (p) => p.id == pid,
            orElse: () => Product(
              id: pid.isNotEmpty ? pid : 'prod_item',
              name: raw['name']?.toString() ?? 'Essential Item',
              brand: 'Tanizkart',
              packSize: raw['pack_size']?.toString() ?? 'Standard',
              price: (raw['price'] is num) ? (raw['price'] as num).toDouble() : 50.0,
              originalPrice: (raw['mrp'] is num) ? (raw['mrp'] as num).toDouble() : 50.0,
              discountPercent: 0,
              imageUrl: raw['image']?.toString() ?? '',
              categoryId: 'cat_groceries',
              subcategory: 'All',
              description: '',
            ),
          );
          final qty = (raw['quantity'] is num) ? (raw['quantity'] as num).toInt() : 1;
          if (qty > 0) {
            _items[prod.id] = CartItem(product: prod, quantity: qty);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[CartState] hydrateUserCart error: $e');
    }
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    _scheduleSync();
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    _scheduleSync();
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
    _scheduleSync();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _syncDebounceTimer?.cancel();
    SupabaseService().clearUserCartInSupabase(_customerId);
    notifyListeners();
  }

  /// Applies coupon with strict eligibility validation
  CouponApplyResult applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    final match = Coupon.availableCoupons.firstWhere(
      (c) => c.code.toUpperCase() == clean,
      orElse: () => const Coupon(
        code: '',
        title: '',
        description: '',
        discountAmount: 0,
        minOrderAmount: 0,
      ),
    );

    if (match.code.isEmpty) {
      return CouponApplyResult(
        isSuccess: false,
        message: 'Invalid coupon code "$clean". Please check the offer code.',
      );
    }

    _appliedCoupon = match;
    notifyListeners();

    final summary = billSummary;
    if (summary.couponDiscount > 0) {
      return CouponApplyResult(
        isSuccess: true,
        message: '🎉 Coupon "${match.code}" applied! You saved ₹${summary.couponDiscount.toInt()}',
      );
    } else {
      return CouponApplyResult(
        isSuccess: false,
        message: summary.couponIneligibilityReason ??
            'Cart subtotal must be at least ₹${match.minOrderAmount.toInt()} for this offer.',
      );
    }
  }

  void toggleCoupon() {
    if (_appliedCoupon != null) {
      _appliedCoupon = null;
    } else {
      _appliedCoupon = Coupon.availableCoupons.first;
    }
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  /// Places an order via authoritative OrderRepository and syncs to Supabase
  Future<Order> placeOrder({
    required String idempotencyKey,
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
    final summary = billSummary;
    final order = await OrderRepository().createOrder(
      idempotencyKey: idempotencyKey,
      items: itemsList,
      billSummary: summary,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions,
      customInstruction: customInstruction,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      transactionId: transactionId,
      customerId: customerId ?? _customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      warehouseId: warehouseId,
    );

    // Empty user cart in local state and in Supabase
    clearCart();
    return order;
  }
}

class CouponApplyResult {
  final bool isSuccess;
  final String message;

  const CouponApplyResult({
    required this.isSuccess,
    required this.message,
  });
}
