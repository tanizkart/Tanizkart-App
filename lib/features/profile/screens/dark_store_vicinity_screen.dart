import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../state/location_state.dart';
import '../../../data/models/dark_store_model.dart';
import '../../../data/repositories/mock_dark_store_repository.dart';
import '../../../shared/widgets/address_bottom_sheet.dart';

class DarkStoreVicinityScreen extends StatelessWidget {
  const DarkStoreVicinityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationState>(
      builder: (context, locationState, _) {
        final address = locationState.selectedAddress;
        final store = MockDarkStoreRepository.getStoreForAddress(address);
        final distance = MockDarkStoreRepository.getDistanceForAddress(address);

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
              'Dark Store Vicinity',
              style: TanizTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),
          body: store == null
              ? _buildNoStoreFallback(context, address)
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Selected Delivery Address banner
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
                                color: TanizColors.blueContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded, color: TanizColors.primaryBlue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Delivering to: ',
                                        style: TanizTypography.caption.copyWith(color: TanizColors.textSecondary),
                                      ),
                                      Text(
                                        address.tag,
                                        style: TanizTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    address.fullAddress,
                                    style: TanizTypography.bodySmall.copyWith(
                                      color: TanizColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => AddressBottomSheet.show(context),
                              child: const Text('Change', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Store Overview Hero Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F2552), Color(0xFF1B3D7A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: TanizColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.warehouse_rounded, color: TanizColors.primaryGold, size: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        'STORE ${store.displayId}',
                                        style: TanizTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: store.isOpen ? TanizColors.rapidGreen : TanizColors.errorRed,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        store.isOpen ? 'ONLINE' : 'CLOSED',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              store.name,
                              style: TanizTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.locality,
                              style: TanizTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.near_me_rounded, color: TanizColors.primaryGold, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    distance,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.flash_on_rounded, color: TanizColors.primaryGold, size: 15),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '10-Min Express Zone',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Map / Route Preview Card
                      Text(
                        'Fulfillment Route',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TanizColors.borderSubtle),
                          boxShadow: [TanizColors.cardShadow],
                        ),
                        child: Column(
                          children: [
                            // Visual route illustration
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F2FF),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFE3EDFC),
                                    const Color(0xFFF1F6FD),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Grid pattern
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _GridRoutePainter(),
                                    ),
                                  ),
                                  // Dark store pin
                                  Positioned(
                                    left: 40,
                                    top: 36,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: TanizColors.navyDark,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.warehouse_rounded, color: TanizColors.primaryGold, size: 18),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [TanizColors.cardShadow],
                                          ),
                                          child: const Text(
                                            'Hub #304',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // User Address pin
                                  Positioned(
                                    right: 40,
                                    bottom: 24,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: TanizColors.rapidGreenDark,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [TanizColors.cardShadow],
                                          ),
                                          child: Text(
                                            address.tag,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coordinates: ${store.latitude}° N, ${store.longitude}° E',
                                        style: TanizTypography.caption.copyWith(
                                          color: TanizColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Direct line: $distance',
                                        style: TanizTypography.labelSmall.copyWith(
                                          color: TanizColors.rapidGreenDark,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _showMapDetailsModal(context, store, address, distance);
                                    },
                                    icon: const Icon(Icons.map_rounded, size: 16),
                                    label: const Text('View on Map'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: TanizColors.primaryBlue,
                                      side: const BorderSide(color: TanizColors.primaryBlue),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Store Details List
                      Text(
                        'Store & Service Info',
                        style: TanizTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: TanizColors.borderSubtle),
                          boxShadow: [TanizColors.cardShadow],
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.place_outlined,
                              title: 'Facility Address',
                              content: store.fullAddress,
                            ),
                            const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                            _buildInfoTile(
                              icon: Icons.access_time_rounded,
                              title: 'Operating Hours',
                              content: store.operatingHours,
                            ),
                            const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                            _buildInfoTile(
                              icon: Icons.phone_in_talk_rounded,
                              title: 'Dispatch Helplink',
                              content: store.contactPhone,
                              isActionable: true,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Calling Dark Store #304 Dispatch: ${store.contactPhone}'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, indent: 56, color: TanizColors.borderSubtle),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.radar_rounded, color: TanizColors.primaryBlue, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Covered Localities & Pincodes',
                                        style: TanizTypography.titleMedium.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      ...store.coverageLocalities.map(
                                        (loc) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF4FB),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: TanizColors.borderSubtle),
                                          ),
                                          child: Text(
                                            loc,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: TanizColors.navyDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...store.coveragePincodes.map(
                                        (pin) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: TanizColors.amberBadgeBg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: TanizColors.primaryGold.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            'PIN: $pin',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: TanizColors.goldenAmberDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    bool isActionable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: TanizColors.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: TanizTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActionable ? TanizColors.primaryBlue : TanizColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (isActionable)
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: TanizColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStoreFallback(BuildContext context, AddressItem address) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TanizColors.amberBadgeBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_mall_directory_outlined, size: 40, color: TanizColors.goldenAmberDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No Warehouse Assigned',
              style: TanizTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'No TanizKart dark store currently fulfills deliveries to:\n"${address.fullAddress}".\nWe are launching new warehouses rapidly across Andhra Pradesh.',
              textAlign: TextAlign.center,
              style: TanizTypography.bodyMedium.copyWith(color: TanizColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => AddressBottomSheet.show(context),
              icon: const Icon(Icons.place_rounded),
              label: const Text('Switch Delivery Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TanizColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapDetailsModal(BuildContext context, DarkStore store, AddressItem address, String distance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Warehouse Geo-Location',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TanizColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Warehouse: ${store.name} (${store.displayId})', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Address: ${store.fullAddress}', style: const TextStyle(fontSize: 12, color: TanizColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Latitude: ${store.latitude}° N', style: const TextStyle(fontSize: 12)),
                  Text('Longitude: ${store.longitude}° E', style: const TextStyle(fontSize: 12)),
                  Text('Estimated Delivery Radius: 4.5 km', style: const TextStyle(fontSize: 12)),
                  Text('Distance from you: $distance', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TanizColors.rapidGreenDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TanizTappable(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening GPS Navigation to ${store.name}...'),
                    backgroundColor: TanizColors.primaryBlue,
                  ),
                );
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
                    'Open in External Maps',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw route dashed line
    final routePaint = Paint()
      ..color = TanizColors.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(55, 52)
      ..cubicTo(size.width * 0.35, 30, size.width * 0.65, size.height - 30, size.width - 55, size.height - 40);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
