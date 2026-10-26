import '../models/dark_store_model.dart';
import '../../state/location_state.dart';

class MockDarkStoreRepository {
  static const DarkStore hub304 = DarkStore(
    id: 'store_304',
    displayId: '#304',
    name: 'Tanizkart Hub #304',
    locality: 'Lawyerpet, Ongole',
    fullAddress: 'D.No. 4-12, Lawyerpet Main Road, Near RTC Complex, Ongole, Andhra Pradesh 523001',
    operatingHours: '6:00 AM – 11:30 PM (Daily)',
    isOpen: true,
    statusMessage: 'Open & Dispatching in 10 mins',
    coverageLocalities: [
      'Lawyerpet',
      'Trunk Road',
      'South Bypass',
      'Collectorate Area',
      'RTC Colony',
      'Gandhi Road',
    ],
    coveragePincodes: ['523001', '523002'],
    latitude: 15.5057,
    longitude: 80.0499,
    contactPhone: '+91 98480 22338',
  );

  static DarkStore? getStoreForAddress(AddressItem? address) {
    if (address == null) return hub304;

    final full = address.fullAddress.toLowerCase();
    final label = address.label.toLowerCase();

    // Check if the address matches the Ongole service cluster
    if (full.contains('ongole') ||
        full.contains('lawyerpet') ||
        full.contains('trunk road') ||
        full.contains('bypass') ||
        label.contains('meadows') ||
        label.contains('enclave') ||
        label.contains('taniz')) {
      return hub304;
    }

    // Return null if completely outside coverage radius
    return null;
  }

  static String getDistanceForAddress(AddressItem? address) {
    if (address == null) return '1.2 km away';
    final full = address.fullAddress.toLowerCase();
    if (full.contains('lawyerpet')) {
      return '1.2 km away';
    } else if (full.contains('trunk road')) {
      return '2.4 km away';
    } else if (full.contains('bypass')) {
      return '3.8 km away';
    }
    return '1.2 km away';
  }
}
