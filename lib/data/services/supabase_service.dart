import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

/// Production Supabase Service for Tanizkart Mobile App
/// Connects to Taniz Admin Supabase database instance with graceful offline fallback & local caching.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://zeyblntgsxzyvochkybf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleWJsbnRnc3h6eXZvY2hreWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2NjY0OTUsImV4cCI6MjEwNjI0MjQ5NX0.0LF0Rd3_Ua3RRfBDNkjla2lHGB_4sdxVJmh0Rx0Dxzs';

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  /// Verifies Supabase reachability
  Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/products?select=id&limit=1');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));
      _isOnline = (res.statusCode >= 200 && res.statusCode < 300);
      return _isOnline;
    } catch (e) {
      debugPrint('[SupabaseService] Offline or paused: $e');
      _isOnline = false;
      return false;
    }
  }

  /// Fetches products from Supabase 'products' table
  Future<List<Product>?> fetchProducts() async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/products?select=*&is_active=eq.true');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(res.body);
        _isOnline = true;
        if (data.isEmpty) return null;
        return data.map((item) {
          final double price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
          final double mrp = (item['mrp'] is num) ? (item['mrp'] as num).toDouble() : price;
          final int discount = (item['discount'] is num) ? (item['discount'] as num).toInt() : 0;
          return Product(
            id: item['id']?.toString() ?? '',
            name: item['name']?.toString() ?? 'Product',
            brand: item['brand']?.toString() ?? 'Tanizkart',
            packSize: item['pack_size']?.toString() ?? 'Standard',
            price: price,
            originalPrice: mrp,
            discountPercent: discount,
            imageUrl: item['image']?.toString() ?? '',
            categoryId: item['category']?.toString() ?? 'cat_groceries',
            subcategory: 'All',
            description: item['description']?.toString() ?? '',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[SupabaseService] fetchProducts fallback: $e');
    }
    return null;
  }

  // ===========================================================================
  // 1. USER CART SYNCHRONIZATION (Supabase + Local Debounced Sync)
  // ===========================================================================

  /// Debounce-sync active cart payload to Supabase & persistent storage
  Future<bool> syncCartToSupabase({
    required String customerId,
    required List<CartItem> items,
  }) async {
    final serializedItems = items.map((item) {
      return {
        'product_id': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'pack_size': item.product.packSize,
        'image': item.product.imageUrl,
      };
    }).toList();

    // Cache locally first for instantaneous offline persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('taniz_cart_$customerId', jsonEncode(serializedItems));
    } catch (e) {
      debugPrint('[SupabaseService] Local cart cache fallback: $e');
    }

    // Push to Supabase 'carts' table if reachable
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/carts');
      final payload = {
        'customer_id': customerId,
        'items': serializedItems,
        'total_items': items.fold(0, (sum, i) => sum + i.quantity),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final headers = Map<String, String>.from(_headers)
        ..['Prefer'] = 'resolution=merge-duplicates';

      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _isOnline = true;
        debugPrint('[SupabaseService] Cart synced to Supabase for customer $customerId');
        return true;
      }
    } catch (e) {
      debugPrint('[SupabaseService] syncCartToSupabase offline fallback: $e');
    }

    return false;
  }

  /// Fetches saved cart for the user upon login from Supabase or local cache
  Future<List<Map<String, dynamic>>?> fetchUserCartFromSupabase(String customerId) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/carts?customer_id=eq.$customerId&select=*');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 4));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> list = jsonDecode(res.body);
        if (list.isNotEmpty && list.first['items'] != null) {
          final items = list.first['items'] as List<dynamic>;
          _isOnline = true;
          return items.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('[SupabaseService] fetchUserCartFromSupabase offline: $e');
    }

    // Fallback to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('taniz_cart_$customerId');
      if (cached != null) {
        final List<dynamic> list = jsonDecode(cached);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[SupabaseService] Local cart read error: $e');
    }

    return null;
  }

  /// Empties user's cart in Supabase & local storage
  Future<bool> clearUserCartInSupabase(String customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('taniz_cart_$customerId');
    } catch (_) {}

    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/carts?customer_id=eq.$customerId');
      final res = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 4));
      return (res.statusCode >= 200 && res.statusCode < 300);
    } catch (e) {
      debugPrint('[SupabaseService] clearUserCartInSupabase error: $e');
    }
    return false;
  }

  // ===========================================================================
  // 2. ORDER PLACEMENT & SYNCHRONIZATION (Supabase 'orders' table)
  // ===========================================================================

  /// Inserts a newly placed order into the Supabase 'orders' collection/table
  Future<bool> createOrderInSupabase({
    required Order order,
    String? customerName,
    String? customerPhone,
    String? customerId,
  }) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/orders');
      final itemsJson = order.items.map((item) {
        return {
          'id': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'mrp': item.product.originalPrice,
          'quantity': item.quantity,
          'pack_size': item.product.packSize,
          'image': item.product.imageUrl,
          'total': item.product.price * item.quantity,
        };
      }).toList();

      final payload = {
        'order_number': order.id,
        'customer_id': customerId ?? order.customerId,
        'customer_name': customerName ?? order.customerName,
        'customer_phone': customerPhone ?? order.customerPhone,
        'customer_email': 'customer@tanizkart.com',
        'delivery_address': order.deliveryAddress,
        'delivery_instructions': order.deliveryInstructions,
        'warehouse_id': order.warehouseId,
        'warehouse_name': order.hubLocation.label,
        'items': itemsJson,
        'subtotal': order.subtotal,
        'delivery_fee': order.deliveryFee,
        'grand_total': order.total,
        'status': 'Pending',
        'payment_status': order.paymentStatus == PaymentStatus.paid ? 'Paid' : 'COD',
        'delivery_otp': order.deliveryOtp ?? '1234',
        'created_at': DateTime.now().toIso8601String(),
        'assigned_delivery_partner_id': order.deliveryPartner != null ? '00000000-0000-0000-0000-000000000002' : null,
        'assigned_delivery_partner_name': order.deliveryPartner?.name,
        'notes': order.customInstruction,
      };

      // Always cache order payload locally for instantaneous offline resilience
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('taniz_supabase_offline_orders') ?? '[]';
        final List<dynamic> list = jsonDecode(raw);
        list.removeWhere((item) => item['order_number'] == order.id);
        list.insert(0, payload);
        await prefs.setString('taniz_supabase_offline_orders', jsonEncode(list));
      } catch (_) {}

      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        debugPrint('[SupabaseService] Order ${order.id} saved to Supabase successfully.');
        _isOnline = true;
        return true;
      }
    } catch (e) {
      debugPrint('[SupabaseService] createOrderInSupabase fallback: $e');
    }
    return false;
  }

  /// Updates an order's status in Supabase (e.g. Accepted -> Out for Delivery -> Delivered via OTP)
  Future<bool> updateOrderStatusInSupabase(
    String orderNumber,
    String status, {
    String? notes,
    String? deliveryPartnerName,
    String? deliveryPartnerId,
  }) async {
    // Update local offline cache as well
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('taniz_supabase_offline_orders');
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        for (final item in list) {
          if (item['order_number'] == orderNumber) {
            item['status'] = status;
            item['updated_at'] = DateTime.now().toIso8601String();
            if (notes != null) item['notes'] = notes;
            if (deliveryPartnerName != null) item['assigned_delivery_partner_name'] = deliveryPartnerName;
          }
        }
        await prefs.setString('taniz_supabase_offline_orders', jsonEncode(list));
      }
    } catch (_) {}

    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/orders?order_number=eq.$orderNumber');
      final payload = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (notes != null) payload['notes'] = notes;
      if (deliveryPartnerName != null) {
        payload['assigned_delivery_partner_name'] = deliveryPartnerName;
      }
      if (deliveryPartnerId != null) {
        payload['assigned_delivery_partner_id'] = deliveryPartnerId;
      }

      final res = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        debugPrint('[SupabaseService] Order $orderNumber status updated to $status in Supabase.');
        _isOnline = true;
        return true;
      }
    } catch (e) {
      debugPrint('[SupabaseService] updateOrderStatusInSupabase fallback: $e');
    }
    return false;
  }

  /// Fetches orders from Supabase for Delivery Guy portal
  Future<List<Map<String, dynamic>>?> fetchOrdersFromSupabase({
    String warehouseId = 'wh_lawyerpet_304',
    bool activeOnly = false,
  }) async {
    try {
      var query = 'order=created_at.desc';
      if (activeOnly) {
        query += '&status=neq.Delivered';
      }
      final uri = Uri.parse('$supabaseUrl/rest/v1/orders?$query');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(res.body);
        _isOnline = true;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[SupabaseService] fetchOrdersFromSupabase fallback: $e');
    }

    // Fallback to local offline cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('taniz_supabase_offline_orders');
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    return null;
  }
}
