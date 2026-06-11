import '../../core/l10n/l10n.dart';

enum UserRole { admin, agent, citizen }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return S.roleAdmin;
      case UserRole.agent:
        return S.roleAgent;
      case UserRole.citizen:
        return S.roleCitizen;
    }
  }
}
