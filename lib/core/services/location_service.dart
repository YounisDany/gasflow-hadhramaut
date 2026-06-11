import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/l10n.dart';

/// Result of a location request: either a [point] or a human-readable [error].
class LocationResult {
  final LatLng? point;
  final String? error;
  const LocationResult.success(this.point) : error = null;
  const LocationResult.failure(this.error) : point = null;

  bool get ok => point != null;
}

/// Thin wrapper around `geolocator` that handles the permission dance and
/// returns localized error messages. Works on web (over https/localhost),
/// Android and iOS.
class LocationService {
  LocationService._();

  static Future<LocationResult> current() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return LocationResult.failure(S.locationServicesDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationResult.failure(S.locationPermissionDenied);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LocationResult.success(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      return LocationResult.failure(S.locationPermissionDenied);
    }
  }
}
