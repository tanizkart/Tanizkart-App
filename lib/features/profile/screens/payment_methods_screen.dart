import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../state/payment_state.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: TanizTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<PaymentState>(
        builder: (context, paymentState, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TanizColors.blueContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TanizColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: TanizColors.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'TanizKart uses RBI-compliant tokenization for all payments. We never store your CVV or UPI PIN.',
                          style: TanizTypography.bodySmall.copyWith(
                            color: TanizColors.navyDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 1. Default Checkout Preference
                Text(
                  'Default Checkout Preference',
                  style: TanizTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose which payment option is auto-selected during 10-minute express checkout.',
                  style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TanizColors.borderSubtle),
                    boxShadow: [TanizColors.cardShadow],
                  ),
                  child: Column(
                    children: [
                      _buildDefaultOptionTile(
                        context: context,
                        index: 0,
                        title: 'UPI (Instant UPI Intent / QR)',
                        subtitle: 'Google Pay, PhonePe, Paytm, CRED',
                        icon: Icons.account_balance_wallet_rounded,
                        selectedIndex: paymentState.selectedMethodIndex,
                        onTap: () => paymentState.setDefaultMethod(0),
                      ),
                      const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                      _buildDefaultOptionTile(
                        context: context,
                        index: 1,
                        title: 'Credit / Debit Cards',
                        subtitle: 'Visa, Mastercard, RuPay cards',
                        icon: Icons.credit_card_rounded,
                        selectedIndex: paymentState.selectedMethodIndex,
                        onTap: () => paymentState.setDefaultMethod(1),
                      ),
                      const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                      _buildDefaultOptionTile(
                        context: context,
                        index: 2,
                        title: 'Pay on Delivery (COD / UPI at door)',
                        subtitle: 'Cash or scan delivery partner QR code',
                        icon: Icons.payments_rounded,
                        selectedIndex: paymentState.selectedMethodIndex,
                        onTap: () => paymentState.setDefaultMethod(2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Saved UPI Accounts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved UPI IDs',
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddUpiDialog(context, paymentState),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add UPI'),
                      style: TextButton.styleFrom(
                        foregroundColor: TanizColors.primaryBlue,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TanizColors.borderSubtle),
                    boxShadow: [TanizColors.cardShadow],
                  ),
                  child: paymentState.savedUpiList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No saved UPI IDs yet. Add your UPI ID for one-tap checkout.',
                              style: TextStyle(color: TanizColors.textMuted, fontSize: 12.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paymentState.savedUpiList.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                          itemBuilder: (context, index) {
                            final upi = paymentState.savedUpiList[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: TanizColors.blueContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'UPI',
                                    style: TextStyle(
                                      color: TanizColors.primaryBlue,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    upi.vpa,
                                    style: TanizTypography.titleMedium.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (upi.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: TanizColors.greenContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'DEFAULT',
                                        style: TanizTypography.labelSmall.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: TanizColors.rapidGreenDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                'Verified by NPCI',
                                style: TanizTypography.caption.copyWith(color: TanizColors.rapidGreenDark),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: TanizColors.textMuted, size: 20),
                                onPressed: () {
                                  _confirmDelete(
                                    context,
                                    title: 'Remove UPI ID',
                                    message: 'Remove ${upi.vpa} from your saved payment methods?',
                                    onConfirm: () => paymentState.removeUpi(upi.id),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 24),

                // 3. Saved Cards (RBI Tokenized)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Cards (Tokenized)',
                      style: TanizTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddCardDialog(context, paymentState),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Card'),
                      style: TextButton.styleFrom(
                        foregroundColor: TanizColors.primaryBlue,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TanizColors.borderSubtle),
                    boxShadow: [TanizColors.cardShadow],
                  ),
                  child: paymentState.savedCards.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No saved cards. Add a card to securely tokenize for quick checkout.',
                              style: TextStyle(color: TanizColors.textMuted, fontSize: 12.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paymentState.savedCards.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                          itemBuilder: (context, index) {
                            final card = paymentState.savedCards[index];
                            return ListTile(
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: card.brand == 'Visa' ? const Color(0xFF1A1F71) : const Color(0xFFEB001B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.credit_card_rounded,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    size: 22,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    '${card.bank} ${card.maskedNumber}',
                                    style: TanizTypography.titleMedium.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF2F6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      card.brand,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: TanizColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${card.cardHolder} • Exp: ${card.expiryMonth}/${card.expiryYear.length == 4 ? card.expiryYear.substring(2) : card.expiryYear}',
                                style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: TanizColors.textMuted, size: 20),
                                onPressed: () {
                                  _confirmDelete(
                                    context,
                                    title: 'Remove Saved Card',
                                    message: 'Remove ${card.bank} ${card.maskedNumber}?',
                                    onConfirm: () => paymentState.removeCard(card.id),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 24),

                // NetBanking Information
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TanizColors.borderSubtle),
                    boxShadow: [TanizColors.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: TanizColors.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Banking Supported at Checkout',
                              style: TanizTypography.titleMedium.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Supported for 50+ banks via payment gateway during checkout.',
                              style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // PCI-DSS Trust Badge
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, size: 14, color: TanizColors.rapidGreenDark),
                      const SizedBox(width: 6),
                      Text(
                        '100% Safe & Secure • PCI-DSS Level 1 Compliant',
                        style: TanizTypography.caption.copyWith(
                          color: TanizColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultOptionTile({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? TanizColors.primaryBlue : TanizColors.textMuted,
                  width: isSelected ? 6.5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Icon(icon, color: isSelected ? TanizColors.primaryBlue : TanizColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TanizTypography.titleMedium.copyWith(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? TanizColors.primaryBlue : TanizColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required String title, required String message, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: TanizColors.errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddUpiDialog(BuildContext context, PaymentState paymentState) {
    final vpaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add UPI ID',
                    style: TanizTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your Virtual Payment Address (e.g. yourname@oksbi or 9848022338@paytm)',
                style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: vpaController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'username@bank',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: TanizColors.primaryBlue),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TanizColors.primaryBlue, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a UPI ID';
                  }
                  if (!val.contains('@') || val.trim().length < 5) {
                    return 'Enter a valid UPI ID (e.g. user@bank)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TanizTappable(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    paymentState.addUpi(vpaController.text.trim());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UPI ID added successfully!'),
                        backgroundColor: TanizColors.rapidGreen,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: TanizColors.blueGoldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Verify & Save UPI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, PaymentState paymentState) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Card (RBI Tokenization)',
                    style: TanizTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Per RBI guidelines, cards are securely tokenized. CVV is never stored.',
                style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name on Card',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                validator: (v) {
                  if (v == null || v.replaceAll(' ', '').length < 15) {
                    return 'Enter valid card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: expiryController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: InputDecoration(
                  labelText: 'Expiry (MM/YY)',
                  counterText: '',
                  hintText: '12/28',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v == null || !v.contains('/') || v.length != 5) {
                    return 'MM/YY format required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TanizTappable(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    final cleanNum = numberController.text.replaceAll(' ', '');
                    final last4 = cleanNum.substring(cleanNum.length - 4);
                    final brand = cleanNum.startsWith('4') ? 'Visa' : (cleanNum.startsWith('5') ? 'Mastercard' : 'RuPay');
                    final parts = expiryController.text.split('/');

                    paymentState.addCard(
                      SavedCardItem(
                        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                        bank: 'HDFC Bank',
                        brand: brand,
                        last4: last4,
                        cardHolder: nameController.text.trim(),
                        expiryMonth: parts[0],
                        expiryYear: '20${parts[1]}',
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card tokenized and saved securely!'),
                        backgroundColor: TanizColors.rapidGreen,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: TanizColors.blueGoldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Tokenize & Save Card',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
