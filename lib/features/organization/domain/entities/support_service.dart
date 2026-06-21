class SupportService {
  final String id;
  final String serviceName;
  final String category;
  final String description;
  final String eligibilityRules; // Text description of rules
  final List<String> languages;
  final String city;
  final String address;
  final String phone;
  final String website;
  final String capacityStatus; // 'High', 'Medium', 'Low'
  final DateTime lastUpdated;

  // Step 1 Rule-Based fields
  final double incomeThreshold; // Maximum monthly income (0 means no limit)
  final int minFamilySize; // Minimum family size required
  final double lat; // Mock location latitude
  final double lng; // Mock location longitude

  SupportService({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.eligibilityRules,
    required this.languages,
    required this.city,
    required this.address,
    required this.phone,
    required this.website,
    required this.capacityStatus,
    required this.lastUpdated,
    required this.incomeThreshold,
    required this.minFamilySize,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'category': category,
      'description': description,
      'eligibilityRules': eligibilityRules,
      'languages': languages,
      'city': city,
      'address': address,
      'phone': phone,
      'website': website,
      'capacityStatus': capacityStatus,
      'lastUpdated': lastUpdated.toIso8601String(),
      'incomeThreshold': incomeThreshold,
      'minFamilySize': minFamilySize,
      'lat': lat,
      'lng': lng,
    };
  }

  factory SupportService.fromJson(Map<String, dynamic> json) {
    return SupportService(
      id: json['id'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eligibilityRules: json['eligibilityRules'] as String? ?? '',
      languages: List<String>.from(json['languages'] as List<dynamic>? ?? []),
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      capacityStatus: json['capacityStatus'] as String? ?? 'High',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
      incomeThreshold: (json['incomeThreshold'] as num? ?? 0.0).toDouble(),
      minFamilySize: json['minFamilySize'] as int? ?? 0,
      lat: (json['lat'] as num? ?? 0.0).toDouble(),
      lng: (json['lng'] as num? ?? 0.0).toDouble(),
    );
  }
}
