import 'package:flutter/foundation.dart';

class AddressItem {
  final String id;
  final String label;
  final String fullAddress;
  final String tag; // Home, Office, Other
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.tag,
    this.isDefault = false,
  });
}

class LocationState extends ChangeNotifier {
  final List<AddressItem> _addresses = [
    const AddressItem(
      id: 'addr_1',
      label: 'Flat 302, Green Meadows',
      fullAddress: 'Flat 302, Green Meadows, Lawyerpet, Ongole, Andhra Pradesh',
      tag: 'Home',
      isDefault: true,
    ),
    const AddressItem(
      id: 'addr_2',
      label: 'Taniz HQ, Trunk Road',
      fullAddress: 'Tech Park, 4th Floor, Trunk Road, Ongole, Andhra Pradesh',
      tag: 'Office',
    ),
    const AddressItem(
      id: 'addr_3',
      label: 'Haritha Enclave Villa 14',
      fullAddress: 'Villa 14, Haritha Enclave, South Bypass, Ongole, Andhra Pradesh',
      tag: 'Other',
    ),
  ];

  late AddressItem _selectedAddress;

  LocationState() {
    _selectedAddress = _addresses.first;
  }

  List<AddressItem> get addresses => List.unmodifiable(_addresses);
  AddressItem get selectedAddress => _selectedAddress;

  void selectAddress(AddressItem address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress({
    required String label,
    required String fullAddress,
    required String tag,
  }) {
    final newAddress = AddressItem(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      fullAddress: fullAddress,
      tag: tag,
    );
    _addresses.add(newAddress);
    _selectedAddress = newAddress;
    notifyListeners();
  }
}
