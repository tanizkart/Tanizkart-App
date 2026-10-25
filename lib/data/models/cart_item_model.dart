import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
  double get totalOriginalPrice => product.originalPrice * quantity;
  double get totalSavings => (product.originalPrice - product.price) * quantity;
}
