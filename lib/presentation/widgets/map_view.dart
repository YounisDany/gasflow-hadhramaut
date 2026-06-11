import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A point to render on the map (an agent, a citizen, …).
class MapPin {
  final LatLng point;
  final String label;
  final String avatar; // initials shown inside the badge
  final Color color;
  const MapPin({
    required this.point,
    required this.label,
    this.avatar = '',
    this.color = AppColors.primary,
  });
}

/// Real OpenStreetMap-backed map (no API key required). Renders [pins] as
/// tappable badges and an optional pulsing [userLocation] dot. Used full-screen
/// on the citizen home and as an embedded card on the agent home.
class MapView extends StatefulWidget {
  final List<MapPin> pins;
  final int selectedIndex;
  final ValueChanged<int>? onSelect;
  final LatLng? userLocation;

  /// Optional ordered points to draw as a route line (e.g. agent → citizen).
  /// Null or fewer than two points draws nothing.
  final List<LatLng>? route;

  /// Fallback center when there are no pins and no user location.
  final LatLng fallbackCenter;

  const MapView({
    super.key,
    required this.pins,
    this.selectedIndex = -1,
    this.onSelect,
    this.userLocation,
    this.route,
    this.fallbackCenter = const LatLng(15.9437, 48.7888), // Seiyun, Hadhramaut
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with SingleTickerProviderStateMixin {
  final MapController _map = MapController();
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();
  bool _ready = false;

  LatLng get _initialCenter {
    if (widget.userLocation != null) return widget.userLocation!;
    if (widget.pins.isNotEmpty) return widget.pins.first.point;
    return widget.fallbackCenter;
  }

  List<LatLng> get _allPoints => [
        ...widget.pins.map((p) => p.point),
        if (widget.userLocation != null) widget.userLocation!,
      ];

  void _fit() {
    final pts = _allPoints;
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _map.move(pts.first, 14);
      return;
    }
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pts),
        padding: const EdgeInsets.all(64),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MapView old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    final i = widget.selectedIndex;
    if (i != old.selectedIndex && i >= 0 && i < widget.pins.length) {
      final zoom = _map.camera.zoom.clamp(13.0, 18.0);
      _map.move(widget.pins[i].point, zoom);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 13,
            minZoom: 3,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () {
              _ready = true;
              _fit();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.younisdany.gas_app',
              maxZoom: 19,
            ),
            if (widget.route != null && widget.route!.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.route!,
                    strokeWidth: 4,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
            if (widget.userLocation != null)
              MarkerLayer(markers: [_userMarker(widget.userLocation!)]),
            MarkerLayer(markers: [
              for (int i = 0; i < widget.pins.length; i++)
                _pinMarker(widget.pins[i], i == widget.selectedIndex, i),
            ]),
          ],
        ),

        // OSM attribution (required by tile usage policy).
        const PositionedDirectional(
          start: 6,
          bottom: 4,
          child: _Attribution(),
        ),

        // Recenter on the user location.
        if (widget.userLocation != null)
          PositionedDirectional(
            end: 14,
            bottom: 18,
            child: _RoundButton(
              icon: Icons.my_location_rounded,
              onTap: () => _map.move(widget.userLocation!, 15),
            ),
          ),
      ],
    );
  }

  Marker _userMarker(LatLng p) => Marker(
        point: p,
        width: 44,
        height: 44,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) {
            final v = _pulse.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44 * v,
                  height: 44 * v,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.info.withValues(alpha: 0.18 * (1 - v)),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.info,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

  Marker _pinMarker(MapPin pin, bool selected, int index) {
    final double size = selected ? 46 : 34;
    return Marker(
      point: pin.point,
      width: 120,
      height: 64,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect == null ? null : () => widget.onSelect!(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  pin.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pin.color,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: pin.color.withValues(alpha: 0.4),
                    blurRadius: selected ? 14 : 6,
                    spreadRadius: selected ? 1 : 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: pin.avatar.isEmpty
                  ? Icon(Icons.local_fire_department_rounded,
                      color: Colors.white, size: selected ? 22 : 16)
                  : Text(
                      pin.avatar,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: selected ? 14 : 11,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '© OpenStreetMap',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 9,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
