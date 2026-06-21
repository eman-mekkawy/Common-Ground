class Situation {
  final String description;
  final String location;
  final String preferredLanguage;
  final int householdSize;
  final double monthlyIncome;
  final String urgencyLevel; // 'low', 'medium', 'high'

  Situation({
    required this.description,
    required this.location,
    required this.preferredLanguage,
    required this.householdSize,
    required this.monthlyIncome,
    required this.urgencyLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'location': location,
      'preferredLanguage': preferredLanguage,
      'householdSize': householdSize,
      'monthlyIncome': monthlyIncome,
      'urgencyLevel': urgencyLevel,
    };
  }
}
