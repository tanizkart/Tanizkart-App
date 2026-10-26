import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'contact_support_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _FaqItem {
  final String question;
  final String answer;
  final String category;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Orders & Delivery',
    'Payments & Refunds',
    'Wishlist',
    'Account & Addresses',
  ];

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      category: 'Orders & Delivery',
      question: 'How does 10-minute quick delivery work?',
      answer:
          'TanizKart fulfills orders from our localized micro-warehouses (Dark Stores) located within 3–4 km of your delivery address. As soon as your order is confirmed, our store team packs it in under 3 minutes, and an express delivery partner delivers it directly to your doorstep.',
    ),
    _FaqItem(
      category: 'Orders & Delivery',
      question: 'Can I cancel an order once placed?',
      answer:
          'You can cancel an order while it is still in the "Order Placed" state directly from the Orders tracking screen. Once packing has begun at the dark store, cancellation is restricted to avoid grocery wastage.',
    ),
    _FaqItem(
      category: 'Orders & Delivery',
      question: 'What are the delivery operating hours?',
      answer:
          'Our dark store operates daily from 6:00 AM to 11:30 PM. Orders placed during these hours are dispatched immediately.',
    ),
    _FaqItem(
      category: 'Payments & Refunds',
      question: 'Which payment methods are accepted?',
      answer:
          'We support instant UPI (Google Pay, PhonePe, Paytm, CRED), Credit & Debit cards (Visa, Mastercard, RuPay) using RBI-compliant tokenization, and Pay on Delivery (Cash or UPI QR scan at your door).',
    ),
    _FaqItem(
      category: 'Payments & Refunds',
      question: 'How do refunds work if an item is unavailable or returned?',
      answer:
          'If an item is out of stock or returned upon delivery, refunds are initiated immediately to your original payment method (usually 2–4 hours for UPI, and 2–5 business days for cards depending on your bank).',
    ),
    _FaqItem(
      category: 'Wishlist',
      question: 'How do I save products to my Wishlist?',
      answer:
          'Tap the heart icon on any product card or the top-right corner of the product details page. Saved products sync with your authenticated account and can be viewed or reordered anytime from My Profile > Wishlist / Saved Products.',
    ),
    _FaqItem(
      category: 'Account & Addresses',
      question: 'How do I edit my name, email, or delivery addresses?',
      answer:
          'Open My Profile and tap the pencil edit icon in the top right to update your name and email. To add, edit, or set default delivery addresses, tap "Saved Addresses" under Delivery Preferences.',
    ),
    _FaqItem(
      category: 'Account & Addresses',
      question: 'Why can’t I edit my phone number?',
      answer:
          'Your phone number is your primary TanizKart account credential linked to OTP verification. To protect account security, phone numbers cannot be changed directly in the profile editor.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredFaqs = _faqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

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
          'Help Center & FAQs',
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
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search questions, orders, refunds...',
                prefixIcon: const Icon(Icons.search_rounded, color: TanizColors.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TanizColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TanizColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TanizColors.primaryBlue, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: TanizColors.primaryBlue,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : TanizColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? TanizColors.primaryBlue : TanizColors.borderSubtle,
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // FAQ List
            if (filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: TanizColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No matching questions found',
                        style: TanizTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try searching for different keywords or contact our support team.',
                        style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFaqs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final faq = filteredFaqs[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [TanizColors.cardShadow],
                    ),
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: TanizColors.borderSubtle),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                        iconColor: TanizColors.primaryBlue,
                        collapsedIconColor: TanizColors.textMuted,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          faq.question,
                          style: TanizTypography.titleMedium.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                faq.answer,
                                style: TanizTypography.bodyMedium.copyWith(
                                  color: TanizColors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              ),

            const SizedBox(height: 24),

            // Contact Support CTA Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF5FF), Color(0xFFE4EDFC)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TanizColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: TanizColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Still need help?',
                          style: TanizTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reach out to our customer care team directly.',
                          style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TanizColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
