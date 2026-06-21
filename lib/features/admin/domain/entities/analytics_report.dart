import 'demand_gap.dart';

class AnalyticsReport {
  final int totalRequests;
  final Map<String, int> searchVolumeByCategory;
  final Map<String, int> serviceDemandByCategory;
  final List<DemandGap> serviceGapAlerts;

  AnalyticsReport({
    required this.totalRequests,
    required this.searchVolumeByCategory,
    required this.serviceDemandByCategory,
    required this.serviceGapAlerts,
  });
}
