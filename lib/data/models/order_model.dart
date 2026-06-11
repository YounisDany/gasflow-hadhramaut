import '../../core/l10n/l10n.dart';
import 'app_status.dart';

class OrderModel {
  final String id;
  final String citizenNameEn;
  final String citizenNameAr;
  final String citizenAvatar;
  final String addressEn;
  final String addressAr;
  final int cylinders;
  final String size;
  final double total;
  final DateTime requestedAt;
  final AppStatus status;

  const OrderModel({
    required this.id,
    required this.citizenNameEn,
    required this.citizenNameAr,
    required this.citizenAvatar,
    required this.addressEn,
    required this.addressAr,
    required this.cylinders,
    required this.size,
    required this.total,
    required this.requestedAt,
    required this.status,
  });

  String get citizenName => L10n.isAr ? citizenNameAr : citizenNameEn;
  String get address => L10n.isAr ? addressAr : addressEn;

  OrderModel copyWith({AppStatus? status}) => OrderModel(
        id: id,
        citizenNameEn: citizenNameEn,
        citizenNameAr: citizenNameAr,
        citizenAvatar: citizenAvatar,
        addressEn: addressEn,
        addressAr: addressAr,
        cylinders: cylinders,
        size: size,
        total: total,
        requestedAt: requestedAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'citizenNameEn': citizenNameEn,
        'citizenNameAr': citizenNameAr,
        'citizenAvatar': citizenAvatar,
        'addressEn': addressEn,
        'addressAr': addressAr,
        'cylinders': cylinders,
        'size': size,
        'total': total,
        'requestedAt': requestedAt.millisecondsSinceEpoch,
        'status': status.name,
      };

  factory OrderModel.fromMap(String id, Map<String, dynamic> m) => OrderModel(
        id: id,
        citizenNameEn: m['citizenNameEn'] ?? '',
        citizenNameAr: m['citizenNameAr'] ?? '',
        citizenAvatar: m['citizenAvatar'] ?? '',
        addressEn: m['addressEn'] ?? '',
        addressAr: m['addressAr'] ?? '',
        cylinders: (m['cylinders'] ?? 1).toInt(),
        size: m['size'] ?? '12 kg',
        total: (m['total'] ?? 0).toDouble(),
        requestedAt: DateTime.fromMillisecondsSinceEpoch(
            (m['requestedAt'] ?? 0).toInt()),
        status: appStatusFromName(m['status']),
      );
}
