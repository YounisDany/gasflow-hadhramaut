import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppNavItem {
  final IconData icon;
  final String label;
  const AppNavItem(this.icon, this.label);
}

/// Premium floating bottom navigation: a blurred, rounded bar with a sliding
/// pill indicator under the active tab, a springy icon bounce, and a label
/// that reveals only for the selected item. Reused across both role shells.
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  /// Approximate height (bar + outer margins) so shells can pad content that
  /// should sit above the floating bar.
  static const double height = 88;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(26),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                boxShadow: AppColors.cardShadow,
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final n = items.length;
                  final cellW = c.maxWidth / n;
                  final t = n == 1 ? 0.0 : currentIndex / (n - 1);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(-1 + 2 * t, 0),
                        child: Container(
                          width: cellW - 10,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (int i = 0; i < n; i++)
                            Expanded(
                              child: _NavCell(
                                item: items[i],
                                selected: i == currentIndex,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textHint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: selected ? 1.12 : 1.0,
              child: Icon(item.icon, color: color, size: 22),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
