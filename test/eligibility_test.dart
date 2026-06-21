import 'package:flutter_test/flutter_test.dart';
import 'package:commonground/features/citizen/domain/entities/situation.dart';
import 'package:commonground/features/citizen/data/services/gemini_ai_service.dart';
import 'package:commonground/features/citizen/data/services/eligibility_matching_engine.dart';
import 'package:commonground/features/organization/domain/entities/support_service.dart';

void main() {
  group('Crisis Detection Tests', () {
    final aiService = GeminiAiService();

    test('Should flag severe suicide risks immediately', () async {
      final situation = Situation(
        description: 'I feel extremely hopeless and want to end my life.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 1,
        monthlyIncome: 1000,
        urgencyLevel: 'high',
      );

      final result = await aiService.analyzeSituation(situation);
      expect(result.isCrisis, isTrue);
      expect(result.crisisType, equals('suicide_risk'));
    });

    test('Should flag domestic violence threats immediately', () async {
      final situation = Situation(
        description: 'My partner is beating me and I need domestic violence support.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 2,
        monthlyIncome: 800,
        urgencyLevel: 'high',
      );

      final result = await aiService.analyzeSituation(situation);
      expect(result.isCrisis, isTrue);
      expect(result.crisisType, equals('domestic_violence'));
    });

    test('Should not flag standard jobs/rent requests as crisis', () async {
      final situation = Situation(
        description: 'I lost my job and cannot pay rent next week.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 1,
        monthlyIncome: 500,
        urgencyLevel: 'high',
      );

      final result = await aiService.analyzeSituation(situation);
      expect(result.isCrisis, isFalse);
    });
  });

  group('Hybrid Matching - Rule-Based Filtering Tests', () {
    final aiService = GeminiAiService();
    final matchingEngine = EligibilityMatchingEngine(aiService);

    final mockServices = [
      SupportService(
        id: 'srv_test_income',
        serviceName: 'Low Income Assistance',
        category: 'Financial Assistance',
        description: 'Assistance for low earners.',
        eligibilityRules: 'Income must be under \$1,500.',
        languages: ['en'],
        city: 'North District',
        address: '123 Main St',
        phone: '555-1111',
        website: 'www.test.org',
        capacityStatus: 'High',
        lastUpdated: DateTime.now(),
        incomeThreshold: 1500, // Max Income 1500
        minFamilySize: 1,
        lat: 40.0,
        lng: -74.0,
      ),
      SupportService(
        id: 'srv_test_family',
        serviceName: 'Family Support Program',
        category: 'Housing Support',
        description: 'Assistance for larger families.',
        eligibilityRules: 'Household must be at least 3 people.',
        languages: ['en'],
        city: 'North District',
        address: '123 Main St',
        phone: '555-2222',
        website: 'www.test.org',
        capacityStatus: 'High',
        lastUpdated: DateTime.now(),
        incomeThreshold: 0, // No income cap
        minFamilySize: 3, // Min Family size 3
        lat: 40.0,
        lng: -74.0,
      ),
    ];

    test('Should filter out service when user income exceeds threshold', () async {
      final situation = Situation(
        description: 'I need financial assistance.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 1,
        monthlyIncome: 2000, // Income 2000 > Threshold 1500
        urgencyLevel: 'medium',
      );

      final matches = await matchingEngine.matchServices(
        situation: situation,
        allServices: mockServices,
      );

      // Low Income Assistance (srv_test_income) should be excluded
      final hasIncomeService = matches.any((m) => m.serviceId == 'srv_test_income');
      expect(hasIncomeService, isFalse);
    });

    test('Should filter out service when household size is below min limit', () async {
      final situation = Situation(
        description: 'Single renter housing help.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 1, // Household size 1 < Min 3
        monthlyIncome: 1200,
        urgencyLevel: 'medium',
      );

      final matches = await matchingEngine.matchServices(
        situation: situation,
        allServices: mockServices,
      );

      // Family Support Program (srv_test_family) should be excluded
      final hasFamilyService = matches.any((m) => m.serviceId == 'srv_test_family');
      expect(hasFamilyService, isFalse);
    });

    test('Should match services when rules are fully met', () async {
      final situation = Situation(
        description: 'Family needs assistance.',
        location: 'North District',
        preferredLanguage: 'en',
        householdSize: 4, // 4 >= Min 3 (Ok)
        monthlyIncome: 1200, // 1200 <= Max 1500 (Ok)
        urgencyLevel: 'medium',
      );

      final matches = await matchingEngine.matchServices(
        situation: situation,
        allServices: mockServices,
      );

      // Both should match
      expect(matches.length, equals(2));
      expect(matches.any((m) => m.serviceId == 'srv_test_income'), isTrue);
      expect(matches.any((m) => m.serviceId == 'srv_test_family'), isTrue);
    });
  });
}
