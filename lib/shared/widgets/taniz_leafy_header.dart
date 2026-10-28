import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../state/location_state.dart';
import '../widgets/address_bottom_sheet.dart';
import '../widgets/search_input_bar.dart';
import '../../features/listing/screens/product_listing_screen.dart';

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

  const TanizLeafyHeader({
    super.key,
    required this.onProfileTap,
    this.onNotificationTap,
    this.onLocationTap,
    this.onSearchTap,
    this.onCategoryTap,
  });

  static const List<Map<String, dynamic>> _quickShortcuts = [
    {
      'title': '10m Rush',
      'emoji': '⚡',
      'bgColor': Color(0xFFFEF3C7),
      'borderColor': Color(0xFFFDE68A),
      'textColor': Color(0xFF92400E),
      'category': 'deals',
    },
    {
      'title': 'Farm Fresh',
      'emoji': '🥦',
      'bgColor': Color(0xFFDCFCE7),
      'borderColor': Color(0xFFBBF7D0),
      'textColor': Color(0xFF166534),
      'category': 'cat_produce',
    },
    {
      'title': 'Dairy Hub',
      'emoji': '🥛',
      'bgColor': Color(0xFFE0F2FE),
      'borderColor': Color(0xFFBAE6FD),
      'textColor': Color(0xFF075985),
      'category': 'cat_dairy',
    },
    {
      'title': 'Munchies',
      'emoji': '🍿',
      'bgColor': Color(0xFFFFEDD5),
      'borderColor': Color(0xFFFED7AA),
      'textColor': Color(0xFF9A3412),
      'category': 'cat_snacks',
    },
    {
      'title': 'Under ₹99',
      'emoji': '₹',
      'bgColor': Color(0xFFFEF9C3),
      'borderColor': Color(0xFFFEF08A),
      'textColor': Color(0xFF854D0E),
      'category': 'budget',
    },
    {
      'title': 'Ice Cold',
      'emoji': '🧊',
      'bgColor': Color(0xFFCFFAFE),
      'borderColor': Color(0xFFA5F3FC),
      'textColor': Color(0xFF155E75),
      'category': 'cat_drinks',
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Row: Transparent Logo + Notification & Profile
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

                      // Notification Bell & Profile Controls
                      Row(
                        children: [
                          // Bell with Red Badge Dot
                          TanizTappable(
                            onTap: onNotificationTap,
                            borderRadius: BorderRadius.circular(999),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.90),
                                    border: Border.all(color: Colors.white, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    size: 20,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Positioned(
                                  top: 1,
                                  right: 2,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

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
                  TanizTappable(
                    onTap: onSearchTap ??
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListingScreen(),
                            ),
                          );
                        },
                    borderRadius: BorderRadius.circular(16),
                    child: const SearchInputBar(
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 10),

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
