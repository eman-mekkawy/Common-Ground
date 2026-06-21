import '../../domain/entities/analytics_report.dart';
import '../../domain/entities/demand_gap.dart';
import '../../domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsReport> getSystemAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return AnalyticsReport(
      totalRequests: 142,
      searchVolumeByCategory: {
        'Housing': 68,
        'Food': 42,
        'Financial': 35,
        'Legal': 24,
        'Childcare': 18,
        'Employment': 15,
      },
      serviceDemandByCategory: {
        'Housing': 55,
        'Food': 39,
        'Financial': 28,
        'Legal': 12,
        'Childcare': 10,
        'Employment': 8,
      },
      serviceGapAlerts: [
        DemandGap(
          district: 'North District',
          category: 'Housing Support',
          searchVolume: 68,
          activeCapacityStatus: 'Low',
          hasCriticalGap: true,
        ),
        DemandGap(
          district: 'East Ward',
          category: 'Childcare',
          searchVolume: 18,
          activeCapacityStatus: 'Low',
          hasCriticalGap: true,
        ),
        DemandGap(
          district: 'West District',
          category: 'Legal Aid',
          searchVolume: 24,
          activeCapacityStatus: 'Medium',
          hasCriticalGap: false,
        ),
      ],
    );
  }
}
