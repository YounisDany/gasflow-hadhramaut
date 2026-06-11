import '../../core/l10n/l10n.dart';
import 'app_status.dart';

class CitizenModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String addressEn;
  final String addressAr;
  final String phone;
  final String avatar;
  final String? barcodeId;
  final AppStatus status;
  final double? lat;
  final double? lng;

  const CitizenModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.addressEn,
    required this.addressAr,
    required this.phone,
    required this.avatar,
    required this.status,
    this.barcodeId,
    this.lat,
    this.lng,
  });

  String get name => L10n.isAr ? nameAr : nameEn;
  String get address => L10n.isAr ? addressAr : addressEn;
  bool get hasLocation => lat != null && lng != null;

  CitizenModel copyWith(
          {AppStatus? status, String? barcodeId, double? lat, double? lng}) =>
      CitizenModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        addressEn: addressEn,
        addressAr: addressAr,
        phone: phone,
        avatar: avatar,
        status: status ?? this.status,
        barcodeId: barcodeId ?? this.barcodeId,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  Map<String, dynamic> toMap() => {
        'nameEn': nameEn,
        'nameAr': nameAr,
        'addressEn': addressEn,
        'addressAr': addressAr,
        'phone': phone,
        'avatar': avatar,
        'barcodeId': barcodeId,
        'status': status.name,
        'lat': lat,
        'lng': lng,
      };

  factory CitizenModel.fromMap(String id, Map<String, dynamic> m) =>
      CitizenModel(
        id: id,
        nameEn: m['nameEn'] ?? '',
        nameAr: m['nameAr'] ?? '',
        addressEn: m['addressEn'] ?? '',
        addressAr: m['addressAr'] ?? '',
        phone: m['phone'] ?? '',
        avatar: m['avatar'] ?? '',
        barcodeId: m['barcodeId'],
        status: appStatusFromName(m['status']),
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
      );
}
