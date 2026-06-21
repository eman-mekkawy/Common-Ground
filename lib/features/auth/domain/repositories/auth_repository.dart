import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> loginWithEmailAndPassword(String email, String password);
  
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
  });

  Future<AppUser> loginWithGoogle();

  Future<void> logout();

  Future<AppUser?> getCurrentUser();
}
