import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/product_model.dart';
import '../data/repositories/mock_product_repository.dart';

class WishlistState extends ChangeNotifier {
  // Pre-seed with actual product IDs so items appear immediately
  final Set<String> _wishlistIds = {'prod_amul_butter', 'prod_farm_eggs'};
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
    _hasError = false;
    _errorMessage = null;
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      final savedList = prefs.getStringList(key);

      if (savedList != null) {
        _wishlistIds.clear();
        _wishlistIds.addAll(savedList);
      } else {
        // Save initial default items to storage
        await prefs.setStringList(key, _wishlistIds.toList());
      }
      _isLoading = false;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      // In-memory fallback if platform channel / SharedPreferences is unavailable:
      // Keep pre-seeded in-memory items without setting error state
      _isLoading = false;
      _hasError = false;
      _errorMessage = null;
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
    // Instant optimistic UI update
    if (isCurrentlySaved) {
      _wishlistIds.remove(product.id);
    } else {
      _wishlistIds.add(product.id);
    }
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      await prefs.setStringList(key, _wishlistIds.toList());
    } catch (_) {
      // Retained in-memory if SharedPreferences write is unavailable
    }
    return !isCurrentlySaved;
  }

  Future<void> removeFromWishlist(String productId) async {
    if (!_wishlistIds.contains(productId)) return;

    _wishlistIds.remove(productId);
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(_currentUserPhone);
      await prefs.setStringList(key, _wishlistIds.toList());
    } catch (_) {
      // Retained in-memory
    }
  }

  Future<void> retry() async {
    await _initWishlist();
  }
}
