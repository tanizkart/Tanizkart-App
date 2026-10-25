import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../../state/navigation_state.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../auth/screens/login_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _user;

  @override
  void initState() {
    super.initState();
    _user = MockUserRepository.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TanizColors.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'My Account',
          style: TanizTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: TanizColors.primaryBlue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: TanizColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // PRIORITY 1: TOP PROFILE HERO & STAT PILLS
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2552), TanizColors.midnightNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: TanizColors.midnightNavy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // User Avatar & Name
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: TanizColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: TanizColors.goldenAmber, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'Y',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hi, ${_user.name} 👋',
                                  style: TanizTypography.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 16, color: TanizColors.goldenAmber),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _user.phone,
                              style: TanizTypography.bodySmall.copyWith(
                                color: Colors.blue.shade100,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TanizColors.goldenAmber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: TanizColors.goldenAmber.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                _user.memberTier,
                                style: TanizTypography.labelSmall.copyWith(
                                  color: TanizColors.goldenAmber,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 14),

                  // 3 Quick Account Cards: Orders (12), Premium (Active), Rewards (₹2,400)
                  Row(
                    children: [
                      _buildQuickStatCard('Orders', '${_user.totalOrders}', Icons.shopping_bag_outlined),
                      const SizedBox(width: 8),
                      _buildQuickStatCard('Premium', 'Active', Icons.workspace_premium_rounded, isHighlighted: true),
                      const SizedBox(width: 8),
                      _buildQuickStatCard('Rewards', CurrencyFormatter.format(_user.rewardsBalance), Icons.account_balance_wallet_outlined),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // PRIORITY 2: TANIZKART PREMIUM VIP CARD (GOLD)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: TanizColors.goldVIPGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: TanizColors.goldenAmber.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: TanizColors.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'TANIZKART PREMIUM',
                              style: TanizTypography.labelLarge.copyWith(
                                color: TanizColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: TanizColors.midnightNavy,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  color: TanizColors.goldenAmber,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Free delivery on all orders • ${CurrencyFormatter.format(_user.premiumAnnualValue)}/year value',
                          style: TanizTypography.bodySmall.copyWith(
                            color: TanizColors.textPrimary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: TanizColors.midnightNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View',
                            style: TanizTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // PRIORITY 3: PROMINENT REFER & EARN CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: TanizColors.primaryBlue.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TanizColors.blueContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.card_giftcard_rounded,
                              color: TanizColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Refer & Earn ${CurrencyFormatter.format(_user.referralMilestoneReward)}',
                                style: TanizTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Invite friends → earn cash rewards',
                                style: TanizTypography.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TanizColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Refer Now',
                              style: TanizTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_rounded, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Referral Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_user.referralsCompleted} / ${_user.referralsTarget} referrals',
                        style: TanizTypography.labelMedium.copyWith(
                          color: TanizColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '₹1,000 milestone almost unlocked!',
                        style: TanizTypography.labelSmall.copyWith(
                          color: TanizColors.rapidGreenDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _user.referralProgress,
                      backgroundColor: TanizColors.surfaceLow,
                      valueColor: const AlwaysStoppedAnimation<Color>(TanizColors.goldenAmber),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // SECONDARY SECTIONS
            // ==========================================

            // Section 1: My Activity
            _buildSectionHeader('My Activity'),
            _buildSectionCard([
              _buildTile(
                Icons.inventory_2_outlined,
                'My Orders',
                'Track past warehouse deliveries',
                onTap: () => Provider.of<NavigationState>(context, listen: false).setIndex(2),
              ),
              _buildTile(Icons.favorite_outline_rounded, 'Wishlist / Saved Products', 'Quick-order your favorites', onTap: () {}),
              _buildTile(Icons.card_giftcard_rounded, 'Referrals & Milestones', 'Earn up to ₹1,200', onTap: () {}),
              _buildTile(Icons.account_balance_wallet_outlined, 'Rewards & Earnings', '₹2,400 wallet balance', isLast: true, onTap: () {}),
            ]),

            const SizedBox(height: 20),

            // Section 2: Delivery & Addresses
            _buildSectionHeader('Delivery Preferences'),
            _buildSectionCard([
              _buildTile(
                Icons.location_on_outlined,
                'Saved Addresses',
                'Select or manage delivery addresses',
                onTap: () => AddressBottomSheet.show(context),
              ),
              _buildTile(Icons.payment_rounded, 'Payment Methods', 'UPI, Cards & NetBanking', onTap: () {}),
              _buildTile(Icons.home_outlined, 'Dark Store Vicinity', 'Dark Store #304 Lawyerpet', isLast: true, onTap: () {}),
            ]),

            const SizedBox(height: 20),

            // Section 3: Support & Legal
            _buildSectionHeader('Help & Support'),
            _buildSectionCard([
              _buildTile(Icons.help_outline_rounded, 'Help Center & FAQs', '24x7 Customer support', onTap: () {}),
              _buildTile(Icons.call_outlined, 'Contact Support Team', 'Instant chat & phone assistance', onTap: () {}),
              _buildTile(Icons.policy_outlined, 'Terms of Service & Privacy', 'Quick-commerce safety policy', isLast: true, onTap: () {}),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => LoginSheet.show(context),
              icon: const Icon(Icons.logout_rounded, color: TanizColors.errorRed, size: 20),
              label: Text(
                'Log Out of Tanizkart',
                style: TanizTypography.labelLarge.copyWith(
                  color: TanizColors.errorRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: TanizColors.errorRed.withValues(alpha: 0.3)),
                backgroundColor: TanizColors.errorContainer.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'TANIZKART EXPRESS v2.4.0 (Build 8920)',
                    style: TanizTypography.labelSmall.copyWith(
                      color: TanizColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save money save time • Dark Store #304 Ongole',
                    style: TanizTypography.bodySmall.copyWith(
                      fontSize: 10,
                      color: TanizColors.textMuted,
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

  Widget _buildQuickStatCard(String label, String value, IconData icon, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? TanizColors.goldenAmber.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted
                ? TanizColors.goldenAmber.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isHighlighted ? TanizColors.goldenAmber : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TanizTypography.titleMedium.copyWith(
                color: isHighlighted ? TanizColors.goldenAmber : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: TanizTypography.bodySmall.copyWith(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TanizTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: TanizColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, {bool isLast = false, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TanizColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TanizColors.primaryBlue, size: 20),
          ),
          title: Text(
            title,
            style: TanizTypography.titleMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TanizTypography.bodySmall.copyWith(
              fontSize: 11,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: TanizColors.textMuted, size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: TanizColors.borderSubtle),
      ],
    );
  }
}
