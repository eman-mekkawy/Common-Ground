class Recommendation {
  final String serviceId;
  final String serviceName;
  final String category;
  final double confidenceScore; // 0-100 percentage
  final String confidenceCategory; // 'High', 'Medium', 'Low'
  final String reasoning;
  final double distanceKm;
  final String phone;
  final String address;
  final String website;

  Recommendation({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.confidenceScore,
    required this.confidenceCategory,
    required this.reasoning,
    required this.distanceKm,
    required this.phone,
    required this.address,
    required this.website,
  });
}
