import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/mock_dark_store_repository.dart';
import '../../../state/auth_state.dart';
import '../../../state/wishlist_state.dart';
import '../../../state/location_state.dart';
import '../../../state/navigation_state.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';
import '../../auth/screens/login_sheet.dart';
import 'edit_profile_screen.dart';
import 'wishlist_screen.dart';
import 'payment_methods_screen.dart';
import 'dark_store_vicinity_screen.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';
import 'terms_privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final user = authState.profile;
    final wishlistState = context.watch<WishlistState>();
    final locationState = context.watch<LocationState>();

    final selectedAddress = locationState.selectedAddress;
    final assignedStore = MockDarkStoreRepository.getStoreForAddress(selectedAddress);
    final distance = MockDarkStoreRepository.getDistanceForAddress(selectedAddress);

    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    final phoneDisplay = user.phoneNumber.isNotEmpty
        ? user.phoneNumber
        : (user.phone.isNotEmpty ? user.phone : '+91 98480 22338');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: TanizColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'My Profile',
          style: TanizTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'QR Code & Member Pass',
            icon: const Icon(Icons.qr_code_scanner_rounded, color: TanizColors.primaryBlue),
            onPressed: () {
              _showQrPassModal(context, user.name, phoneDisplay, user.memberTier);
            },
          ),
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: TanizColors.primaryBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
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
                  colors: [Color(0xFF0F2552), Color(0xFF1B3D7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: TanizColors.primaryBlue.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // User Avatar, Name, Phone & Edit Action
                  Row(
                    children: [
                      // Avatar with edit shortcut
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: TanizColors.primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: TanizColors.primaryGold, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: TanizColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, size: 10, color: TanizColors.navyDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Hi, ${user.name}',
                                    style: TanizTypography.headlineSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('👋', style: TextStyle(fontSize: 15)),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, size: 15, color: TanizColors.goldenAmber),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phoneDisplay,
                              style: TanizTypography.bodySmall.copyWith(
                                color: Colors.blue.shade100,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TanizColors.goldenAmber.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: TanizColors.goldenAmber.withValues(alpha: 0.45)),
                              ),
                              child: Text(
                                user.memberTier,
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
                      IconButton(
                        tooltip: 'Edit Profile Info',
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.mode_edit_outline_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 12),

                  // 3 Quick Account Cards: Orders (12), Premium (Active), Rewards (₹2,400)
                  Row(
                    children: [
                      _buildQuickStatCard(
                        'Orders',
                        '${user.totalOrders}',
                        Icons.shopping_bag_outlined,
                        onTap: () => Provider.of<NavigationState>(context, listen: false).setIndex(2),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickStatCard(
                        'Premium',
                        'Active',
                        Icons.workspace_premium_rounded,
                        isHighlighted: true,
                        onTap: () => _showPremiumModal(context, user),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickStatCard(
                        'Rewards',
                        CurrencyFormatter.format(user.rewardsBalance),
                        Icons.account_balance_wallet_outlined,
                        onTap: () => _showRewardsModal(context, user),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==========================================
            // PRIORITY 2: BALANCED PREMIUM VIP CARD
            // ==========================================
            TanizTappable(
              onTap: () => _showPremiumModal(context, user),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFAE00), Color(0xFFFF9500)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFAE00).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: TanizColors.navyDark,
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
                                'TANIZKART PREMIUM',
                                style: TanizTypography.labelLarge.copyWith(
                                  color: TanizColors.navyDark,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: TanizColors.navyDark,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: TanizColors.goldenAmber,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Free delivery on all orders • ${CurrencyFormatter.format(user.premiumAnnualValue)}/yr saved',
                            style: TanizTypography.bodySmall.copyWith(
                              color: TanizColors.navyDark.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: TanizColors.navyDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View',
                            style: TanizTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==========================================
            // PRIORITY 3: BALANCED REFER & EARN CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TanizColors.borderSubtle),
                boxShadow: [TanizColors.cardShadow],
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
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: TanizColors.blueContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.card_giftcard_rounded,
                              color: TanizColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Refer & Earn ${CurrencyFormatter.format(user.referralMilestoneReward)}',
                                style: TanizTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Invite friends → earn cash rewards',
                                style: TanizTypography.caption.copyWith(
                                  color: TanizColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showReferralModal(context, user);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TanizColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Refer Now',
                              style: TanizTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_rounded, size: 11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Referral Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${user.referralsCompleted} / ${user.referralsTarget} referrals',
                        style: TanizTypography.labelMedium.copyWith(
                          color: TanizColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '₹1,000 milestone almost unlocked!',
                        style: TanizTypography.labelSmall.copyWith(
                          color: TanizColors.rapidGreenDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: user.referralProgress,
                      backgroundColor: const Color(0xFFF0F4F8),
                      valueColor: const AlwaysStoppedAnimation<Color>(TanizColors.goldenAmber),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // SECTION 1: MY ACTIVITY
            // ==========================================
            _buildSectionHeader('My Activity'),
            _buildSectionCard([
              _buildTile(
                Icons.inventory_2_outlined,
                'My Orders',
                'Track active and past dark store deliveries',
                onTap: () => Provider.of<NavigationState>(context, listen: false).setIndex(2),
              ),
              _buildTile(
                Icons.favorite_outline_rounded,
                'Wishlist / Saved Products',
                wishlistState.itemCount > 0
                    ? '${wishlistState.itemCount} saved item${wishlistState.itemCount > 1 ? 's' : ''}'
                    : 'Quick-order your favorites',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.card_giftcard_rounded,
                'Referrals & Milestones',
                'Earn up to ₹1,200 wallet cash',
                onTap: () => _showReferralModal(context, user),
              ),
              _buildTile(
                Icons.account_balance_wallet_outlined,
                'Rewards & Earnings',
                '${CurrencyFormatter.format(user.rewardsBalance)} wallet balance',
                isLast: true,
                onTap: () => _showRewardsModal(context, user),
              ),
            ]),

            const SizedBox(height: 20),

            // ==========================================
            // SECTION 2: DELIVERY PREFERENCES
            // ==========================================
            _buildSectionHeader('Delivery Preferences'),
            _buildSectionCard([
              _buildTile(
                Icons.location_on_outlined,
                'Saved Addresses',
                'Select or manage delivery addresses',
                onTap: () => AddressBottomSheet.show(context),
              ),
              _buildTile(
                Icons.payment_rounded,
                'Payment Methods',
                'UPI, Saved Cards & COD preferences',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.home_outlined,
                'Dark Store Vicinity',
                assignedStore != null
                    ? '${assignedStore.name} (${assignedStore.displayId}) • $distance'
                    : 'No assigned dark store',
                isLast: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DarkStoreVicinityScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 20),

            // ==========================================
            // SECTION 3: HELP & SUPPORT
            // ==========================================
            _buildSectionHeader('Help & Support'),
            _buildSectionCard([
              _buildTile(
                Icons.help_outline_rounded,
                'Help Center & FAQs',
                'Searchable guides, refunds & order support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.call_outlined,
                'Contact Support Team',
                'Support tickets, call & email (7 AM – 11 PM)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
                  );
                },
              ),
              _buildTile(
                Icons.policy_outlined,
                'Terms of Service & Privacy',
                'Terms, privacy & quick-commerce policies',
                isLast: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsPrivacyScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ==========================================
            // LOGOUT BUTTON
            // ==========================================
            OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context, authState);
              },
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
                backgroundColor: TanizColors.errorContainer.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // App Version Footer (Dynamic store info)
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
                    'Save money save time • ${assignedStore?.name ?? "Dark Store #304 Ongole"}',
                    style: TanizTypography.bodySmall.copyWith(
                      fontSize: 10.5,
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

  Widget _buildQuickStatCard(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: TanizTappable(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          fontSize: 14.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: TanizColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle, {
    bool isLast = false,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TanizColors.blueContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TanizColors.primaryBlue, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TanizTypography.titleMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: TanizColors.redContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TanizTypography.labelSmall.copyWith(
                      color: TanizColors.errorRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            subtitle,
            style: TanizTypography.bodySmall.copyWith(
              fontSize: 11,
              color: TanizColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: TanizColors.textMuted, size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16, color: TanizColors.borderSubtle),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthState authState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log out of Tanizkart?'),
        content: const Text('You will need to verify your phone number via OTP to log back in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authState.logout();
              LoginSheet.show(context);
            },
            child: const Text('Log Out', style: TextStyle(color: TanizColors.errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showQrPassModal(BuildContext context, String name, String phone, String tier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            Text(
              'TanizKart Member Pass',
              style: TanizTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Scan at TanizKart physical hub or dark store counter',
              style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TanizColors.borderSubtle),
                boxShadow: [TanizColors.cardShadow],
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 140, color: TanizColors.navyDark),
            ),
            const SizedBox(height: 14),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('$phone • $tier', style: const TextStyle(color: TanizColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPremiumModal(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: TanizColors.goldVIPGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, size: 36, color: TanizColors.navyDark),
            ),
            const SizedBox(height: 14),
            Text(
              'TanizKart VIP Membership',
              style: TanizTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Your VIP status is Active. Enjoy free delivery on all orders across Ongole.',
              textAlign: TextAlign.center,
              style: TanizTypography.bodyMedium.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TanizColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(Icons.check_circle_rounded, 'Unlimited free delivery on orders above ₹99'),
                  const SizedBox(height: 8),
                  _buildBenefitRow(Icons.check_circle_rounded, 'Priority picking at Lawyerpet Dark Store #304'),
                  const SizedBox(height: 8),
                  _buildBenefitRow(Icons.check_circle_rounded, 'Exclusive member pricing & flash discounts'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardsModal(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: TanizColors.greenContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 36, color: TanizColors.rapidGreenDark),
            ),
            const SizedBox(height: 14),
            Text(
              'TanizKart Wallet Rewards',
              style: TanizTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Available Wallet Balance',
              style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(user.rewardsBalance),
              style: TanizTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: TanizColors.primaryBlue,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your wallet rewards are automatically applied towards discounts on checkout.',
              textAlign: TextAlign.center,
              style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralModal(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard_rounded, size: 44, color: TanizColors.primaryBlue),
            const SizedBox(height: 12),
            Text(
              'Invite & Earn Rewards',
              style: TanizTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'Share TanizKart with your neighbors and friends in Ongole. When they place their first order, both get ₹100 wallet cash.',
              textAlign: TextAlign.center,
              style: TanizTypography.bodySmall.copyWith(color: TanizColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TanizColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Referral Code: TANIZ892', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral code copied to clipboard!')),
                      );
                    },
                    child: const Text('Copy'),
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

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: TanizColors.rapidGreenDark, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
