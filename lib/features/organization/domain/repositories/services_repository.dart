import '../entities/support_service.dart';

abstract class ServicesRepository {
  Future<List<SupportService>> getAllServices();
  
  Future<List<SupportService>> getServicesByOrganization(String orgUid);

  Future<void> addService(SupportService service);

  Future<void> updateService(SupportService service);
  
  Future<void> deleteService(String id);
}
