import '../../core/l10n/l10n.dart';
import 'app_status.dart';

class ComplaintModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final DateTime createdAt;
  final AppStatus status;

  const ComplaintModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.createdAt,
    required this.status,
  });

  String get title => L10n.isAr ? titleAr : titleEn;
  String get description => L10n.isAr ? descriptionAr : descriptionEn;

  ComplaintModel copyWith({AppStatus? status}) => ComplaintModel(
        id: id,
        titleEn: titleEn,
        titleAr: titleAr,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'titleEn': titleEn,
        'titleAr': titleAr,
        'descriptionEn': descriptionEn,
        'descriptionAr': descriptionAr,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status.name,
      };

  factory ComplaintModel.fromMap(String id, Map<String, dynamic> m) =>
      ComplaintModel(
        id: id,
        titleEn: m['titleEn'] ?? '',
        titleAr: m['titleAr'] ?? '',
        descriptionEn: m['descriptionEn'] ?? '',
        descriptionAr: m['descriptionAr'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] ?? 0).toInt()),
        status: appStatusFromName(m['status']),
      );
}
