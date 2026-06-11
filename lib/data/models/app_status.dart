import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';

enum AppStatus { pending, accepted, rejected, completed, suspended }

/// Parse a Firestore-stored status name back to the enum (defaults to pending).
AppStatus appStatusFromName(Object? name) => AppStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppStatus.pending,
    );

extension AppStatusX on AppStatus {
  String get label {
    switch (this) {
      case AppStatus.pending:
        return S.statusPending;
      case AppStatus.accepted:
        return S.statusAccepted;
      case AppStatus.rejected:
        return S.statusRejected;
      case AppStatus.completed:
        return S.statusCompleted;
      case AppStatus.suspended:
        return S.statusSuspended;
    }
  }

  Color get color {
    switch (this) {
      case AppStatus.pending:
        return AppColors.warning;
      case AppStatus.accepted:
        return AppColors.success;
      case AppStatus.rejected:
        return AppColors.danger;
      case AppStatus.completed:
        return AppColors.primary;
      case AppStatus.suspended:
        return AppColors.textHint;
    }
  }

  Color get softColor {
    switch (this) {
      case AppStatus.pending:
        return AppColors.warningSoft;
      case AppStatus.accepted:
        return AppColors.successSoft;
      case AppStatus.rejected:
        return AppColors.dangerSoft;
      case AppStatus.completed:
        return AppColors.primarySoft;
      case AppStatus.suspended:
        return AppColors.divider;
    }
  }

  IconData get icon {
    switch (this) {
      case AppStatus.pending:
        return Icons.schedule_rounded;
      case AppStatus.accepted:
        return Icons.check_circle_rounded;
      case AppStatus.rejected:
        return Icons.cancel_rounded;
      case AppStatus.completed:
        return Icons.verified_rounded;
      case AppStatus.suspended:
        return Icons.pause_circle_rounded;
    }
  }
}
