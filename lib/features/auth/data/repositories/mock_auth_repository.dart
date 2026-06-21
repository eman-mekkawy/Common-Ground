import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  static const String _prefUserKey = 'mock_current_user_uid';
  static final Map<String, UserModel> _mockUsersDb = {
    'citizen_omar': UserModel(
      uid: 'citizen_omar',
      email: 'omar@commonground.org',
      role: UserRole.citizen,
      displayName: 'Omar Al-Fayed',
    ),
    'citizen_maria': UserModel(
      uid: 'citizen_maria',
      email: 'maria@commonground.org',
      role: UserRole.citizen,
      displayName: 'Maria Rodriguez',
    ),
    'citizen_student': UserModel(
      uid: 'citizen_student',
      email: 'student@commonground.org',
      role: UserRole.citizen,
      displayName: 'Alex Chen',
    ),
    'org_foodbank': UserModel(
      uid: 'org_foodbank',
      email: 'contact@metrofoodbank.org',
      role: UserRole.organization,
      displayName: 'Metro Food Bank & Housing',
    ),
    'admin_main': UserModel(
      uid: 'admin_main',
      email: 'admin@commonground.org',
      role: UserRole.admin,
      displayName: 'System Admin',
    ),
  };

  UserModel? _currentUser;

  @override
  Future<AppUser> loginWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate networking
    
    // Find in mock DB
    for (final user in _mockUsersDb.values) {
      if (user.email.trim().toLowerCase() == email.trim().toLowerCase()) {
        _currentUser = user;
        await _saveSession(user.uid);
        return user;
      }
    }

    // Default auto-creation for quick demo testing if user doesn't exist
    final cleanEmail = email.trim();
    final name = cleanEmail.split('@').first;
    final newUser = UserModel(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      role: email.contains('org') ? UserRole.organization : (email.contains('admin') ? UserRole.admin : UserRole.citizen),
      displayName: name.toUpperCase(),
    );
    _mockUsersDb[newUser.uid] = newUser;
    _currentUser = newUser;
    await _saveSession(newUser.uid);
    return newUser;
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final newUser = UserModel(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      role: role,
      displayName: displayName.trim().isEmpty ? 'User' : displayName.trim(),
    );
    
    _mockUsersDb[newUser.uid] = newUser;
    _currentUser = newUser;
    await _saveSession(newUser.uid);
    return newUser;
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Default mock citizen
    final omar = _mockUsersDb['citizen_omar']!;
    _currentUser = omar;
    await _saveSession(omar.uid);
    return omar;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserKey);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_prefUserKey);
    if (uid != null && _mockUsersDb.containsKey(uid)) {
      _currentUser = _mockUsersDb[uid];
    }
    return _currentUser;
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, uid);
  }
}
