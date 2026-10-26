import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../data/repositories/mock_order_repository.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String _selectedTopic = 'Order Delay / Tracking';
  String _selectedOrder = 'Order #TK-89421 (Active)';
  bool _isSubmitting = false;

  final List<String> _topics = [
    'Order Delay / Tracking',
    'Missing or Damaged Item',
    'Payment / Refund Query',
    'Address / Store Vicinity',
    'Account & Wishlist',
    'General Feedback',
  ];

  late final List<String> _orderOptions;

  @override
  void initState() {
    super.initState();
    final activeOrder = MockOrderRepository.getActiveOrder();
    _orderOptions = [
      'Order #${activeOrder.id} (Active)',
      'None (General Query / Account)',
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate backend ticket registration
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final ticketId = 'TKT-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';

    setState(() {
      _isSubmitting = false;
    });

    _showTicketSuccessDialog(ticketId);
  }

  void _showTicketSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: TanizColors.greenContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: TanizColors.rapidGreenDark, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket Raised Successfully',
              style: TanizTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TanizColors.blueContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ticket ID: #$ticketId',
                style: TanizTypography.titleMedium.copyWith(
                  color: TanizColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our Ongole dark store support executive will review your inquiry and follow up within 15 minutes during active support hours (7:00 AM – 11:00 PM).',
              textAlign: TextAlign.center,
              style: TanizTypography.bodySmall.copyWith(
                color: TanizColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _messageController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

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
          'Contact Support Team',
          style: TanizTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operating Hours Banner (Honest & Realistic)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TanizColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: TanizColors.primaryBlue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support Hours: 7:00 AM – 11:00 PM Daily',
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dedicated support for Lawyerpet & Ongole dark store deliveries.',
                          style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Verified Direct Channels
            Text(
              'Direct Support Channels',
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildChannelCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Call Support',
                    subtitle: '+91 98480 22338',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: '+919848022338'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied support phone number: +91 98480 22338'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChannelCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Care',
                    subtitle: 'support@tanizkart.com',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'support@tanizkart.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied support email: support@tanizkart.com'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Raise Support Ticket Form
            Text(
              'Raise a Support Ticket',
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Have an issue with an item, delivery, or refund? Submit details below.',
              style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TanizColors.borderSubtle),
                boxShadow: [TanizColors.cardShadow],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic selector
                    Text(
                      'Issue Category',
                      style: TanizTypography.titleMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTopic,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TanizColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TanizColors.borderSubtle),
                        ),
                      ),
                      items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTopic = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Order Reference selector
                    Text(
                      'Related Order (Optional)',
                      style: TanizTypography.titleMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOrder,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TanizColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TanizColors.borderSubtle),
                        ),
                      ),
                      items: _orderOptions.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedOrder = val;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Message textarea
                    Text(
                      'Describe your issue',
                      style: TanizTypography.titleMedium.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Please describe what went wrong or how we can help...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: TanizColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        contentPadding: const EdgeInsets.all(14),
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
                          return 'Please provide details about your issue';
                        }
                        if (val.trim().length < 10) {
                          return 'Please describe in at least 10 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    TanizTappable(
                      onTap: _isSubmitting ? () {} : _handleSubmitTicket,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: TanizColors.blueGoldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Submit Ticket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TanizColors.borderSubtle),
          boxShadow: [TanizColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TanizColors.blueContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: TanizColors.primaryBlue, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TanizTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TanizTypography.caption.copyWith(
                color: TanizColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
