import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';

enum NotificationType { agentApproved, citizenApproved, order, complaint, system }

NotificationType notificationTypeFromName(Object? name) =>
    NotificationType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => NotificationType.system,
    );

class NotificationModel {
  final String id;
  final NotificationType type;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final DateTime createdAt;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.createdAt,
    this.read = false,
  });

  String get title => L10n.isAr ? titleAr : titleEn;
  String get body => L10n.isAr ? bodyAr : bodyEn;

  NotificationModel copyWith({bool? read}) => NotificationModel(
        id: id,
        type: type,
        titleEn: titleEn,
        titleAr: titleAr,
        bodyEn: bodyEn,
        bodyAr: bodyAr,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'bodyEn': bodyEn,
        'bodyAr': bodyAr,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'read': read,
      };

  factory NotificationModel.fromMap(String id, Map<String, dynamic> m) =>
      NotificationModel(
        id: id,
        type: notificationTypeFromName(m['type']),
        titleEn: m['titleEn'] ?? '',
        titleAr: m['titleAr'] ?? '',
        bodyEn: m['bodyEn'] ?? '',
        bodyAr: m['bodyAr'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] ?? 0).toInt()),
        read: m['read'] ?? false,
      );

  IconData get icon {
    switch (type) {
      case NotificationType.agentApproved:
        return Icons.verified_user_rounded;
      case NotificationType.citizenApproved:
        return Icons.how_to_reg_rounded;
      case NotificationType.order:
        return Icons.local_shipping_rounded;
      case NotificationType.complaint:
        return Icons.report_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.agentApproved:
      case NotificationType.citizenApproved:
        return AppColors.success;
      case NotificationType.order:
        return AppColors.primary;
      case NotificationType.complaint:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.info;
    }
  }
}
