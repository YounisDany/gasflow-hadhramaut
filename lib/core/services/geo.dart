import 'package:latlong2/latlong.dart';

/// Real geodesic distance + a rough ETA estimate between two points. Backed by
/// `latlong2`'s haversine [Distance] — no network or external routing service,
/// so it works fully offline. ETA assumes an average urban driving speed
/// suitable for Hadhrami city streets.
class Geo {
  Geo._();

  static const Distance _d = Distance();

  /// Average delivery speed (km/h) used to turn a straight-line distance into a
  /// human ETA. Kept conservative to account for non-straight roads.
  static const double _avgSpeedKmh = 22;

  /// Straight-line distance in kilometres between [a] and [b].
  static double km(LatLng a, LatLng b) =>
      _d.as(LengthUnit.Kilometer, a, b);

  /// Estimated arrival time in whole minutes for travelling [distanceKm].
  /// Always at least 1 minute so the UI never shows "0 min".
  static int etaMinutes(double distanceKm) {
    final mins = (distanceKm / _avgSpeedKmh) * 60;
    return mins < 1 ? 1 : mins.round();
  }

  /// Convenience: ETA in minutes directly from two points.
  static int etaBetween(LatLng a, LatLng b) => etaMinutes(km(a, b));
}
