enum UserRole {
  citizen,
  organization,
  admin;

  static UserRole fromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'organization':
      case 'org':
        return UserRole.organization;
      case 'admin':
        return UserRole.admin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }

  String toShortString() {
    switch (this) {
      case UserRole.organization:
        return 'org';
      case UserRole.admin:
        return 'admin';
      case UserRole.citizen:
        return 'citizen';
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final UserRole role;
  final String displayName;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.displayName,
  });
}
