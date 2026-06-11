import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Silhouette of Shibam's mudbrick tower-houses — the "Manhattan of the
/// desert". The layout is deterministic (fixed RNG seed) so it never flickers
/// between repaints, and windows are drawn as the signature whitewashed
/// openings of Hadhrami architecture.
class ShibamSkylinePainter extends CustomPainter {
  final Color color;
  final Color windowColor;
  const ShibamSkylinePainter({
    this.color = AppColors.clay,
    this.windowColor = AppColors.warmWhite,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final body = Paint()..color = color;
    final cap = Paint()..color = windowColor.withValues(alpha: 0.5);
    final win = Paint()..color = windowColor.withValues(alpha: 0.85);
    final rng = Random(11); // deterministic skyline
    final w = size.width;
    final h = size.height;

    double x = -8;
    while (x < w) {
      final tw = w * (0.055 + rng.nextDouble() * 0.05);
      final th = h * (0.5 + rng.nextDouble() * 0.48);
      final top = h - th;
      final bw = tw - 3;

      // Tower body with a softly rounded crown.
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, bw, th + 2),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rrect, body);

      // Whitewashed parapet line.
      canvas.drawRect(Rect.fromLTWH(x, top, bw, 3), cap);

      // Window grid.
      final ws = (bw * 0.16).clamp(2.0, 5.0);
      final gap = ws * 1.5;
      final cols = ((bw + gap) / (ws + gap)).floor().clamp(1, 3);
      final usedW = cols * ws + (cols - 1) * gap;
      final startX = x + (bw - usedW) / 2;
      for (int rIdx = 0; rIdx < 4; rIdx++) {
        final wy = top + 9 + rIdx * (ws + gap);
        if (wy > h - ws) break;
        for (int c = 0; c < cols; c++) {
          final wx = startX + c * (ws + gap);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(wx, wy, ws, ws * 1.3),
              const Radius.circular(1),
            ),
            win,
          );
        }
      }
      x += tw;
    }
  }

  @override
  bool shouldRepaint(covariant ShibamSkylinePainter old) =>
      old.color != color || old.windowColor != windowColor;
}

/// A subtle tessellating diamond lattice evoking Yemeni/Islamic geometric
/// ornament (mashrabiya screens). Cheap to paint — pure stroked paths.
class HadhramiPatternPainter extends CustomPainter {
  final Color color;
  final double tile;
  final double opacity;
  const HadhramiPatternPainter({
    this.color = AppColors.warmWhite,
    this.tile = 46,
    this.opacity = 0.06,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final node = Paint()..color = color.withValues(alpha: opacity * 1.4);
    final half = tile / 2;

    for (double y = 0; y <= size.height + tile; y += tile) {
      for (double x = 0; x <= size.width + tile; x += tile) {
        final path = Path()
          ..moveTo(x, y - half)
          ..lineTo(x + half, y)
          ..lineTo(x, y + half)
          ..lineTo(x - half, y)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawCircle(Offset(x, y), 1.3, node);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HadhramiPatternPainter old) =>
      old.color != color || old.tile != tile || old.opacity != opacity;
}

/// A ready-made Hadhrami backdrop: gradient wash + lattice overlay, with an
/// optional Shibam skyline anchored at the bottom. Stack [child] on top.
class HadhramiBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final bool showSkyline;
  final double patternOpacity;
  const HadhramiBackground({
    super.key,
    required this.child,
    this.gradient,
    this.showSkyline = false,
    this.patternOpacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.hadhramiGradient,
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: HadhramiPatternPainter(opacity: patternOpacity),
            ),
          ),
        ),
        if (showSkyline)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: false,
                painter: ShibamSkylinePainter(
                  color: AppColors.clayDark.withValues(alpha: 0.5),
                  windowColor: AppColors.ochre,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
