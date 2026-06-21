import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/support_service.dart';
import '../../domain/repositories/services_repository.dart';

class FirestoreServicesRepository implements ServicesRepository {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  @override
  Future<List<SupportService>> getAllServices() async {
    final snapshot = await _firestore.collection('services').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return SupportService.fromJson(data);
    }).toList();
  }

  @override
  Future<List<SupportService>> getServicesByOrganization(String orgUid) async {
    final snapshot = await _firestore
        .collection('services')
        .where('orgUid', isEqualTo: orgUid)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return SupportService.fromJson(data);
    }).toList();
  }

  @override
  Future<void> addService(SupportService service) async {
    final json = service.toJson();
    json.remove('id'); // Firestore generates the doc ID
    await _firestore.collection('services').add(json);
  }

  @override
  Future<void> updateService(SupportService service) async {
    await _firestore
        .collection('services')
        .doc(service.id)
        .update(service.toJson());
  }

  @override
  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).delete();
  }
}
