import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/hooks/auth_controller.dart';
import '../domain/entities/support_service.dart';
import '../domain/repositories/services_repository.dart';
import '../../citizen/hooks/citizen_flow_controller.dart';

class OrgDashboardState {
  final List<SupportService> services;
  final bool isLoading;
  final String? errorMessage;

  OrgDashboardState({
    this.services = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OrgDashboardState copyWith({
    List<SupportService>? services,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrgDashboardState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OrgDashboardController extends StateNotifier<OrgDashboardState> {
  final ServicesRepository _servicesRepository;
  final String? _orgUid;

  OrgDashboardController(this._servicesRepository, this._orgUid) : super(OrgDashboardState()) {
    loadServices();
  }

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true);
    final orgUid = _orgUid;
    try {
      final list = orgUid != null 
          ? await _servicesRepository.getServicesByOrganization(orgUid)
          : await _servicesRepository.getAllServices();
      state = state.copyWith(services: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<bool> saveService(SupportService service) async {
    state = state.copyWith(isLoading: true);
    try {
      final isNew = service.id.isEmpty;
      if (isNew) {
        // Generate mock ID if empty
        final newService = SupportService(
          id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
          serviceName: service.serviceName,
          category: service.category,
          description: service.description,
          eligibilityRules: service.eligibilityRules,
          languages: service.languages,
          city: service.city,
          address: service.address,
          phone: service.phone,
          website: service.website,
          capacityStatus: service.capacityStatus,
          lastUpdated: DateTime.now(),
          incomeThreshold: service.incomeThreshold,
          minFamilySize: service.minFamilySize,
          lat: service.lat,
          lng: service.lng,
        );
        await _servicesRepository.addService(newService);
      } else {
        final updatedService = SupportService(
          id: service.id,
          serviceName: service.serviceName,
          category: service.category,
          description: service.description,
          eligibilityRules: service.eligibilityRules,
          languages: service.languages,
          city: service.city,
          address: service.address,
          phone: service.phone,
          website: service.website,
          capacityStatus: service.capacityStatus,
          lastUpdated: DateTime.now(),
          incomeThreshold: service.incomeThreshold,
          minFamilySize: service.minFamilySize,
          lat: service.lat,
          lng: service.lng,
        );
        await _servicesRepository.updateService(updatedService);
      }
      await loadServices();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> updateCapacity(String serviceId, String newCapacity) async {
    final idx = state.services.indexWhere((s) => s.id == serviceId);
    if (idx == -1) return;

    final original = state.services[idx];
    final updated = SupportService(
      id: original.id,
      serviceName: original.serviceName,
      category: original.category,
      description: original.description,
      eligibilityRules: original.eligibilityRules,
      languages: original.languages,
      city: original.city,
      address: original.address,
      phone: original.phone,
      website: original.website,
      capacityStatus: newCapacity,
      lastUpdated: DateTime.now(),
      incomeThreshold: original.incomeThreshold,
      minFamilySize: original.minFamilySize,
      lat: original.lat,
      lng: original.lng,
    );

    try {
      await _servicesRepository.updateService(updated);
      await loadServices();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> delete(String serviceId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _servicesRepository.deleteService(serviceId);
      await loadServices();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

final orgDashboardControllerProvider =
    StateNotifierProvider<OrgDashboardController, OrgDashboardState>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  final user = ref.watch(authControllerProvider).user;
  return OrgDashboardController(repo, user?.uid);
});
