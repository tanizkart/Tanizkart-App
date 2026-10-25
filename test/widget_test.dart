import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tanzikart/data/repositories/mock_category_repository.dart';
import 'package:tanzikart/data/repositories/mock_order_repository.dart';
import 'package:tanzikart/data/repositories/mock_product_repository.dart';
import 'package:tanzikart/data/repositories/mock_user_repository.dart';
import 'package:tanzikart/state/cart_state.dart';
import 'package:tanzikart/state/navigation_state.dart';
import 'package:tanzikart/state/location_state.dart';
import 'package:tanzikart/state/auth_state.dart';
import 'package:tanzikart/features/home/screens/home_screen.dart';
import 'package:tanzikart/features/tracking/screens/live_tracking_screen.dart';
import 'package:tanzikart/features/profile/screens/profile_screen.dart';

void main() {
  group('Tanizkart Core State & Repository Tests', () {
    test('CartState calculation and item management test', () {
      final cart = CartState();
      expect(cart.isNotEmpty, true);
      expect(cart.totalItemCount, 3);

      final p = MockProductRepository.getAllProducts().first;
      final initialCount = cart.getQuantity(p.id);
      cart.addItem(p);
      expect(cart.getQuantity(p.id), initialCount + 1);

      cart.removeItem(p);
      expect(cart.getQuantity(p.id), initialCount);

      // Test coupon toggling
      expect(cart.hasCoupon, true);
      cart.toggleCoupon();
      expect(cart.hasCoupon, false);
      cart.toggleCoupon();
      expect(cart.hasCoupon, true);
    });

    test('LocationState and AuthState test', () {
      final loc = LocationState();
      expect(loc.addresses.isNotEmpty, true);
      expect(loc.selectedAddress.tag, 'Home');

      final auth = AuthState();
      expect(auth.isAuthenticated, true);
      expect(auth.userName, 'Yaswanth');
    });

    test('NavigationState tab indexing test', () {
      final nav = NavigationState();
      expect(nav.currentIndex, 0);

      nav.setIndex(1);
      expect(nav.currentIndex, 1);

      nav.setIndex(2);
      expect(nav.currentIndex, 2);

      nav.setIndex(3);
      expect(nav.currentIndex, 3);
    });

    test('Mock repositories data integrity test', () {
      final products = MockProductRepository.getAllProducts();
      expect(products.isNotEmpty, true);
      expect(products.any((p) => p.name.contains('Amul Taaza')), true);

      final categories = MockCategoryRepository.getAllCategories();
      expect(categories.length, 8);

      final order = MockOrderRepository.getActiveOrder();
      expect(order.deliveryPartner.name, 'Rajesh K.');
      expect(order.deliveryOtp, '4821');

      final user = MockUserRepository.getUserProfile();
      expect(user.name, 'Yaswanth');
      expect(user.totalOrders, 12);
      expect(user.isPremiumActive, true);
    });

    test('Product sorting and filtering reorders list correctly', () {
      final products = MockProductRepository.getAllProducts();
      expect(products.length >= 2, true);

      // Price: Low to High
      final sortedLowToHigh = MockProductRepository.sortProducts(products, ProductSortOption.priceLowToHigh);
      for (int i = 0; i < sortedLowToHigh.length - 1; i++) {
        expect(sortedLowToHigh[i].price <= sortedLowToHigh[i + 1].price, true);
      }

      // Price: High to Low
      final sortedHighToLow = MockProductRepository.sortProducts(products, ProductSortOption.priceHighToLow);
      for (int i = 0; i < sortedHighToLow.length - 1; i++) {
        expect(sortedHighToLow[i].price >= sortedHighToLow[i + 1].price, true);
      }

      // Discount: Highest First
      final sortedDiscount = MockProductRepository.sortProducts(products, ProductSortOption.discount);
      for (int i = 0; i < sortedDiscount.length - 1; i++) {
        expect(sortedDiscount[i].discountPercent >= sortedDiscount[i + 1].discountPercent, true);
      }

      // Rating: Highest First
      final sortedRating = MockProductRepository.sortProducts(products, ProductSortOption.rating);
      for (int i = 0; i < sortedRating.length - 1; i++) {
        expect(sortedRating[i].rating >= sortedRating[i + 1].rating, true);
      }

      // Popularity: Highest ratingCount First
      final sortedPopular = MockProductRepository.sortProducts(products, ProductSortOption.popular);
      for (int i = 0; i < sortedPopular.length - 1; i++) {
        expect(sortedPopular[i].ratingCount >= sortedPopular[i + 1].ratingCount, true);
      }
    });
  });

  group('Tanizkart Screen Widget Tests', () {
    testWidgets('HomeScreen renders key UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartState()),
            ChangeNotifierProvider(create: (_) => NavigationState()),
            ChangeNotifierProvider(create: (_) => LocationState()),
            ChangeNotifierProvider(create: (_) => AuthState()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify essential UI texts
      expect(find.text('Explore Categories'), findsOneWidget);
      expect(find.text('View All (24+)'), findsOneWidget);
      expect(find.text('Shop Now'), findsOneWidget);
    });

    testWidgets('LiveTrackingScreen renders rider, OTP, and status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartState()),
            ChangeNotifierProvider(create: (_) => NavigationState()),
            ChangeNotifierProvider(create: (_) => LocationState()),
            ChangeNotifierProvider(create: (_) => AuthState()),
          ],
          child: const MaterialApp(
            home: LiveTrackingScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify OTP card and delivery partner
      expect(find.textContaining('4  8  2  1'), findsOneWidget);
      expect(find.textContaining('Rajesh K.'), findsWidgets);
      expect(find.textContaining('Your order is on the way'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user stats and VIP card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CartState()),
            ChangeNotifierProvider(create: (_) => NavigationState()),
            ChangeNotifierProvider(create: (_) => LocationState()),
            ChangeNotifierProvider(create: (_) => AuthState()),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify User Profile elements
      expect(find.textContaining('Yaswanth'), findsOneWidget);
      expect(find.textContaining('Orders'), findsWidgets);
      expect(find.textContaining('VIP'), findsWidgets);
    });
  });
}
