import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/motion.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/coupon_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/payment_service.dart';
import '../../../shared/widgets/add_to_cart_stepper.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../../state/cart_state.dart';
import '../../../state/location_state.dart';
import '../../../state/payment_state.dart';
import '../../../state/auth_state.dart';
import '../../tracking/screens/live_tracking_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  final Set<String> _selectedInstructions = {'Leave at Door'};
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _customInstructionController = TextEditingController();
  bool _showCustomInstructionField = false;
  bool _isProcessingPayment = false;
  String? _checkoutErrorMessage;

  final List<String> _instructions = [
    'Leave at Door',
    'Do Not Ring Bell',
    'Call Upon Arrival',
    'Avoid Calling',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = PaymentMethod.values[context.read<PaymentState>().selectedMethodIndex.clamp(0, PaymentMethod.values.length - 1)];
  }

  @override
  void dispose() {
    _couponController.dispose();
    _customInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cart, _) {
        final summary = cart.billSummary;

        return Scaffold(
          backgroundColor: TanizColors.canvasBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Text(
                  'Cart & Checkout',
                  style: TanizTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: TanizColors.blueContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.totalItems} Items',
                    style: TanizTypography.labelSmall.copyWith(
                      color: TanizColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: cart.isEmpty
              ? _buildEmptyCart(context)
              : Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_checkoutErrorMessage != null) ...[
                            _buildErrorBanner(_checkoutErrorMessage!),
                            const SizedBox(height: 12),
                          ],

                          // 1. Delivery Address Card
                          _buildDeliveryAddressCard(context),

                          const SizedBox(height: 16),

                          // 2. Cart Items Section
                          _buildOrderItemsSection(cart),

                          const SizedBox(height: 16),

                          // 3. Delivery Instructions
                          _buildDeliveryInstructionsSection(),

                          const SizedBox(height: 16),

                          // 4. Coupons & Offers
                          _buildCouponsSection(context, cart),

                          const SizedBox(height: 16),

                          // 5. Authoritative Bill Summary
                          _buildBillSummaryCard(cart),

                          const SizedBox(height: 16),

                          // 6. Payment Method Selector
                          _buildPaymentMethodSection(),

                          const SizedBox(height: 16),

                          // 7. Security & Trust Badge
                          _buildTrustBadge(),
                        ],
                      ),
                    ),

                    // Sticky Bottom Payment Dock
                    _buildBottomPaymentDock(context, cart),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TanizColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TanizColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: TanizColors.errorRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TanizTypography.bodySmall.copyWith(
                color: TanizColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16, color: TanizColors.errorRed),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _checkoutErrorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(BuildContext context) {
    return Consumer<LocationState>(
      builder: (context, locState, _) {
        final activeAddr = locState.selectedAddress;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TanizColors.borderSubtle),
            boxShadow: [TanizColors.cardShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TanizColors.greenContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TanizColors.greenBorder),
                ),
                child: const Icon(
                  Icons.electric_moped_rounded,
                  color: TanizColors.rapidGreenDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Delivery to ${activeAddr.tag}',
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TanizColors.blueContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '10-12 MINS',
                            style: TanizTypography.labelSmall.copyWith(
                              fontSize: 9,
                              color: TanizColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeAddr.fullAddress,
                      style: TanizTypography.bodySmall.copyWith(
                        color: TanizColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TanizTappable(
                borderRadius: BorderRadius.circular(8),
                onTap: () => AddressBottomSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    'Change',
                    style: TanizTypography.labelLarge.copyWith(
                      color: TanizColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItemsSection(CartState cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Items (${cart.itemsList.length})',
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${cart.totalItemCount} units',
              style: TanizTypography.bodySmall.copyWith(
                color: TanizColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TanizColors.borderSubtle),
            boxShadow: [TanizColors.cardShadow],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: cart.itemsList.length,
            separatorBuilder: (_, _) => const Divider(height: 20, color: TanizColors.borderSubtle),
            itemBuilder: (context, index) {
              final item = cart.itemsList[index];
              final p = item.product;

              return Row(
                children: [
                  // Product Packshot
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TanizColors.borderSubtle),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: p.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const TanizShimmerBox(
                          width: 60,
                          height: 60,
                          borderRadius: 14,
                        ),
                        errorWidget: (c, u, e) => Container(
                          color: TanizColors.surfaceLow,
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 24,
                              color: TanizColors.primaryBlue.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title, pack size, price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.packSize,
                          style: TanizTypography.bodySmall.copyWith(
                            color: TanizColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.format(item.totalPrice),
                              style: TanizTypography.titleMedium.copyWith(
                                color: TanizColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (item.totalOriginalPrice > item.totalPrice)
                              Text(
                                CurrencyFormatter.format(item.totalOriginalPrice),
                                style: TanizTypography.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: TanizColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stepper Quantity Control
                  AddToCartStepper(
                    quantity: item.quantity,
                    onAdd: () => cart.addItem(p),
                    onIncrement: () => cart.addItem(p),
                    onDecrement: () => cart.removeItem(p),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Instructions',
          style: TanizTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _instructions.map((inst) {
            final isSelected = _selectedInstructions.contains(inst);
            return FilterChip(
              label: Text(inst),
              selected: isSelected,
              selectedColor: TanizColors.blueContainer,
              checkmarkColor: TanizColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(
                color: isSelected ? TanizColors.primaryBlue : TanizColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11.5,
              ),
              side: BorderSide(
                color: isSelected ? TanizColors.primaryBlue : TanizColors.borderSubtle,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedInstructions.add(inst);
                  } else {
                    _selectedInstructions.remove(inst);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (!_showCustomInstructionField)
          TextButton.icon(
            onPressed: () => setState(() => _showCustomInstructionField = true),
            icon: const Icon(Icons.add_comment_outlined, size: 16, color: TanizColors.primaryBlue),
            label: Text(
              'Add specific gate/door instruction',
              style: TanizTypography.labelSmall.copyWith(
                color: TanizColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TanizColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customInstructionController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Ring buzzer 302 or leave with security',
                      hintStyle: TextStyle(fontSize: 12, color: TanizColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: TanizColors.rapidGreenDark, size: 20),
                  onPressed: () => setState(() => _showCustomInstructionField = false),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCouponsSection(BuildContext context, CartState cart) {
    final summary = cart.billSummary;
    final hasActiveDiscount = summary.couponDiscount > 0;
    final appliedCoupon = cart.appliedCoupon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasActiveDiscount ? TanizColors.rapidGreen : TanizColors.borderSubtle,
          width: hasActiveDiscount ? 1.5 : 1,
        ),
        boxShadow: [TanizColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasActiveDiscount ? TanizColors.greenContainer : TanizColors.amberBadgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  color: hasActiveDiscount ? TanizColors.rapidGreenDark : TanizColors.goldenAmberDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasActiveDiscount
                          ? 'Coupon \'${appliedCoupon!.code}\' Applied!'
                          : (appliedCoupon != null
                              ? 'Coupon \'${appliedCoupon.code}\' Ineligible'
                              : 'Apply Coupons & Offers'),
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasActiveDiscount ? TanizColors.rapidGreenDark : TanizColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasActiveDiscount
                          ? 'You are saving ₹${summary.couponDiscount.toInt()} on items subtotal'
                          : (summary.couponIneligibilityReason ?? 'Select an eligible offer below'),
                      style: TanizTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: hasActiveDiscount
                            ? TanizColors.rapidGreenDark
                            : (appliedCoupon != null ? TanizColors.errorRed : TanizColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              if (appliedCoupon != null)
                TextButton(
                  onPressed: () => cart.removeCoupon(),
                  child: const Text('Remove', style: TextStyle(color: TanizColors.errorRed, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Coupon offer chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Coupon.availableCoupons.map((coupon) {
              final isThisApplied = appliedCoupon?.code == coupon.code && hasActiveDiscount;
              final isEligible = summary.itemsSubtotal >= coupon.minOrderAmount;

              return ActionChip(
                avatar: Icon(
                  isThisApplied ? Icons.check_circle_rounded : Icons.local_offer_rounded,
                  size: 14,
                  color: isThisApplied
                      ? Colors.white
                      : (isEligible ? TanizColors.primaryBlue : TanizColors.textMuted),
                ),
                label: Text(
                  '${coupon.code} (₹${coupon.discountAmount.toInt()} OFF on ₹${coupon.minOrderAmount.toInt()}+)',
                ),
                backgroundColor: isThisApplied
                    ? TanizColors.rapidGreen
                    : (isEligible ? TanizColors.blueContainer : TanizColors.surfaceLow),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                labelStyle: TextStyle(
                  color: isThisApplied
                      ? Colors.white
                      : (isEligible ? TanizColors.primaryBlue : TanizColors.textMuted),
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
                side: BorderSide(
                  color: isThisApplied
                      ? TanizColors.rapidGreen
                      : (isEligible ? TanizColors.primaryBlue.withValues(alpha: 0.3) : TanizColors.borderSubtle),
                ),
                onPressed: () {
                  final result = cart.applyCoupon(coupon.code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: result.isSuccess ? TanizColors.rapidGreen : TanizColors.textPrimary,
                      duration: const Duration(seconds: 2),
                      content: Text(result.message),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(CartState cart) {
    final summary = cart.billSummary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TanizColors.borderSubtle),
        boxShadow: [TanizColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bill Summary',
                style: TanizTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (summary.totalSavings > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: TanizColors.greenContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Saved ${CurrencyFormatter.format(summary.totalSavings)}',
                    style: TanizTypography.labelSmall.copyWith(
                      color: TanizColors.rapidGreenDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          _buildBillRow('Item Total (MRP)', CurrencyFormatter.format(summary.mrpSubtotal)),
          const SizedBox(height: 8),

          if (summary.warehouseDiscount > 0) ...[
            _buildBillRow(
              'Warehouse Direct Discount',
              '- ${CurrencyFormatter.format(summary.warehouseDiscount)}',
              isDiscount: true,
            ),
            const SizedBox(height: 8),
          ],

          _buildBillRow('Subtotal', CurrencyFormatter.format(summary.itemsSubtotal)),
          const SizedBox(height: 8),

          _buildBillRow('Handling Charge', CurrencyFormatter.format(summary.handlingFee)),
          const SizedBox(height: 8),

          _buildBillRow(
            'Delivery Fee',
            summary.deliveryFee == 0.0 ? 'FREE' : CurrencyFormatter.format(summary.deliveryFee),
            isFree: summary.deliveryFee == 0.0,
          ),

          if (summary.couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Coupon Discount (${summary.appliedCoupon?.code ?? ''})',
              '- ${CurrencyFormatter.format(summary.couponDiscount)}',
              isDiscount: true,
            ),
          ],

          const Divider(height: 24, color: TanizColors.borderSubtle),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Pay',
                    style: TanizTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Inclusive of all taxes & fees',
                    style: TanizTypography.caption,
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.format(summary.totalPayable),
                style: TanizTypography.priceLarge.copyWith(
                  fontSize: 22,
                  color: TanizColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TanizTypography.bodyMedium.copyWith(
            color: isDiscount ? TanizColors.rapidGreenDark : TanizColors.textSecondary,
            fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TanizTypography.titleMedium.copyWith(
            fontSize: 13,
            color: isFree
                ? TanizColors.rapidGreenDark
                : (isDiscount ? TanizColors.rapidGreenDark : TanizColors.textPrimary),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TanizTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),

        _buildPaymentOption(
          method: PaymentMethod.upi,
          title: 'UPI (Google Pay, PhonePe, Paytm, CRED)',
          subtitle: 'Instant authorization with zero transaction fees',
          icon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: 8),

        _buildPaymentOption(
          method: PaymentMethod.card,
          title: 'Credit / Debit Cards',
          subtitle: 'Visa, Mastercard, RuPay & Corporate',
          icon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 8),

        _buildPaymentOption(
          method: PaymentMethod.cod,
          title: 'Pay on Delivery (Cash / UPI at door)',
          subtitle: 'Pay via QR scan or cash to delivery hero upon arrival',
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return TanizTappable(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        context.read<PaymentState>().setDefaultMethod(method.index);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TanizColors.primaryBlue : TanizColors.borderSubtle,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [TanizColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? TanizColors.primaryBlue : TanizColors.textMuted,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TanizTypography.titleMedium.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TanizTypography.bodySmall.copyWith(
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: isSelected ? TanizColors.primaryBlue : TanizColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_outlined, size: 16, color: TanizColors.rapidGreenDark),
          const SizedBox(width: 6),
          Text(
            '100% Safe & Secure Payments • 10-Minute Dark Store Fulfillment',
            style: TanizTypography.caption.copyWith(
              color: TanizColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentDock(BuildContext context, CartState cart) {
    final summary = cart.billSummary;
    final isFree = summary.isLegitimatelyFree;
    final buttonText = _isProcessingPayment
        ? 'Verifying Order...'
        : (isFree
            ? 'Confirm Free Order'
            : 'Proceed to Pay ${CurrencyFormatter.format(summary.totalPayable)}');

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [TanizColors.floatingShadow],
          border: const Border(
            top: BorderSide(color: TanizColors.borderSubtle),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Payable',
                    style: TanizTypography.caption,
                  ),
                  Text(
                    CurrencyFormatter.format(summary.totalPayable),
                    style: TanizTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: TanizColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TanizTappable(
                borderRadius: BorderRadius.circular(12),
                onTap: _isProcessingPayment ? null : () => _handleProceedToCheckout(cart),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: TanizColors.blueGoldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [TanizColors.softShadow],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isProcessingPayment) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        buttonText,
                        style: TanizTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      if (!_isProcessingPayment) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleProceedToCheckout(CartState cart) async {
    final locState = Provider.of<LocationState>(context, listen: false);
    final authState = Provider.of<AuthState>(context, listen: false);

    // 1. Validation: Address check
    if (locState.selectedAddress.fullAddress.trim().isEmpty) {
      setState(() => _checkoutErrorMessage = 'Please select a valid delivery address.');
      AddressBottomSheet.show(context);
      return;
    }

    // 2. Validation: Cart empty check
    if (cart.isEmpty) {
      setState(() => _checkoutErrorMessage = 'Your cart is empty. Add items to checkout.');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _checkoutErrorMessage = null;
    });

    // 3. Prepare idempotency key and authoritative pricing
    final idempotencyKey = 'idemp-${DateTime.now().millisecondsSinceEpoch}-${cart.itemsList.length}';
    final summary = cart.billSummary;

    // 4. Show Payment Processing Sheet for real user feedback
    final result = await _showPaymentModal(
      context: context,
      amount: summary.totalPayable,
      method: _selectedPaymentMethod,
      phone: authState.phoneNumber,
    );

    if (!mounted) return;

    if (result != null && result.isSuccess) {
      // 5. Authoritative order creation in OrderRepository
      final customInstruction = _customInstructionController.text.trim().isNotEmpty
          ? _customInstructionController.text.trim()
          : null;

      final newOrder = await cart.placeOrder(
        idempotencyKey: idempotencyKey,
        deliveryAddress: locState.selectedAddress.fullAddress,
        deliveryInstructions: _selectedInstructions.toList(),
        customInstruction: customInstruction,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: PaymentStatus.paid,
        transactionId: result.transactionId,
      );

      if (!mounted) return;
      setState(() => _isProcessingPayment = false);

      // 6. Navigate to Live Tracking with real order
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LiveTrackingScreen(order: newOrder),
        ),
      );
    } else {
      setState(() {
        _isProcessingPayment = false;
        _checkoutErrorMessage = result?.errorMessage ?? 'Payment was cancelled. You can retry with another method.';
      });
    }
  }

  Future<PaymentResult?> _showPaymentModal({
    required BuildContext context,
    required double amount,
    required PaymentMethod method,
    required String phone,
  }) async {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _PaymentProcessingModal(
          amount: amount,
          method: method,
          phone: phone,
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: TanizColors.blueContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              size: 44,
              color: TanizColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Tanizkart basket is empty',
            style: TanizTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add fresh essentials from Dark Store #304',
            style: TanizTypography.bodyMedium,
          ),
          const SizedBox(height: 20),
          TanizTappable(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: TanizColors.blueGoldGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [TanizColors.softShadow],
              ),
              child: Text(
                'Start Shopping',
                style: TanizTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentProcessingModal extends StatefulWidget {
  final double amount;
  final PaymentMethod method;
  final String phone;

  const _PaymentProcessingModal({
    required this.amount,
    required this.method,
    required this.phone,
  });

  @override
  State<_PaymentProcessingModal> createState() => _PaymentProcessingModalState();
}

class _PaymentProcessingModalState extends State<_PaymentProcessingModal> {
  String _statusText = 'Contacting payment gateway...';
  bool _hasFailed = false;
  String? _failureReason;

  @override
  void initState() {
    super.initState();
    _executePayment();
  }

  Future<void> _executePayment() async {
    setState(() {
      _hasFailed = false;
      _failureReason = null;
      _statusText = widget.method == PaymentMethod.cod
          ? 'Confirming Pay on Delivery booking...'
          : 'Authorizing ${CurrencyFormatter.format(widget.amount)} with bank...';
    });

    final result = await PaymentService.processPayment(
      orderId: 'TK-${DateTime.now().millisecondsSinceEpoch}',
      amount: widget.amount,
      method: widget.method,
      customerPhone: widget.phone,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _statusText = 'Payment verified! Creating order...');
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.pop(context, result);
      }
    } else {
      setState(() {
        _hasFailed = true;
        _failureReason = result.errorMessage ?? 'Payment failed. Please retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          if (!_hasFailed) ...[
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: TanizColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Secure Payment Gateway',
              style: TanizTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _statusText,
              style: TanizTypography.bodyMedium.copyWith(color: TanizColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: TanizColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: TanizColors.errorRed, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Authorization Failed',
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: TanizColors.errorRed,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _failureReason ?? 'An error occurred during payment verification.',
              style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Change Method'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _executePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TanizColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retry Payment', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
