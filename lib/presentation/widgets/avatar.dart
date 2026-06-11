import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? color;

  const Avatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: 0.18),
            base.withValues(alpha: 0.32),
          ],
        ),
        border: Border.all(color: base.withValues(alpha: 0.25), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.titleMedium.copyWith(
          color: base,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
