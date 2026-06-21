import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  @override
  Future<AppUser> loginWithEmailAndPassword(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Authentication failed. No user found.');
    }

    return await _getUserFromFirestore(credential.user!.uid, credential.user!.email ?? email);
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Registration failed.');
    }

    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      role: role,
      displayName: displayName.trim(),
    );

    // Save user profile & role in Firestore
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(userModel.toJson());

    return userModel;
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    // In production Flutter, Google Sign-In would be triggered via google_sign_in package.
    // Here we perform basic sign-in credentials check.
    throw UnimplementedError('Google Sign-In is configured on the platform client level.');
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    
    try {
      return await _getUserFromFirestore(fbUser.uid, fbUser.email ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> _getUserFromFirestore(String uid, String fallbackEmail) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    } else {
      // Default fallback if document does not exist yet (e.g. Google Sign-In direct)
      final fallbackUser = UserModel(
        uid: uid,
        email: fallbackEmail,
        role: UserRole.citizen,
        displayName: fallbackEmail.split('@').first.toUpperCase(),
      );
      await _firestore.collection('users').doc(uid).set(fallbackUser.toJson());
      return fallbackUser;
    }
  }
}
