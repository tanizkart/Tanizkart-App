import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

class TermsPrivacyScreen extends StatelessWidget {
  final int initialTabIndex;

  const TermsPrivacyScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
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
            'Legal & Policies',
            style: TanizTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
          bottom: TabBar(
            indicatorColor: TanizColors.primaryBlue,
            indicatorWeight: 3,
            labelColor: TanizColors.primaryBlue,
            unselectedLabelColor: TanizColors.textSecondary,
            labelStyle: TanizTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            unselectedLabelStyle: TanizTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PolicyContent(
              title: 'Terms of Service',
              isDraft: true,
              sections: [
                _PolicySection(
                  number: '1',
                  heading: 'Account Registration & Verification',
                  body:
                      'TanizKart accounts are created and authenticated using a valid mobile phone number and One-Time Password (OTP). You are responsible for maintaining confidentiality of your device and login sessions. You may update your display name and email address in your profile, but the registered phone number remains tied to your verified account.',
                ),
                _PolicySection(
                  number: '2',
                  heading: 'Product Catalogue & Pricing',
                  body:
                      'All grocery items, dairy products, beverages, and household goods displayed on TanizKart are subject to live stock availability at your designated dark store (e.g., Tanizkart Hub #304 in Ongole). All displayed prices are inclusive of applicable GST/taxes. TanizKart strives for complete pricing accuracy; in the rare event of a pricing error, we reserve the right to cancel affected order items before dispatch.',
                ),
                _PolicySection(
                  number: '3',
                  heading: '10-Minute Express Delivery',
                  body:
                      'Our 10-minute delivery promise is fulfilled by localized micro-fulfillment centres located within your delivery vicinity. While our average dispatch time is under 3 minutes, transit times may vary depending on adverse weather, traffic, roadblocks, or sudden surges in order volume.',
                ),
                _PolicySection(
                  number: '4',
                  heading: 'Order Cancellations',
                  body:
                      'You may cancel an order free of charge while its status remains "Order Placed" directly in the live tracking screen. Once our dark store commences picking and packing, cancellations are restricted to prevent grocery and perishable food wastage.',
                ),
                _PolicySection(
                  number: '5',
                  heading: 'Returns & Refunds Policy',
                  body:
                      'Perishable goods (such as fresh milk, eggs, bread, and fruits) must be inspected at the time of delivery. If an item is missing, damaged, or past its expiration date, please raise a ticket via Contact Support within 24 hours. Approved refunds are credited back to your original payment method or wallet.',
                ),
                _PolicySection(
                  number: '6',
                  heading: 'Payment Options & Security',
                  body:
                      'TanizKart supports instant UPI intent, major Credit/Debit cards (Visa, Mastercard, RuPay), and Pay on Delivery. In compliance with RBI tokenization guidelines, TanizKart never stores your raw card numbers, CVV codes, or UPI PINs.',
                ),
                _PolicySection(
                  number: '7',
                  heading: 'TanizKart Premium & Rewards',
                  body:
                      'TanizKart VIP members enjoy free delivery on eligible orders and exclusive milestone rewards. Referral bonuses and wallet earnings are non-transferable and can only be redeemed towards future grocery purchases on the platform.',
                ),
                _PolicySection(
                  number: '8',
                  heading: 'Customer Grievances',
                  body:
                      'For complaints, feedback, or delivery disputes, please reach out to our customer care team via the in-app Contact Support form or write to support@tanizkart.com.',
                ),
              ],
            ),
            _PolicyContent(
              title: 'Privacy Policy',
              isDraft: true,
              sections: [
                _PolicySection(
                  number: '1',
                  heading: 'Information We Collect',
                  body:
                      'To fulfill quick-commerce orders, we collect your verified mobile phone number, name, email address, saved delivery addresses, preferred payment methods (in tokenized form), wishlist items, and order history.',
                ),
                _PolicySection(
                  number: '2',
                  heading: 'Location & GPS Usage',
                  body:
                      'We access your device location or selected delivery address solely to assign the closest servicing dark store (e.g. Tanizkart Hub #304), verify serviceability within our 10-minute delivery radius, and guide our delivery partners to your doorstep.',
                ),
                _PolicySection(
                  number: '3',
                  heading: 'How We Use Your Personal Data',
                  body:
                      'We use your data to:\n• Process, pack, and deliver orders.\n• Send transactional SMS and OTP authentication messages.\n• Maintain your synchronized Wishlist and delivery preferences.\n• Prevent fraud and ensure secure payment processing.',
                ),
                _PolicySection(
                  number: '4',
                  heading: 'Payment Information Security',
                  body:
                      'Card transactions and UPI intents are handled through RBI-authorized payment aggregators. TanizKart complies with PCI-DSS standards; card credentials are saved as encrypted network tokens.',
                ),
                _PolicySection(
                  number: '5',
                  heading: 'User Data Controls',
                  body:
                      'You retain full control over your information. You can edit your profile details, remove saved delivery addresses, clear your saved wishlist items, or log out of your session at any time.',
                ),
                _PolicySection(
                  number: '6',
                  heading: 'Contact Privacy Support',
                  body:
                      'If you have questions regarding our data practices or wish to request data updates, please contact our privacy desk at support@tanizkart.com.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  final String title;
  final bool isDraft;
  final List<_PolicySection> sections;

  const _PolicyContent({
    required this.title,
    required this.isDraft,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDraft)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TanizColors.amberBadgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TanizColors.goldenAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: TanizColors.goldenAmberDark, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'DRAFT FOR OWNER / LEGAL REVIEW: This document summarizes TanizKart\'s quick-commerce policies matching current app functionality.',
                      style: TanizTypography.caption.copyWith(
                        color: TanizColors.goldenAmberDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sec = sections[index];
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: TanizColors.blueContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              sec.number,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: TanizColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sec.heading,
                            style: TanizTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sec.body,
                      style: TanizTypography.bodyMedium.copyWith(
                        color: TanizColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String number;
  final String heading;
  final String body;

  const _PolicySection({
    required this.number,
    required this.heading,
    required this.body,
  });
}
