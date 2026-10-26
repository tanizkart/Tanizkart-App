import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/product_model.dart';
import '../data/repositories/mock_product_repository.dart';

class WishlistState extends ChangeNotifier {
  final Set<String> _wishlistIds = {};
  String _currentUserPhone = '+91 98480 22338';
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  WishlistState() {
    _initWishlist();
  }

  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String? get error => _hasError ? (_errorMessage ?? 'Something went wrong') : null;
  int get itemCount => _wishlistIds.length;
  bool get isEmpty => _wishlistIds.isEmpty;

  List<Product> get items {
    final all = MockProductRepository.getAllProducts();
    return all.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  List<Product> get savedProducts => items;

  bool isWishlisted(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> clearWishlist() async {
    _wishlistIds.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      await prefs.setStringList(key, []);
    } catch (_) {}
  }

  String _getStorageKey(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    return 'tanizkart_wishlist_$clean';
  }

  Future<void> _initWishlist() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      final savedList = prefs.getStringList(key);

      _wishlistIds.clear();
      if (savedList != null && savedList.isNotEmpty) {
        _wishlistIds.addAll(savedList);
      } else {
        // Pre-populate 2 initial items for initial active demonstration if fresh install
        _wishlistIds.addAll(['prod_dairy_1', 'prod_dairy_3']);
        await prefs.setStringList(key, _wishlistIds.toList());
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Could not load wishlist items: $e';
      notifyListeners();
    }
  }

  Future<void> setUser(String phone) async {
    if (_currentUserPhone == phone) return;
    _currentUserPhone = phone;
    await _initWishlist();
  }

  Future<bool> toggleWishlist(
    Product product, {
    bool isAuthenticated = true,
    VoidCallback? onRequireLogin,
  }) async {
    if (!isAuthenticated) {
      onRequireLogin?.call();
      return false;
    }

    final isCurrentlySaved = _wishlistIds.contains(product.id);
    // Optimistic UI update
    if (isCurrentlySaved) {
      _wishlistIds.remove(product.id);
    } else {
      _wishlistIds.add(product.id);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      await prefs.setStringList(key, _wishlistIds.toList());
      return !isCurrentlySaved;
    } catch (e) {
      // Revert optimistic update on failure
      if (isCurrentlySaved) {
        _wishlistIds.add(product.id);
      } else {
        _wishlistIds.remove(product.id);
      }
      _hasError = true;
      _errorMessage = 'Failed to update wishlist. Please try again.';
      notifyListeners();
      return isCurrentlySaved;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    if (!_wishlistIds.contains(productId)) return;

    _wishlistIds.remove(productId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      await prefs.setStringList(key, _wishlistIds.toList());
    } catch (_) {
      // Ignore background persistence failure
    }
  }

  Future<void> retry() async {
    await _initWishlist();
  }
}
