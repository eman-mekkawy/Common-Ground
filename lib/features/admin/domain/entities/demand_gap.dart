class DemandGap {
  final String district;
  final String category;
  final int searchVolume;
  final String activeCapacityStatus; // 'High', 'Medium', 'Low'
  final bool hasCriticalGap;

  DemandGap({
    required this.district,
    required this.category,
    required this.searchVolume,
    required this.activeCapacityStatus,
    required this.hasCriticalGap,
  });
}
