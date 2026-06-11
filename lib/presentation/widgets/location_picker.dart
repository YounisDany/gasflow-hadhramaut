import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Opens a full-screen interactive map so the user can drop a pin (tap the map)
/// or use their current GPS location. Returns the chosen [LatLng], or null if
/// cancelled.
Future<LatLng?> showLocationPicker(BuildContext context, {LatLng? initial}) {
  return Navigator.of(context).push<LatLng>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LocationPickerScreen(initial: initial),
    ),
  );
}

class _LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const _LocationPickerScreen({this.initial});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  final MapController _map = MapController();
  static const LatLng _fallback = LatLng(15.9437, 48.7888); // Seiyun
  LatLng? _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _useCurrent() async {
    setState(() => _locating = true);
    final res = await LocationService.current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (res.ok) {
      setState(() => _selected = res.point);
      _map.move(res.point!, 16);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.error ?? S.locationPermissionDenied),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.setLocation),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _selected ?? _fallback,
              initialZoom: _selected != null ? 16 : 12,
              minZoom: 3,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, latlng) => setState(() => _selected = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.younisdany.gas_app',
                maxZoom: 19,
              ),
              if (_selected != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _selected!,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.danger,
                      size: 48,
                    ),
                  ),
                ]),
            ],
          ),

          // Hint banner
          PositionedDirectional(
            top: 12,
            start: 12,
            end: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.tapMapToSetLocation,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const PositionedDirectional(
            start: 6,
            bottom: 92,
            child: _Attribution(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _locating ? null : _useCurrent,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded,
                        color: AppColors.primary),
                label: Text(
                  _locating ? S.gettingLocation : S.useCurrentLocation,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white),
                label: Text(
                  S.confirmLocation,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
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
