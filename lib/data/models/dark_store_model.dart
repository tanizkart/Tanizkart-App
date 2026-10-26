class DarkStore {
  final String id;
  final String displayId;
  final String name;
  final String locality;
  final String fullAddress;
  final String operatingHours;
  final bool isOpen;
  final String statusMessage;
  final List<String> coverageLocalities;
  final List<String> coveragePincodes;
  final double latitude;
  final double longitude;
  final String contactPhone;

  const DarkStore({
    required this.id,
    required this.displayId,
    required this.name,
    required this.locality,
    required this.fullAddress,
    required this.operatingHours,
    this.isOpen = true,
    required this.statusMessage,
    required this.coverageLocalities,
    required this.coveragePincodes,
    required this.latitude,
    required this.longitude,
    required this.contactPhone,
  });
}
