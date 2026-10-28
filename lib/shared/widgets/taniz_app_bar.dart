import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../state/location_state.dart';
import 'address_bottom_sheet.dart';

class TanizAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const TanizAppBar({
    super.key,
    required this.onProfileTap,
    this.onLocationTap,
    this.onNotificationTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TanizColors.primaryDeep,
            TanizColors.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), // Strict spacing 12/16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Logo, Notification & Profile Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo (Transparent background, no white container/box)
                  Image.asset(
                    'assets/logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Row(
                      children: [
                        Text(
                          'TANIZ',
                          style: TanizTypography.titleMedium.copyWith(
                            color: TanizColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'KART',
                          style: TanizTypography.titleMedium.copyWith(
                            color: TanizColors.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Notification & Profile
                  Row(
                    children: [
                      // Notification Bell
                      TanizTappable(
                        onTap: onNotificationTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: Colors.white, // Explicit icon tint
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Profile Avatar
                      TanizTappable(
                        onTap: onProfileTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TanizColors.accentGold,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: TanizColors.accentGold.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Y',
                              style: TextStyle(
                                color: TanizColors.primaryDeep,
                                fontWeight: FontWeight.w800,
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
              const SizedBox(height: 12),

              // Row 2: Live Location Dropdown
              Consumer<LocationState>(
                builder: (context, locState, _) {
                  final activeAddr = locState.selectedAddress;

                  return TanizTappable(
                    onTap: onLocationTap ?? () => AddressBottomSheet.show(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: TanizColors.accentGold, // Explicit gold tint
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Deliver to ${activeAddr.tag} - ${activeAddr.label}',
                                      style: TanizTypography.titleSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white, // Explicit white tint
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeAddr.fullAddress,
                                  style: TanizTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
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
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
