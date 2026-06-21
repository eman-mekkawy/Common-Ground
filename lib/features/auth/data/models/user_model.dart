import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.displayName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'citizen'),
      displayName: json['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role.toShortString(),
      'displayName': displayName,
    };
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
    );
  }
}
