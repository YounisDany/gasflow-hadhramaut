import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/avatar.dart';

/// Real camera-based QR / barcode scanner. Uses [mobile_scanner] to read the
/// citizen's QR (encoded as `GF|<name>|<code>`), then surfaces the matched
/// customer in a confirmation card. Falls back to showing the raw scanned value
/// when the code is not in the expected GasFlow format.
class BarcodeScannerScreen extends StatefulWidget {
  final bool embedded;
  const BarcodeScannerScreen({super.key, this.embedded = false});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
  );

  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  bool _detected = false;
  bool _torchOn = false;
  String _code = '';
  String _name = '';
  String _address = '';

  @override
  void dispose() {
    _scan.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;
    _parse(raw);
    setState(() => _detected = true);
    _controller.stop();
  }

  void _parse(String raw) {
    final ar = L10n.isAr;
    if (raw.startsWith('GF|')) {
      final parts = raw.split('|');
      _name = parts.length > 1 && parts[1].trim().isNotEmpty
          ? parts[1].trim()
          : (ar ? 'عميل GasFlow' : 'GasFlow customer');
      _code = parts.length > 2 ? parts[2].trim() : raw;
      _address = ar ? 'عميل معتمد' : 'Verified customer';
    } else {
      _code = raw;
      _name = ar ? 'رمز ممسوح' : 'Scanned code';
      _address = ar ? 'تحقّق من بيانات العميل' : 'Verify customer details';
    }
  }

  void _rescan() {
    setState(() {
      _detected = false;
      _code = '';
      _name = '';
      _address = '';
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.scanBarcode, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: Colors.white),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Live camera feed.
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) =>
                  _CameraError(error: error),
              fit: BoxFit.cover,
            ),
            // Dark scrim for readability.
            Container(color: Colors.black.withValues(alpha: 0.25)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.alignBarcode,
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        ..._buildCorners(),
                        if (!_detected)
                          AnimatedBuilder(
                            animation: _scan,
                            builder: (_, __) => Positioned(
                              left: 12,
                              right: 12,
                              top: 20 + (240 * _scan.value),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0),
                                      AppColors.primaryLight,
                                      AppColors.primary.withValues(alpha: 0),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.6),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_detected)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.success,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_detected)
                    Text(
                      S.searchingBarcode,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),
                ],
              ),
            ),
            if (_detected)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DetectedCard(
                    name: _name,
                    address: _address,
                    code: _code,
                    onDone: () => Navigator.pop(context),
                    onRescan: _rescan,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double size = 26;
    const double thickness = 4;
    Border cornerBorder({
      bool top = false,
      bool right = false,
      bool bottom = false,
      bool left = false,
    }) =>
        Border(
          top: top
              ? const BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          right: right
              ? const BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          bottom: bottom
              ? const BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: AppColors.primary, width: thickness)
              : BorderSide.none,
        );

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(border: cornerBorder(top: true, left: true)),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration:
              BoxDecoration(border: cornerBorder(top: true, right: true)),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration:
              BoxDecoration(border: cornerBorder(bottom: true, left: true)),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration:
              BoxDecoration(border: cornerBorder(bottom: true, right: true)),
        ),
      ),
    ];
  }
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;
  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    final ar = L10n.isAr;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded,
                color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text(
              denied
                  ? (ar
                      ? 'لم يتم منح إذن الكاميرا. فعّله من إعدادات التطبيق.'
                      : 'Camera permission denied. Enable it in app settings.')
                  : (ar
                      ? 'تعذّر تشغيل الكاميرا'
                      : 'Could not start the camera'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectedCard extends StatelessWidget {
  final String name;
  final String address;
  final String code;
  final VoidCallback onDone;
  final VoidCallback onRescan;
  const _DetectedCard({
    required this.name,
    required this.address,
    required this.code,
    required this.onDone,
    required this.onRescan,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'GF';
    if (parts.length == 1) return parts.first.characters.take(2).toString();
    return (parts[0].characters.first + parts[1].characters.first).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Avatar(initials: _initials, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(address, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    Text(S.verified,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    code,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryDark,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRescan,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(S.scanBarcode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.local_shipping_rounded, size: 20),
                  label: Text(S.confirmDelivery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
