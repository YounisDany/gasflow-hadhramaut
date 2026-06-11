import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/order_model.dart';
import 'app_card.dart';
import 'avatar.dart';
import 'status_chip.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final List<Widget> actions;
  final VoidCallback? onTap;

  const OrderTile({
    super.key,
    required this.order,
    this.actions = const [],
    this.onTap,
  });

  String _timeAgo() {
    final diff = DateTime.now().difference(order.requestedAt);
    if (diff.inMinutes < 60) return S.minutesAgo(diff.inMinutes.abs());
    if (diff.inHours < 24) return S.hoursAgo(diff.inHours.abs());
    return S.daysAgo(diff.inDays.abs());
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(initials: order.citizenAvatar, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.citizenName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('#${order.id}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w600,
                            )),
                        Text('  •  ',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textHint)),
                        Text(_timeAgo(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 14),
          _MetaRow(
            icon: Icons.location_on_rounded,
            label: order.address,
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.local_fire_department_rounded,
            label: S.cylinderCount(order.cylinders, order.size),
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.payments_rounded,
            label: S.totalCurrency(order.total),
            highlight: true,
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(children: actions),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaRow({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: highlight ? AppColors.primary : AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: highlight
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
