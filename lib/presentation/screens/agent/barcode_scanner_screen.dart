import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/avatar.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final bool embedded;
  const BarcodeScannerScreen({super.key, this.embedded = false});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  Timer? _timer;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _detected = true);
    });
  }

  @override
  void dispose() {
    _scan.dispose();
    _timer?.cancel();
    super.dispose();
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
        title: Text(S.scanBarcode,
            style: const TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12, left: 12),
            child: Icon(Icons.flash_on_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.textPrimary,
                    AppColors.textPrimary.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.alignBarcode,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70),
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
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        ..._buildCorners(),
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
                  if (_detected)
                    _DetectedCard(onDone: () => Navigator.pop(context))
                  else
                    Text(
                      S.searchingBarcode,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),
                ],
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
          decoration: BoxDecoration(
              border: cornerBorder(top: true, right: true)),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              border: cornerBorder(bottom: true, left: true)),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              border: cornerBorder(bottom: true, right: true)),
        ),
      ),
    ];
  }
}

class _DetectedCard extends StatelessWidget {
  final VoidCallback onDone;
  const _DetectedCard({required this.onDone});

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
        children: [
          Row(
            children: [
              const Avatar(initials: 'OS', size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L10n.isAr ? 'عمر السبيعي' : 'Omar Al-Subaie',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      L10n.isAr
                          ? 'شقة 12 ب، المربع'
                          : 'Apartment 12B, Al Murabba',
                      style: AppTextStyles.bodySmall,
                    ),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
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
                Text(
                  'GF-9C-2031',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryDark,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.local_shipping_rounded, size: 20),
              label: Text(S.confirmDelivery),
            ),
          ),
        ],
      ),
    );
  }
}
