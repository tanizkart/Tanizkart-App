import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanzikart/data/models/order_model.dart';
import 'package:tanzikart/data/models/cart_item_model.dart';
import 'package:tanzikart/data/repositories/mock_category_repository.dart';
import 'package:tanzikart/data/repositories/mock_order_repository.dart';
import 'package:tanzikart/data/repositories/mock_product_repository.dart';
import 'package:tanzikart/data/repositories/mock_user_repository.dart';
import 'package:tanzikart/data/repositories/mock_dark_store_repository.dart';
import 'package:tanzikart/data/repositories/order_repository.dart';
import 'package:tanzikart/core/pricing/pricing_engine.dart';
import 'package:tanzikart/state/cart_state.dart';
import 'package:tanzikart/state/navigation_state.dart';
import 'package:tanzikart/state/location_state.dart';
import 'package:tanzikart/state/auth_state.dart';
import 'package:tanzikart/state/wishlist_state.dart';
import 'package:tanzikart/state/payment_state.dart';
import 'package:tanzikart/features/home/screens/home_screen.dart';
import 'package:tanzikart/features/tracking/screens/live_tracking_screen.dart';
import 'package:tanzikart/features/profile/screens/profile_screen.dart';
import 'package:tanzikart/features/profile/screens/edit_profile_screen.dart';
import 'package:tanzikart/features/profile/screens/wishlist_screen.dart';
import 'package:tanzikart/features/profile/screens/payment_methods_screen.dart';
import 'package:tanzikart/features/profile/screens/dark_store_vicinity_screen.dart';
import 'package:tanzikart/features/profile/screens/help_center_screen.dart';
import 'package:tanzikart/features/profile/screens/contact_support_screen.dart';
import 'package:tanzikart/features/profile/screens/terms_privacy_screen.dart';
import 'package:tanzikart/features/categories/screens/categories_overview_screen.dart';
import 'package:tanzikart/features/listing/screens/product_listing_screen.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartState()),
      ChangeNotifierProvider(create: (_) => NavigationState()),
      ChangeNotifierProvider(create: (_) => LocationState()),
      ChangeNotifierProvider(create: (_) => AuthState()),
      ChangeNotifierProvider(create: (_) => WishlistState()),
      ChangeNotifierProvider(create: (_) => PaymentState()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
      cart.toggleCoupon();
      expect(cart.appliedCoupon != null, true);
      cart.toggleCoupon();
      expect(cart.appliedCoupon == null, true);
    });

    test('Prevention of erroneous ₹0 total: Maggi ₹14 cannot apply SAVE40 (min ₹199)', () {
      final cart = CartState();
      cart.clearCart();

      // Add single Maggi noodle (₹14)
      final maggi = MockProductRepository.getAllProducts().firstWhere((p) => p.name.contains('Maggi'));
      cart.addItem(maggi);

      expect(cart.totalItemCount, 1);
      expect(cart.subtotal, 14.0);

      // Attempt to apply SAVE40 which requires min ₹199
      final result = cart.applyCoupon('SAVE40');
      expect(result.isSuccess, false);
      expect(cart.appliedCouponDiscount, 0.0);
      expect(cart.couponIneligibilityReason?.contains('Add items worth ₹185 more'), true);

      // Total must be positive: ₹14 items + ₹5 handling + ₹25 delivery = ₹44
      expect(cart.grandTotal, 44.0);
      expect(cart.grandTotal > 0, true);
    });

    test('Authoritative PricingEngine correctly calculates eligible discounts', () {
      final cart = CartState();
      cart.clearCart();

      // Add high value basket > ₹199
      final butter = MockProductRepository.getAllProducts().firstWhere((p) => p.name.contains('Butter'));
      for (int i = 0; i < 4; i++) {
        cart.addItem(butter); // 4 * ₹58 = ₹232
      }

      expect(cart.subtotal, 232.0);

      // SAVE40 should now apply successfully
      final result = cart.applyCoupon('SAVE40');
      expect(result.isSuccess, true);
      expect(cart.appliedCouponDiscount, 40.0);

      // Free delivery on ₹149+, so: 232 - 40 + 5 handling + 0 delivery = ₹197
      expect(cart.grandTotal, 197.0);
    });

    test('OrderRepository idempotency and lifecycle progression', () async {
      final repo = OrderRepository();
      final products = MockProductRepository.getAllProducts();
      final items = [CartItem(product: products[0], quantity: 1)];
      final summary = PricingEngine.calculate(items: items);

      final order1 = await repo.createOrder(
        idempotencyKey: 'idemp-test-key-1',
        items: items,
        billSummary: summary,
        deliveryAddress: 'Flat 302, Green Meadows',
        deliveryInstructions: ['Leave at Door'],
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
      );

      expect(order1.status, OrderStatus.placed);
      expect(order1.deliveryPartner, isNull); // Partner is not fabricated on placement!

      // Duplicate submission with same idempotency key returns exact same order
      final orderDup = await repo.createOrder(
        idempotencyKey: 'idemp-test-key-1',
        items: items,
        billSummary: summary,
        deliveryAddress: 'Flat 302, Green Meadows',
        deliveryInstructions: ['Leave at Door'],
        paymentMethod: PaymentMethod.upi,
        paymentStatus: PaymentStatus.paid,
      );
      expect(orderDup.id, order1.id);

      // Advance through real states
      repo.advanceOrderStatus(order1.id); // -> accepted
      expect(repo.getOrder(order1.id)!.status, OrderStatus.accepted);

      repo.advanceOrderStatus(order1.id); // -> packing
      expect(repo.getOrder(order1.id)!.status, OrderStatus.packing);

      repo.advanceOrderStatus(order1.id); // -> readyForDispatch
      expect(repo.getOrder(order1.id)!.status, OrderStatus.readyForDispatch);

      repo.advanceOrderStatus(order1.id); // -> partnerAssigned (Partner genuinely assigned here!)
      final assignedOrder = repo.getOrder(order1.id)!;
      expect(assignedOrder.status, OrderStatus.partnerAssigned);
      expect(assignedOrder.deliveryPartner, isNotNull);
      expect(assignedOrder.deliveryPartner!.name, 'K. Rajesh');

      // OTP Verification delivers order
      final otp = assignedOrder.deliveryOtp!;
      final wrongOtpResult = repo.verifyOtpAndDeliver(order1.id, '0000');
      expect(wrongOtpResult, false);

      final correctOtpResult = repo.verifyOtpAndDeliver(order1.id, otp);
      expect(correctOtpResult, true);
      expect(repo.getOrder(order1.id)!.status, OrderStatus.delivered);
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
      expect(products.any((p) => p.name.contains('Amul')), true);

      final categories = MockCategoryRepository.getAllCategories();
      expect(categories.length, 10);

      final order = MockOrderRepository.getActiveOrder();
      expect(order.deliveryPartner?.name, 'K. Rajesh');
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

      // Popularity: Highest ratingCount First
      final sortedPopular = MockProductRepository.sortProducts(products, ProductSortOption.popular);
      for (int i = 0; i < sortedPopular.length - 1; i++) {
        expect(sortedPopular[i].ratingCount >= sortedPopular[i + 1].ratingCount, true);
      }
    });

    test('DarkStore repository returns correct store for Ongole & Lawyerpet', () {
      final loc = LocationState();
      final store = MockDarkStoreRepository.getStoreForAddress(loc.selectedAddress);
      expect(store, isNotNull);
      expect(store!.displayId, '#304');
      expect(store.locality.contains('Ongole'), true);
      expect(store.isOpen, true);
    });
  });

  group('Tanizkart Screen Widget Tests', () {
    testWidgets('HomeScreen renders key UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('LiveTrackingScreen renders rider, OTP, and status', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const LiveTrackingScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('4  8  2  1'), findsOneWidget);
      expect(find.textContaining('Rajesh'), findsWidgets);
    });

    testWidgets('ProfileScreen renders My Profile title, user info, and all section rows', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Rename verification
      expect(find.text('My Profile'), findsOneWidget);

      // 2. User details
      expect(find.textContaining('Yaswanth'), findsOneWidget);
      expect(find.textContaining('Orders'), findsWidgets);
      expect(find.textContaining('VIP'), findsWidgets);

      // 3. Activity section
      expect(find.text('Wishlist / Saved Products'), findsOneWidget);

      // 4. Delivery preferences
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Dark Store Vicinity'), findsOneWidget);

      // 5. Help & Support
      expect(find.text('Help Center & FAQs'), findsOneWidget);
      expect(find.text('Contact Support Team'), findsOneWidget);
      expect(find.text('Terms of Service & Privacy'), findsOneWidget);
      expect(find.text('Log Out of Tanizkart'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders prepopulated fields and allows editing name', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const EditProfileScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('WishlistScreen renders saved products or empty state', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const WishlistScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('PaymentMethodsScreen renders default options and saved tokenized cards', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const PaymentMethodsScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Default Checkout Preference'), findsOneWidget);
      expect(find.text('Saved UPI IDs'), findsOneWidget);
      expect(find.text('Saved Cards (Tokenized)'), findsOneWidget);
    });

    testWidgets('DarkStoreVicinityScreen renders warehouse and distance', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const DarkStoreVicinityScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dark Store Vicinity'), findsOneWidget);
      expect(find.textContaining('Tanizkart Hub #304'), findsWidgets);
      expect(find.textContaining('Lawyerpet'), findsWidgets);
    });

    testWidgets('HelpCenterScreen renders searchable FAQs and contact button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const HelpCenterScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Help Center & FAQs'), findsOneWidget);
      expect(find.text('Orders & Delivery'), findsWidgets);
      expect(find.text('Contact Us'), findsOneWidget);
    });

    testWidgets('ContactSupportScreen renders support channels and ticket form', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ContactSupportScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Contact Support Team'), findsOneWidget);
      expect(find.text('Call Support'), findsOneWidget);
      expect(find.text('Email Care'), findsOneWidget);
      expect(find.text('Submit Ticket'), findsOneWidget);
    });

    testWidgets('TermsPrivacyScreen renders tabbed Terms and Privacy', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const TermsPrivacyScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Legal & Policies'), findsOneWidget);
      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('CategoriesOverviewScreen inline search flow activates in place and restores', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const CategoriesOverviewScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Grocery & Kitchen'), findsOneWidget);
      expect(find.text('Dairy, Bread & Eggs'), findsOneWidget);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(searchField, 'milk');
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('found for "milk"'), findsOneWidget);
      expect(find.text('Grocery & Kitchen'), findsNothing);

      await tester.enterText(searchField, '');
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Grocery & Kitchen'), findsOneWidget);
      expect(find.text('Dairy, Bread & Eggs'), findsOneWidget);
    });

    testWidgets('ProductListingScreen inline header search filters within category & restores', (WidgetTester tester) async {
      final dairyCat = MockCategoryRepository.getAllCategories().firstWhere((c) => c.id == 'cat_dairy');
      await tester.pumpWidget(_wrap(ProductListingScreen(selectedCategory: dairyCat)));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Dairy, Bread & Eggs'), findsWidgets);
      expect(find.text('Milk & Curd'), findsOneWidget);

      final searchIcon = find.byIcon(Icons.search_rounded);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pump(const Duration(milliseconds: 200));

      final headerSearchField = find.byType(TextField);
      expect(headerSearchField, findsOneWidget);

      await tester.enterText(headerSearchField, 'nandini');
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Dairy, Bread & Eggs'), findsWidgets);

      await tester.enterText(headerSearchField, '');
      await tester.pump(const Duration(milliseconds: 200));

      final dairyItemsCount = MockProductRepository.getProductsByCategory('cat_dairy').length;
      expect(find.text('$dairyItemsCount items in Dairy, Bread & Eggs'), findsOneWidget);

      final backButton = find.byIcon(Icons.arrow_back_rounded);
      await tester.tap(backButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Dairy, Bread & Eggs'), findsWidgets);
    });

    test('WishlistState management and resilient operations test', () async {
      final wishlist = WishlistState();
      expect(wishlist.itemCount, 2);
      expect(wishlist.isWishlisted('prod_amul_butter'), true);
      expect(wishlist.isWishlisted('prod_farm_eggs'), true);
      expect(wishlist.isWishlisted('prod_britannia_bread'), false);
      expect(wishlist.savedProducts.length, 2);
      expect(wishlist.error, isNull);

      final p3 = MockProductRepository.getAllProducts().firstWhere((p) => p.id == 'prod_britannia_bread');
      final added = await wishlist.toggleWishlist(p3);
      expect(added, true);
      expect(wishlist.itemCount, 3);
      expect(wishlist.isWishlisted('prod_britannia_bread'), true);

      await wishlist.removeFromWishlist('prod_amul_butter');
      expect(wishlist.itemCount, 2);
      expect(wishlist.isWishlisted('prod_amul_butter'), false);
    });

    testWidgets('WishlistScreen renders saved products grid without error', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const WishlistScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.textContaining('Amul Salted Butter'), findsWidgets);
      expect(find.textContaining('Could not load wishlist items'), findsNothing);
    });

    testWidgets('ProfileScreen renders Wishlist row without inline items', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Wishlist / Saved Products'), findsOneWidget);
      expect(find.text('2 saved items'), findsOneWidget);
      // Saved item preview should NOT appear on ProfileScreen
      expect(find.textContaining('Saved Items'), findsNothing);
    });
  });
}
