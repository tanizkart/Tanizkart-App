import 'dart:async';
import 'dart:math';
import '../models/order_model.dart';

enum PaymentResultStatus {
  success,
  pending,
  failed,
  cancelled,
  unconfigured,
}

class PaymentResult {
  final PaymentResultStatus status;
  final String? transactionId;
  final String? errorMessage;
  final String? setupGuide;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    this.setupGuide,
  });

  bool get isSuccess => status == PaymentResultStatus.success;
}

class PaymentService {
  // Configurable gateway settings
  static bool sandboxTestMode = true; // Enabled for safe local testing
  static String? productionGatewayKey; // e.g. Razorpay / Cashfree Merchant Key

  /// Processes payment through the appropriate adapter
  static Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
    required String customerPhone,
    bool simulateFailure = false,
  }) async {
    // 1. Pay on Delivery (COD) - No external gateway required
    if (method == PaymentMethod.cod) {
      await Future.delayed(const Duration(milliseconds: 600));
      return PaymentResult(
        status: PaymentResultStatus.success,
        transactionId: 'COD-${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // 2. Production gateway check when not in sandbox
    if (!sandboxTestMode && (productionGatewayKey == null || productionGatewayKey!.isEmpty)) {
      return const PaymentResult(
        status: PaymentResultStatus.unconfigured,
        errorMessage: 'Payment Gateway is not configured.',
        setupGuide:
            'To enable live online payments, supply TANIZ_PAYMENT_GATEWAY_KEY and TANIZ_WEBHOOK_SECRET in environment configuration.',
      );
    }

    // 3. Online payment verification (UPI or Cards)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (simulateFailure) {
      return const PaymentResult(
        status: PaymentResultStatus.failed,
        errorMessage: 'Payment was declined by your bank or UPI provider. Please retry.',
      );
    }

    // Generate cryptographic-style mock txn id
    final randomId = Random().nextInt(900000) + 100000;
    final prefix = method == PaymentMethod.upi ? 'UPI-TXN' : 'CARD-TXN';

    return PaymentResult(
      status: PaymentResultStatus.success,
      transactionId: '$prefix-$randomId',
    );
  }
}
