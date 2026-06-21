import 'dart:math';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/situation.dart';
import '../../../organization/domain/entities/support_service.dart';
import 'gemini_ai_service.dart';

class EligibilityMatchingEngine {
  final GeminiAiService _geminiService;

  EligibilityMatchingEngine(this._geminiService);

  /// Performs hybrid matching for a situation across all available services.
  Future<List<Recommendation>> matchServices({
    required Situation situation,
    required List<SupportService> allServices,
  }) async {
    final List<Recommendation> recommendations = [];

    for (final service in allServices) {
      // --- Step 1: Rule-Based Filtering ---
      
      // A. Location check (simple city match)
      final locationMatch = service.city.toLowerCase() == 'all' ||
          situation.location.trim().toLowerCase().contains(service.city.toLowerCase()) ||
          service.city.toLowerCase().contains(situation.location.trim().toLowerCase());
          
      if (!locationMatch) {
        continue; // Skip service if it is location restricted and doesn't match
      }

      // B. Income threshold limit check
      if (service.incomeThreshold > 0 && situation.monthlyIncome > service.incomeThreshold) {
        continue; // Exceeds income limit
      }

      // C. Family size requirement check
      if (situation.householdSize < service.minFamilySize) {
        continue; // Does not meet family size requirements
      }

      // --- Step 2: AI Matching & Reasoning ---
      final aiEvaluation = await _geminiService.evaluateEligibility(
        situation: situation,
        serviceName: service.serviceName,
        serviceDesc: service.description,
        eligibilityRules: service.eligibilityRules,
      );

      final percentage = (aiEvaluation['matchPercentage'] as num? ?? 50.0).toDouble();
      final category = aiEvaluation['confidenceCategory'] as String? ?? 'Medium';
      final reasoning = aiEvaluation['reasoning'] as String? ?? 'Based on matching parameters.';

      // --- Step 3: Distance Calculation (Mocked geo coordinates) ---
      final distance = _calculateMockDistance(situation.location, service.lat, service.lng);

      recommendations.add(
        Recommendation(
          serviceId: service.id,
          serviceName: service.serviceName,
          category: service.category,
          confidenceScore: percentage,
          confidenceCategory: category,
          reasoning: reasoning,
          distanceKm: distance,
          phone: service.phone,
          address: service.address,
          website: service.website,
        ),
      );
    }

    // Sort by confidence score descending
    recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return recommendations;
  }

  double _calculateMockDistance(String userLocation, double lat, double lng) {
    // Generate a stable distance based on the coordinates or location name hashing
    final random = Random(userLocation.hashCode ^ lat.hashCode ^ lng.hashCode);
    return double.parse((random.nextDouble() * 8.5 + 0.5).toStringAsFixed(1)); // 0.5 to 9.0 km
  }
}
