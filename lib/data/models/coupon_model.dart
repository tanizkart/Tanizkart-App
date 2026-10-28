class Coupon {
  final String code;
  final String title;
  final String description;
  final double discountAmount;
  final double minOrderAmount;
  final bool isPercentage;
  final double? percentageValue;
  final double? maxDiscount;

  const Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.minOrderAmount,
    this.isPercentage = false,
    this.percentageValue,
    this.maxDiscount,
  });

  /// Calculates discount applicable on an order's items subtotal
  double calculateDiscount(double itemsSubtotal) {
    if (itemsSubtotal < minOrderAmount) {
      return 0.0;
    }
    if (isPercentage && percentageValue != null) {
      final calc = itemsSubtotal * (percentageValue! / 100.0);
      if (maxDiscount != null && calc > maxDiscount!) {
        return maxDiscount!;
      }
      return calc;
    }
    // Fixed amount discount cannot exceed the items subtotal
    return discountAmount > itemsSubtotal ? itemsSubtotal : discountAmount;
  }

  /// Official active coupons for Tanizkart
  static List<Coupon> get availableCoupons => const [
        Coupon(
          code: 'SAVE40',
          title: '₹40 OFF on Grocery',
          description: 'Valid on minimum order of ₹199',
          discountAmount: 40.0,
          minOrderAmount: 199.0,
        ),
        Coupon(
          code: 'WELCOME50',
          title: 'Flat ₹50 OFF for New Members',
          description: 'Valid on minimum order of ₹249',
          discountAmount: 50.0,
          minOrderAmount: 249.0,
        ),
        Coupon(
          code: 'TANIZ100',
          title: 'Mega Saver ₹100 OFF',
          description: 'Valid on warehouse basket of ₹499+',
          discountAmount: 100.0,
          minOrderAmount: 499.0,
        ),
      ];
}
