import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Compact pill button that toggles between Arabic and English.
class LangToggle extends StatelessWidget {
  final bool dark;

  const LangToggle({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: L10n.toggle,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 16,
                color: dark ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                S.langSwitch,
                style: AppTextStyles.bodySmall.copyWith(
                  color: dark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
