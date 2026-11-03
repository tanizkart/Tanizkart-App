import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/order_model.dart';

/// Production Supabase Service for Tanizkart Mobile App
/// Connects to Taniz Admin Supabase database instance with graceful offline fallback.
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
      debugPrint('[SupabaseService] fetchProducts failed, using local store: $e');
    }
    return null;
  }

  /// Inserts a newly placed order into the Supabase 'orders' collection/table
  Future<bool> createOrderInSupabase({
    required Order order,
    String customerName = 'K. Rajesh (Customer)',
    String customerPhone = '+91 98765 43210',
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
        'customer_id': '00000000-0000-0000-0000-000000000001',
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': 'customer@tanizkart.com',
        'delivery_address': {
          'address': order.deliveryAddress,
          'instructions': order.deliveryInstructions,
          'otp': order.deliveryOtp,
        },
        'service_area_name': 'Ongole Central',
        'warehouse_name': order.hubLocation.label,
        'items': itemsJson,
        'subtotal': order.subtotal,
        'mrp_total': order.billSummary.mrpSubtotal,
        'total_discount': order.discount,
        'delivery_fee': order.deliveryFee,
        'premium_free_delivery': order.deliveryFee == 0.0,
        'grand_total': order.total,
        'status': order.status.displayTitle,
        'payment_status': order.paymentStatus == PaymentStatus.paid ? 'Paid' : 'Pending',
        'payment_method': order.paymentMethod == PaymentMethod.cod ? 'Cash on Delivery' : 'UPI Instant',
        'transaction_ref': order.transactionId ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'assigned_delivery_partner_id': order.deliveryPartner != null ? '00000000-0000-0000-0000-000000000002' : null,
        'assigned_delivery_partner_name': order.deliveryPartner?.name,
        'notes': order.customInstruction,
      };

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

  /// Updates an order's status in Supabase
  Future<bool> updateOrderStatusInSupabase(String orderNumber, String status, {String? notes}) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/orders?order_number=eq.$orderNumber');
      final payload = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
        'notes': ?notes,
      };

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
  Future<List<Map<String, dynamic>>?> fetchOrdersFromSupabase() async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/orders?select=*&order=created_at.desc');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(res.body);
        _isOnline = true;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[SupabaseService] fetchOrdersFromSupabase fallback: $e');
    }
    return null;
  }
}
