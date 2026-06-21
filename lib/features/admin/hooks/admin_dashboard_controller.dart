import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/mock_analytics_repository.dart';
import '../domain/entities/analytics_report.dart';
import '../domain/repositories/analytics_repository.dart';

class AdminDashboardState {
  final AnalyticsReport? report;
  final bool isLoading;
  final String? errorMessage;

  AdminDashboardState({
    this.report,
    this.isLoading = false,
    this.errorMessage,
  });

  AdminDashboardState copyWith({
    AnalyticsReport? report,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminDashboardState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  final AnalyticsRepository _analyticsRepository;

  AdminDashboardController(this._analyticsRepository) : super(AdminDashboardState()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    try {
      final rep = await _analyticsRepository.getSystemAnalytics();
      state = state.copyWith(report: rep, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  // Can add Firebase live analytics repo if needed, defaults to Mock for presentation
  return MockAnalyticsRepository();
});

final adminDashboardControllerProvider =
    StateNotifierProvider<AdminDashboardController, AdminDashboardState>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return AdminDashboardController(repo);
});
