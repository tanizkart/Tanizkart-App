import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../state/location_state.dart';

class AddressBottomSheet extends StatelessWidget {
  const AddressBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddressBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationState>(
      builder: (context, locState, _) {
        final addresses = locState.addresses;
        final selected = locState.selectedAddress;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Delivery Address',
                    style: TanizTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Addresses List
              ...addresses.map((addr) {
                final isCurrent = addr.id == selected.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      locState.selectAddress(addr);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 1400),
                          backgroundColor: TanizColors.primaryBlue,
                          content: Text('📍 Delivery address updated to ${addr.label}'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent ? TanizColors.blueContainer : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? TanizColors.primaryBlue : TanizColors.borderSubtle,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            addr.tag == 'Home'
                                ? Icons.home_rounded
                                : addr.tag == 'Office'
                                    ? Icons.business_rounded
                                    : Icons.location_on_rounded,
                            color: isCurrent ? TanizColors.primaryBlue : TanizColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.label,
                                      style: TanizTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isCurrent ? TanizColors.primaryBlue : TanizColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isCurrent ? TanizColors.primaryBlue : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        addr.tag.toUpperCase(),
                                        style: TextStyle(
                                          color: isCurrent ? Colors.white : Colors.grey.shade700,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  addr.fullAddress,
                                  style: TanizTypography.bodySmall.copyWith(
                                    color: TanizColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            const Icon(Icons.check_circle_rounded, color: TanizColors.primaryBlue)
                          else
                            const Icon(Icons.radio_button_off_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 6),

              // + Add New Address Action
              OutlinedButton.icon(
                onPressed: () {
                  _showAddAddressDialog(context, locState);
                },
                icon: const Icon(Icons.add_rounded, color: TanizColors.primaryBlue),
                label: Text(
                  'Add New Delivery Address',
                  style: TanizTypography.labelLarge.copyWith(
                    color: TanizColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: TanizColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAddressDialog(BuildContext context, LocationState locState) {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String selectedTag = 'Home';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Delivery Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'House / Flat / Landmark',
                  hintText: 'e.g. Flat 101, Sunshine Heights',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Street & Area',
                  hintText: 'e.g. Santhapeta, Ongole',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Home', 'Office', 'Other'].map((tag) {
                  final isTagSelected = selectedTag == tag;
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isTagSelected,
                    onSelected: (val) {
                      if (val) setDialogState(() => selectedTag = tag);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelCtrl.text.isNotEmpty) {
                  locState.addAddress(
                    label: labelCtrl.text.trim(),
                    fullAddress: '${labelCtrl.text.trim()}, ${addressCtrl.text.trim()}, Ongole',
                    tag: selectedTag,
                  );
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save & Select'),
            ),
          ],
        ),
      ),
    );
  }
}
