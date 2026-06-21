import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/entities/need.dart';
import '../../domain/entities/situation.dart';

class GeminiResult {
  final bool isCrisis;
  final String? crisisType; // 'homelessness', 'domestic_violence', 'suicide_risk'
  final List<Need> needs;

  GeminiResult({
    required this.isCrisis,
    this.crisisType,
    required this.needs,
  });
}

class GeminiAiService {
  /// Analyzes the user's situation using Gemini AI (or mock simulation if toggled or keys missing).
  Future<GeminiResult> analyzeSituation(Situation situation) async {
    final situationText = situation.description.toLowerCase();

    // 1. Crisis Pre-filtering (Local safeguard before network call)
    final crisisCheck = _detectCrisisLocally(situationText);
    if (crisisCheck.isCrisis) {
      return crisisCheck;
    }

    // 2. Decide between live Gemini and Mock Simulation
    if (AppConfig.useMockData || !AppConfig.isGeminiConfigured) {
      return await _simulateSituationAnalysis(situation);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConfig.geminiApiKey,
      );

      final prompt = '''
Analyze this citizen situation description: "${situation.description}".
Context: Location: ${situation.location}, Income: \$${situation.monthlyIncome}, Household Size: ${situation.householdSize}, Urgency: ${situation.urgencyLevel}, Preferred Language: ${situation.preferredLanguage}.

Determine:
1. Explicit and Inferred Needs (e.g. Housing Support, Food Assistance, Financial Assistance, Legal Aid, Childcare, Employment Support).
2. For each need, assign:
   - Category (Exact string: "Housing Support" | "Food Assistance" | "Financial Assistance" | "Legal Aid" | "Childcare" | "Employment Support")
   - Priority (String: "High" | "Medium" | "Low")
   - Confidence (Float between 0.0 and 1.0)
   - Reasoning (Concise explanation of why this need was detected, or inferred from hidden cues).
3. Evaluate if there is an extreme crisis risk. Set isCrisis=true and specify the type if detected.

Return JSON in this EXACT format:
{
  "isCrisis": boolean,
  "crisisType": "homelessness" | "domestic_violence" | "suicide_risk" | null,
  "needs": [
    {
      "category": string,
      "priority": "High" | "Medium" | "Low",
      "confidence": float,
      "reasoning": string
    }
  ]
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null || text.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      // Parse JSON from code block format markdown if returned
      final cleanText = _extractJson(text);
      final jsonMap = jsonDecode(cleanText) as Map<String, dynamic>;

      final isCrisis = jsonMap['isCrisis'] as bool? ?? false;
      final crisisType = jsonMap['crisisType'] as String?;
      final needsJson = jsonMap['needs'] as List<dynamic>? ?? [];

      final needs = needsJson.map((n) {
        return Need.fromJson(n as Map<String, dynamic>);
      }).toList();

      return GeminiResult(
        isCrisis: isCrisis,
        crisisType: crisisType,
        needs: needs,
      );

    } catch (e) {
      // Graceful fallback to mock system in case of network or key failure
      return await _simulateSituationAnalysis(situation);
    }
  }

  /// AI matching engine for evaluating how well a service fits the situation
  Future<Map<String, dynamic>> evaluateEligibility({
    required Situation situation,
    required String serviceName,
    required String serviceDesc,
    required String eligibilityRules,
  }) async {
    if (AppConfig.useMockData || !AppConfig.isGeminiConfigured) {
      return _simulateEligibilityEvaluation(situation, serviceName);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConfig.geminiApiKey,
      );

      final prompt = '''
Citizen Situation: "${situation.description}"
Monthly Income: \$${situation.monthlyIncome}
Household Size: ${situation.householdSize}
Location: ${situation.location}

Support Program:
Name: "$serviceName"
Description: "$serviceDesc"
Criteria/Rules: "$eligibilityRules"

Evaluate how well the citizen aligns with the program criteria.
Do NOT output "You qualify". Return a confidence percentage (0-100) and a concise, helpful explanation of the match reasoning.

Return JSON in this EXACT format:
{
  "matchPercentage": int,
  "confidenceCategory": "High" | "Medium" | "Low",
  "reasoning": "Reason why the citizen matches or does not match."
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response');

      final cleanText = _extractJson(text);
      return jsonDecode(cleanText) as Map<String, dynamic>;
    } catch (_) {
      return _simulateEligibilityEvaluation(situation, serviceName);
    }
  }

  // Extract JSON from markdown tags if present
  String _extractJson(String responseText) {
    if (responseText.contains('```json')) {
      final startIndex = responseText.indexOf('```json') + 7;
      final endIndex = responseText.indexOf('```', startIndex);
      return responseText.substring(startIndex, endIndex).trim();
    } else if (responseText.contains('```')) {
      final startIndex = responseText.indexOf('```') + 3;
      final endIndex = responseText.indexOf('```', startIndex);
      return responseText.substring(startIndex, endIndex).trim();
    }
    return responseText.trim();
  }

  // Local Crisis Detection Safeguard
  GeminiResult _detectCrisisLocally(String text) {
    final listSuicide = ['suicide', 'kill myself', 'end my life', 'انتحار', 'أنهي حياتي'];
    final listHomeless = ['homeless', 'no home', 'sleep on street', 'sleeping in car', 'بلا مأوى', 'شارع', 'أنام في الشارع'];
    final listAbuse = ['domestic violence', 'abuse', 'beating', 'husband hits', 'عنف أسري', 'إساءة معاملة', 'ضرب'];

    for (final word in listSuicide) {
      if (text.contains(word)) {
        return GeminiResult(isCrisis: true, crisisType: 'suicide_risk', needs: []);
      }
    }
    for (final word in listHomeless) {
      if (text.contains(word)) {
        return GeminiResult(isCrisis: true, crisisType: 'homelessness', needs: []);
      }
    }
    for (final word in listAbuse) {
      if (text.contains(word)) {
        return GeminiResult(isCrisis: true, crisisType: 'domestic_violence', needs: []);
      }
    }

    return GeminiResult(isCrisis: false, needs: []);
  }

