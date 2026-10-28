import '../../data/models/cart_item_model.dart';
import '../../data/models/coupon_model.dart';

class BillSummary {
  final int totalItems;
  final double mrpSubtotal;
  final double warehouseDiscount;
  final double itemsSubtotal;
  final double handlingFee;
  final double deliveryFee;
  final Coupon? appliedCoupon;
  final double couponDiscount;
  final String? couponIneligibilityReason;
  final double totalPayable;
  final double totalSavings;

  const BillSummary({
    required this.totalItems,
    required this.mrpSubtotal,
    required this.warehouseDiscount,
    required this.itemsSubtotal,
    required this.handlingFee,
    required this.deliveryFee,
    this.appliedCoupon,
    required this.couponDiscount,
    this.couponIneligibilityReason,
    required this.totalPayable,
    required this.totalSavings,
  });

  bool get isLegitimatelyFree => totalPayable == 0.0 && totalItems > 0;
  bool get hasCoupon => appliedCoupon != null && couponDiscount > 0;
}

class PricingEngine {
  static const double standardHandlingFee = 5.0;
  static const double freeDeliveryThreshold = 149.0;
  static const double standardDeliveryFee = 25.0;

  /// Authoritative price calculation shared between Cart, Checkout, and Order Creation
  static BillSummary calculate({
    required List<CartItem> items,
    Coupon? coupon,
  }) {
    if (items.isEmpty) {
      return const BillSummary(
        totalItems: 0,
        mrpSubtotal: 0.0,
        warehouseDiscount: 0.0,
        itemsSubtotal: 0.0,
        handlingFee: 0.0,
        deliveryFee: 0.0,
        appliedCoupon: null,
        couponDiscount: 0.0,
        totalPayable: 0.0,
        totalSavings: 0.0,
      );
    }

    final int totalItems = items.fold(0, (sum, i) => sum + i.quantity);
    final double mrpSubtotal = items.fold(0.0, (sum, i) => sum + i.totalOriginalPrice);
    final double itemsSubtotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final double warehouseDiscount = (mrpSubtotal - itemsSubtotal) > 0 ? (mrpSubtotal - itemsSubtotal) : 0.0;

    // Fees
    final double handlingFee = standardHandlingFee;
    final double deliveryFee = itemsSubtotal >= freeDeliveryThreshold ? 0.0 : standardDeliveryFee;

    // Coupon discount verification
    double couponDiscount = 0.0;
    String? ineligibilityReason;

    if (coupon != null) {
      if (itemsSubtotal < coupon.minOrderAmount) {
        final needed = (coupon.minOrderAmount - itemsSubtotal).ceil();
        ineligibilityReason = 'Add items worth ₹$needed more to unlock ${coupon.code}';
      } else {
        // Coupon only discounts product subtotal, cannot exceed itemsSubtotal
        couponDiscount = coupon.calculateDiscount(itemsSubtotal);
        if (couponDiscount > itemsSubtotal) {
          couponDiscount = itemsSubtotal;
        }
      }
    }

    // Authoritative total payable:
    // (itemsSubtotal - couponDiscount) + handlingFee + deliveryFee
    final double discountedSubtotal = itemsSubtotal - couponDiscount;
    final double rawTotal = discountedSubtotal + handlingFee + deliveryFee;

    // Protection: total cannot be less than handling + delivery unless explicitly free
    final double finalPayable = rawTotal > 0 ? rawTotal : 0.0;
    final double totalSavings = warehouseDiscount + couponDiscount + (deliveryFee == 0.0 ? standardDeliveryFee : 0.0);

    return BillSummary(
      totalItems: totalItems,
      mrpSubtotal: mrpSubtotal,
      warehouseDiscount: warehouseDiscount,
      itemsSubtotal: itemsSubtotal,
      handlingFee: handlingFee,
      deliveryFee: deliveryFee,
      appliedCoupon: couponDiscount > 0 ? coupon : null,
      couponDiscount: couponDiscount,
      couponIneligibilityReason: ineligibilityReason,
      totalPayable: finalPayable,
      totalSavings: totalSavings,
    );
  }
}
