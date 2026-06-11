import '../../core/l10n/l10n.dart';
import 'app_status.dart';

class AgentModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String areaEn;
  final String areaAr;
  final String phone;
  final String avatar;
  final double rating;
  final double distanceKm;
  final int citizens;
  final AppStatus status;
  final double? lat;
  final double? lng;

  const AgentModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.areaEn,
    required this.areaAr,
    required this.phone,
    required this.avatar,
    required this.rating,
    required this.distanceKm,
    required this.citizens,
    required this.status,
    this.lat,
    this.lng,
  });

  String get name => L10n.isAr ? nameAr : nameEn;
  String get area => L10n.isAr ? areaAr : areaEn;
  bool get hasLocation => lat != null && lng != null;

  AgentModel copyWith({AppStatus? status, double? lat, double? lng}) =>
      AgentModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        areaEn: areaEn,
        areaAr: areaAr,
        phone: phone,
        avatar: avatar,
        rating: rating,
        distanceKm: distanceKm,
        citizens: citizens,
        status: status ?? this.status,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  Map<String, dynamic> toMap() => {
        'nameEn': nameEn,
        'nameAr': nameAr,
        'areaEn': areaEn,
        'areaAr': areaAr,
        'phone': phone,
        'avatar': avatar,
        'rating': rating,
        'distanceKm': distanceKm,
        'citizens': citizens,
        'status': status.name,
        'lat': lat,
        'lng': lng,
      };

  factory AgentModel.fromMap(String id, Map<String, dynamic> m) => AgentModel(
        id: id,
        nameEn: m['nameEn'] ?? '',
        nameAr: m['nameAr'] ?? '',
        areaEn: m['areaEn'] ?? '',
        areaAr: m['areaAr'] ?? '',
        phone: m['phone'] ?? '',
        avatar: m['avatar'] ?? '',
        rating: (m['rating'] ?? 0).toDouble(),
        distanceKm: (m['distanceKm'] ?? 0).toDouble(),
        citizens: (m['citizens'] ?? 0).toInt(),
        status: appStatusFromName(m['status']),
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
      );
}
