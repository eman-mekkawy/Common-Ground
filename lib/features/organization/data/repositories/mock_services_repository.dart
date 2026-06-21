import '../../domain/entities/support_service.dart';
import '../../domain/repositories/services_repository.dart';

class MockServicesRepository implements ServicesRepository {
  static final List<SupportService> _servicesDb = [
    SupportService(
      id: 'srv_erap',
      serviceName: 'Emergency Rental Assistance (ERAP)',
      category: 'Housing Support',
      description: 'Provides critical financial grants to low-income renters facing imminent eviction, foreclosure risk, or utility shutoffs due to employment crises.',
      eligibilityRules: 'Household monthly income must be less than \$2,500. Must provide proof of job loss, lease agreement, and eviction warning.',
      languages: ['en', 'ar'],
      city: 'North District',
      address: '124 Civic Center Road, North District',
      phone: '+1-555-0199',
      website: 'www.northdistrict.gov/erap',
      capacityStatus: 'High',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      incomeThreshold: 2500,
      minFamilySize: 1,
      lat: 40.7128,
      lng: -74.0060,
    ),
    SupportService(
      id: 'srv_foodbank',
      serviceName: 'Metro Food Bank Pantry',
      category: 'Food Assistance',
      description: 'Provides weekly distributions of organic produce, shelf-stable pantry items, canned goods, and dairy products to families facing nutritional gaps.',
      eligibilityRules: 'Open to all residents of North District experiencing financial hardship. Self-declaration is acceptable.',
      languages: ['en', 'ar'],
      city: 'North District',
      address: '404 Unity Way, North District',
      phone: '+1-555-0245',
      website: 'www.metrofoodbank.org',
      capacityStatus: 'High',
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      incomeThreshold: 3500,
      minFamilySize: 1,
      lat: 40.7250,
      lng: -74.0100,
    ),
    SupportService(
      id: 'srv_childcare',
      serviceName: 'Single Parent Childcare Subsidies',
      category: 'Childcare',
      description: 'Covers up to 80% of certified daycare costs to assist single mothers and fathers seeking work or studying.',
      eligibilityRules: 'Must be a single-parent household with at least one child under 6. Combined monthly income must be below \$3,500.',
      languages: ['en'],
      city: 'North District',
      address: '555 Care Circle, North District',
      phone: '+1-555-0377',
      website: 'www.childcarefund.org',
      capacityStatus: 'Medium',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      incomeThreshold: 3500,
      minFamilySize: 2,
      lat: 40.7090,
      lng: -73.9980,
    ),
    SupportService(
      id: 'srv_legalclinic',
      serviceName: 'Pro-Bono Legal Clinic',
      category: 'Legal Aid',
      description: 'Provides free legal guidance, consultations, and court representation for tenants facing unlawful evictions, lease disputes, or employer wage violations.',
      eligibilityRules: 'Income must be below \$2,000/month. Legal matters must be civil (non-criminal).',
      languages: ['en', 'ar'],
      city: 'North District',
      address: '10 Lawyers Row, North District',
      phone: '+1-555-0812',
      website: 'www.probonolegal.org',
      capacityStatus: 'Low',
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
      incomeThreshold: 2000,
      minFamilySize: 1,
      lat: 40.7180,
      lng: -74.0080,
    ),
    SupportService(
      id: 'srv_jobs',
      serviceName: 'Youth Vocational Training & Job Placement',
      category: 'Employment Support',
      description: 'Offers structured paid apprenticeships, resume audits, mock interviews, and career counseling to students and unemployed youths entering the labor force.',
      eligibilityRules: 'Ages 16-25, active student or recent graduate currently looking for work.',
      languages: ['en'],
      city: 'North District',
      address: '789 Opportunity Blvd, North District',
      phone: '+1-555-0955',
      website: 'www.nextgenemployment.org',
      capacityStatus: 'High',
      lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
      incomeThreshold: 0,
      minFamilySize: 1,
      lat: 40.7150,
      lng: -74.0010,
    ),
  ];

  @override
  Future<List<SupportService>> getAllServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_servicesDb);
  }

  @override
  Future<List<SupportService>> getServicesByOrganization(String orgUid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For demo simplicity, organizations manage a slice of services or all of them.
    // If they create services, it assigns their ID. Let's return services.
    return _servicesDb;
  }

  @override
  Future<void> addService(SupportService service) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _servicesDb.add(service);
  }

  @override
  Future<void> updateService(SupportService service) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _servicesDb.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _servicesDb[idx] = service;
    }
  }

  @override
  Future<void> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _servicesDb.removeWhere((s) => s.id == id);
  }
}
