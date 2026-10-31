import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../state/location_state.dart';
import '../../state/cart_state.dart';
import '../../core/utils/cart_navigation.dart';
import '../widgets/address_bottom_sheet.dart';
import '../widgets/search_input_bar.dart';

/// Top Canopy Header for Tanizkart (Previous Version Layout with New Fresh Canopy)
/// Features:
/// - Brand new bright morning canopy background (delicate leaves framing top, bright clear center, NO blur smudge)
/// - Top Row: Transparent Logo + Notification Bell (with red badge) + Gold 'Y' Profile Avatar
/// - Location Row: Amber pin + Deliver to Home dropdown + Full Address
/// - Search Input Bar with voice and scanner icons
/// - Compact SLA Status Strip: ⚡ 10-15 Min | ⏱ Hub #304 Active | ❄️ Sub-4°C Cold Chain
/// - 6 Quick Shortcut Cards: 10m Rush, Farm Fresh, Dairy Hub, Munchies, Under ₹99, Ice Cold
class TanizLeafyHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSearchTap;
  final Function(String categoryName)? onCategoryTap;
  final bool isSearchActive;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final VoidCallback? onSearchClose;

  const TanizLeafyHeader({
    super.key,
    required this.onProfileTap,
    this.onNotificationTap,
    this.onLocationTap,
    this.onSearchTap,
    this.onCategoryTap,
    this.isSearchActive = false,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.onSearchClear,
    this.onSearchClose,
  });

  static const List<Map<String, dynamic>> _quickShortcuts = [
    {
      'title': 'Vegetables',
      'emoji': '🥦',
      'bgColor': Color(0xFFDCFCE7),
      'borderColor': Color(0xFFBBF7D0),
      'textColor': Color(0xFF166534),
      'category': 'cat_vegetables',
    },
    {
      'title': 'Dairy',
      'emoji': '🥛',
      'bgColor': Color(0xFFE0F2FE),
      'borderColor': Color(0xFFBAE6FD),
      'textColor': Color(0xFF075985),
      'category': 'cat_dairy',
    },
    {
      'title': 'Groceries',
      'emoji': '🌾',
      'bgColor': Color(0xFFFEF9C3),
      'borderColor': Color(0xFFFEF08A),
      'textColor': Color(0xFF854D0E),
      'category': 'cat_groceries',
    },
    {
      'title': 'Baby Care',
      'emoji': '👶',
      'bgColor': Color(0xFFFCE7F3),
      'borderColor': Color(0xFFFBCFE8),
      'textColor': Color(0xFF9D174D),
      'category': 'cat_baby_care',
    },
    {
      'title': 'Personal Care',
      'emoji': '🧴',
      'bgColor': Color(0xFFF3E8FF),
      'borderColor': Color(0xFFE9D5FF),
      'textColor': Color(0xFF6B21A8),
      'category': 'cat_personal_care',
    },
    {
      'title': 'Home Essentials',
      'emoji': '🧼',
      'bgColor': Color(0xFFF1F5F9),
      'borderColor': Color(0xFFE2E8F0),
      'textColor': Color(0xFF334155),
      'category': 'cat_home_essentials',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        image: DecorationImage(
          image: AssetImage('assets/canopy_header.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // Gentle gradient scrim for 100% contrast & smooth fade into canvas
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.70),
                    TanizColors.canvasBackground,
                  ],
                  stops: const [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Row: Transparent Logo + Notification, Cart & Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Transparent Tanizkart Logo
                      TanizTappable(
                        onTap: () {},
                        child: Image.asset(
                          'assets/logo.png',
                          height: 34,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Row(
                            children: [
                              Text(
                                'TANIZ',
                                style: TanizTypography.titleMedium.copyWith(
                                  color: TanizColors.royalBlue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  shadows: const [
                                    Shadow(color: Colors.white, blurRadius: 8),
                                  ],
                                ),
                              ),
                              Text(
                                'KART',
                                style: TanizTypography.titleMedium.copyWith(
                                  color: TanizColors.metallicGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  shadows: const [
                                    Shadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Notification Bell, Cart & Profile Controls
                      Row(
                        children: [
                          // Bell with Red Badge Dot - unclipped and fully visible
                          TanizTappable(
                            onTap: onNotificationTap,
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.95),
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        size: 20,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Cart Bag Icon with dynamic item count badge - unclipped and fully visible
                          Consumer<CartState>(
                            builder: (context, cart, _) => TanizTappable(
                              onTap: () => CartNavigation.openCart(context),
                              child: SizedBox(
                                width: 48,
                                height: 44,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.95),
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 20,
                                          color: TanizColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    if (cart.isNotEmpty)
                                      Positioned(
                                        top: 0,
                                        right: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                                          decoration: BoxDecoration(
                                            color: TanizColors.primaryBlue,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.white, width: 1.8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.18),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${cart.totalItemCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                height: 1.1,
                                                letterSpacing: -0.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Metallic Gold Profile Avatar ('Y')
                          TanizTappable(
                            onTap: onProfileTap,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: TanizColors.metallicGold,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: TanizColors.metallicGold.withValues(alpha: 0.40),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Y',
                                  style: TextStyle(
                                    color: TanizColors.royalBlue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 2. Delivery Location & Address Dropdown
                  Consumer<LocationState>(
                    builder: (context, locState, _) {
                      final activeAddr = locState.selectedAddress;

                      return TanizTappable(
                        onTap: onLocationTap ?? () => AddressBottomSheet.show(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFEAB308), // Amber location pin
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Deliver to ${activeAddr.tag} - ${activeAddr.label}',
                                          style: TanizTypography.titleSmall.copyWith(
                                            color: const Color(0xFF0F172A),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF0F172A),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    activeAddr.fullAddress,
                                    style: TanizTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. Clean White Search Input Bar
                  SearchInputBar(
                    readOnly: !isSearchActive,
                    onTap: onSearchTap,
                    controller: searchController,
                    focusNode: searchFocusNode,
                    autofocus: isSearchActive,
                    onChanged: onSearchChanged,
                    onClear: onSearchClear,
                    onClose: onSearchClose,
                    showCloseButton: isSearchActive,
                    hintText: 'Search for atta, dal, milk and more',
                  ),
                  const SizedBox(height: 10),

                  if (!isSearchActive) ...[
                    // 4. Compact SLA & Hub Status Strip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xEEF7FEE7), // Soft translucent lime-white
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFD9F99D),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '10-15 Min',
                            style: TanizTypography.caption.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          _buildDivider(),
                          const Text('⏱', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Hub #304 Active',
                            style: TanizTypography.caption.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          _buildDivider(),
                          const Text('❄️', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Sub-4°C Cold Chain',
                            style: TanizTypography.caption.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5. 6 Quick Shortcut Cards (From Previous Header in Reference 2)
                    SizedBox(
                      height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _quickShortcuts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = _quickShortcuts[index];
                        final title = item['title'] as String;
                        final emoji = item['emoji'] as String;
                        final bgColor = item['bgColor'] as Color;
                        final borderColor = item['borderColor'] as Color;

                        return TanizTappable(
                          onTap: () => onCategoryTap?.call(title),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 10,
      width: 1,
      color: const Color(0xFF86EFAC),
    );
  }
}
