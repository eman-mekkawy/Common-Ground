import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organization/data/repositories/mock_services_repository.dart';
import '../../organization/data/repositories/firestore_services_repository.dart';
import '../../organization/domain/repositories/services_repository.dart';
import '../../../core/config/app_config.dart';
import '../data/services/eligibility_matching_engine.dart';
import '../data/services/gemini_ai_service.dart';
import '../domain/entities/need.dart';
import '../domain/entities/recommendation.dart';
import '../domain/entities/situation.dart';

class CitizenFlowState {
  final Situation? situation;
  final bool isLoading;
  final bool isCrisis;
  final String? crisisType;
  final List<Need> detectedNeeds;
  final List<Recommendation> recommendations;
  final String? errorMessage;

  CitizenFlowState({
    this.situation,
    this.isLoading = false,
    this.isCrisis = false,
    this.crisisType,
    this.detectedNeeds = const [],
    this.recommendations = const [],
    this.errorMessage,
  });

  CitizenFlowState copyWith({
    Situation? situation,
    bool? isLoading,
    bool? isCrisis,
    String? crisisType,
    List<Need>? detectedNeeds,
    List<Recommendation>? recommendations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CitizenFlowState(
      situation: situation ?? this.situation,
      isLoading: isLoading ?? this.isLoading,
      isCrisis: isCrisis ?? this.isCrisis,
      crisisType: crisisType ?? this.crisisType,
      detectedNeeds: detectedNeeds ?? this.detectedNeeds,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CitizenFlowController extends StateNotifier<CitizenFlowState> {
  final GeminiAiService _geminiService;
  final ServicesRepository _servicesRepository;
  final EligibilityMatchingEngine _matchingEngine;

  CitizenFlowController(
    this._geminiService,
    this._servicesRepository,
    this._matchingEngine,
  ) : super(CitizenFlowState());

  void resetFlow() {
    state = CitizenFlowState();
  }

  Future<void> submitSituation(Situation situation) async {
    state = state.copyWith(isLoading: true, clearError: true, situation: situation);

    try {
      // 1. Analyze situation & detect needs / crisis
      final analysis = await _geminiService.analyzeSituation(situation);

      if (analysis.isCrisis) {
        state = state.copyWith(
          isLoading: false,
          isCrisis: true,
          crisisType: analysis.crisisType,
        );
        return;
      }

      // 2. Fetch all services
      final services = await _servicesRepository.getAllServices();

      // 3. Match services with rule-based filtering + Gemini
      final matches = await _matchingEngine.matchServices(
        situation: situation,
        allServices: services,
      );

      state = state.copyWith(
        isLoading: false,
        isCrisis: false,
        detectedNeeds: analysis.needs,
        recommendations: matches,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Service & Engine injection providers
final geminiServiceProvider = Provider<GeminiAiService>((ref) {
  return GeminiAiService();
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockServicesRepository();
  } else {
    return FirestoreServicesRepository();
  }
});

final eligibilityEngineProvider = Provider<EligibilityMatchingEngine>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return EligibilityMatchingEngine(gemini);
});

final citizenFlowControllerProvider =
    StateNotifierProvider<CitizenFlowController, CitizenFlowState>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  final repo = ref.watch(servicesRepositoryProvider);
  final engine = ref.watch(eligibilityEngineProvider);
  return CitizenFlowController(gemini, repo, engine);
});
