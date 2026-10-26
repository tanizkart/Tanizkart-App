import 'package:flutter/material.dart';
import '../../features/cart/screens/cart_checkout_screen.dart';

class CartNavigation {
  static bool _isNavigating = false;

  static void openCart(BuildContext context) {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartCheckoutScreen(),
      ),
    ).then((_) {
      _isNavigating = false;
    }).catchError((_) {
      _isNavigating = false;
    });
  }
}
