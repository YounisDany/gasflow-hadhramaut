import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_status.dart';

class StatusChip extends StatelessWidget {
  final AppStatus status;
  final bool dense;

  const StatusChip({super.key, required this.status, this.dense = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: dense ? 12 : 14, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