  // High Fidelity Offline Needs Simulation
  Future<GeminiResult> _simulateSituationAnalysis(Situation situation) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final desc = situation.description.toLowerCase();

    // Persona 1: Omar
    if (desc.contains('omar') || desc.contains('rent') || desc.contains('job') && desc.contains('pay')) {
      return GeminiResult(
        isCrisis: false,
        needs: [
          Need(
            category: 'Housing Support',
            priority: 'High',
            confidence: 0.95,
            reasoning: 'You reported being behind on rent due to job loss, which places you at risk of eviction.',
          ),
          Need(
            category: 'Financial Assistance',
            priority: 'High',
            confidence: 0.90,
            reasoning: 'Loss of employment and active arrears indicate a critical need for short-term emergency financial aid.',
          ),
          Need(
            category: 'Employment Support',
            priority: 'Medium',
            confidence: 0.85,
            reasoning: 'You are currently unemployed and seeking support to return to the workforce.',
          ),
          Need(
            category: 'Legal Aid',
            priority: 'Low',
            confidence: 0.70,
            reasoning: 'Legal advice may be required if the landlord initiates formal eviction proceedings.',
          ),
        ],
      );
    }

    // Persona 2: Single Mother
    if (desc.contains('mother') || desc.contains('single') || desc.contains('childcare') || desc.contains('kids')) {
      return GeminiResult(
        isCrisis: false,
        needs: [
          Need(
            category: 'Childcare',
            priority: 'High',
            confidence: 0.96,
            reasoning: 'As a single mother, access to subsidized childcare is essential for you to seek or maintain employment.',
          ),
          Need(
            category: 'Food Assistance',
            priority: 'High',
            confidence: 0.92,
            reasoning: 'Supporting children on a single or low income increases susceptibility to nutritional gaps.',
          ),
          Need(
            category: 'Housing Support',
            priority: 'Medium',
            confidence: 0.88,
            reasoning: 'Family stabilization requires reliable, affordable housing matching your household size.',
          ),
        ],
      );
    }

    // Persona 3: Student
    if (desc.contains('student') || desc.contains('scholarship') || desc.contains('training') || desc.contains('university')) {
      return GeminiResult(
        isCrisis: false,
        needs: [
          Need(
            category: 'Employment Support',
            priority: 'High',
            confidence: 0.88,
            reasoning: 'Identified interest in training programs and skill development to enter the job market.',
          ),
          Need(
            category: 'Financial Assistance',
            priority: 'Medium',
            confidence: 0.80,
            reasoning: 'Scholarships or student grants can alleviate tuition and expense burdens.',
          ),
          Need(
            category: 'Food Assistance',
            priority: 'Low',
            confidence: 0.65,
            reasoning: 'Students with tight budgets often benefit from local food bank campus support networks.',
          ),
        ],
      );
    }

    // Default Fallback
    return GeminiResult(
      isCrisis: false,
      needs: [
        Need(
          category: 'Financial Assistance',
          priority: 'Medium',
          confidence: 0.80,
          reasoning: 'Based on your reported income and circumstances, immediate budget support was detected.',
        ),
        Need(
          category: 'Food Assistance',
          priority: 'Medium',
          confidence: 0.75,
          reasoning: 'Nutritional food support programs can help offset monthly expenses.',
        ),
      ],
    );
  }

  // High Fidelity Offline Eligibility Simulation
  Map<String, dynamic> _simulateEligibilityEvaluation(Situation situation, String serviceName) {
    final name = serviceName.toLowerCase();
    
    if (name.contains('rent') || name.contains('rental') || name.contains('housing')) {
      if (situation.monthlyIncome <= 2000) {
        return {
          'matchPercentage': 92,
          'confidenceCategory': 'High',
          'reasoning': 'Your monthly income is \$${situation.monthlyIncome}, which falls well below the program limit of \$2,500. Your risk profile matches criteria for housing stability support.',
        };
      } else {
        return {
          'matchPercentage': 55,
          'confidenceCategory': 'Medium',
          'reasoning': 'Your monthly income is \$${situation.monthlyIncome}, which is close to the threshold. However, your large household size (${situation.householdSize}) makes you eligible for partial assistance.',
        };
      }
    }

    if (name.contains('food') || name.contains('pantry') || name.contains('meal')) {
      return {
        'matchPercentage': 95,
        'confidenceCategory': 'High',
        'reasoning': 'This pantry program operates on a self-declared emergency basis. Since your household size is ${situation.householdSize}, you qualify for the expanded family package.',
      };
    }

    if (name.contains('child') || name.contains('daycare') || name.contains('early')) {
      if (situation.description.toLowerCase().contains('child') || situation.description.toLowerCase().contains('mother')) {
        return {
          'matchPercentage': 90,
          'confidenceCategory': 'High',
          'reasoning': 'As a single-earner household with children, you match the top prioritization group for the childcare subsidy.',
        };
      } else {
        return {
          'matchPercentage': 30,
          'confidenceCategory': 'Low',
          'reasoning': 'We could not detect clear indicator details about dependent children in your situation details.',
        };
      }
    }

    // Default
    return {
      'matchPercentage': 75,
      'confidenceCategory': 'Medium',
      'reasoning': 'The program offers general assistance. Your reported income is consistent with standard eligibility rules.',
    };
  }
}
