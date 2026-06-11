import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/models/order_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';

class OrderStatusScreen extends StatelessWidget {
  final bool embedded;
  const OrderStatusScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.orderStatusTitle),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStore,
          builder: (context, _) {
            final order = appStore.currentOrder;
            if (order == null) {
              return EmptyState(
                icon: Icons.receipt_long_rounded,
                title: S.noOrdersHere,
                message: S.noOrdersHereDesc,
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _OrderHeaderCard(order: order),
                const SizedBox(height: 16),
                _Timeline(status: order.status),
                const SizedBox(height: 20),
                const _AgentCard(),
                const SizedBox(height: 16),
                _OrderDetails(order: order),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(S.pickupNote,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: order.status == AppStatus.pending
                            ? () => appStore.setOrderStatus(
                                order, AppStatus.rejected)
                            : null,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(S.cancelOrder),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text(S.contactAgent),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderHeaderCard({required this.order});

  String get _headline {
    switch (order.status) {
      case AppStatus.pending:
        return S.profilePendingTitle;
      case AppStatus.accepted:
        return S.gasOnTheWay;
      case AppStatus.completed:
        return S.afterRefillMsg;
      case AppStatus.rejected:
        return S.statusRejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.orderHash(order.id),
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(order.status.icon, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(order.status.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(_headline,
              style:
                  AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(S.etaMinutes,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final AppStatus status;
  const _Timeline({required this.status});

  @override
  Widget build(BuildContext context) {
    // Drive each step's state off the live order status.
    final accepted =
        status == AppStatus.accepted || status == AppStatus.completed;
    final done = status == AppStatus.completed;

    final steps = [
      _TLStep(title: S.stepRequestSubmitted, time: S.todayAt('10:24'), completed: true),
      _TLStep(
        title: S.stepAcceptedByAgent,
        time: accepted ? S.todayAt('10:28') : S.statusPending,
        completed: accepted,
        active: status == AppStatus.pending,
      ),
      _TLStep(
        title: S.stepOutForDelivery,
        time: done ? S.todayAt('10:42') : S.etaAt('10:42'),
        completed: done,
        active: accepted && !done,
      ),
      _TLStep(
        title: S.stepDelivered,
        time: done ? S.todayAt('11:05') : S.etaAt('11:05'),
        completed: done,
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.tracking, style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            final last = i == steps.length - 1;
            return _TimelineItem(step: s, isLast: last);
          }),
        ],
      ),
    );
  }
}

class _TLStep {
  final String title;
  final String time;
  final bool completed;
  final bool active;

  _TLStep({
    required this.title,
    required this.time,
    required this.completed,
    this.active = false,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TLStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = step.completed
        ? AppColors.success
        : step.active
            ? AppColors.primary
            : AppColors.divider;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: step.active
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 4)
                      : null,
                ),
                child: step.completed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.completed
                        ? AppColors.success
                        : AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: step.completed || step.active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      )),
                  const SizedBox(height: 2),
                  Text(step.time, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard();
  @override
  Widget build(BuildContext context) {
    final agent = appStore.nearestAgent;
    return AppCard(
      child: Row(
        children: [
          Avatar(initials: agent?.avatar ?? 'KH', size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent?.name ?? (L10n.isAr ? 'خالد الحربي' : 'Khalid Al-Harbi'),
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 4),
                    Text(S.ratingValue(agent?.rating ?? 4.9),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                    Text('  •  ', style: AppTextStyles.bodySmall),
                    Text(agent?.area ?? (L10n.isAr ? 'حي القرن' : 'Al Qarn district'),
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          _circleBtn(Icons.chat_bubble_outline_rounded, AppColors.primary),
          const SizedBox(width: 8),
          _circleBtn(Icons.phone_rounded, AppColors.success),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final OrderModel order;
  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.orderDetails, style: AppTextStyles.titleLarge),
          const SizedBox(height: 14),
          _row(S.cylinder, order.size),
          _row(S.quantity, '${order.cylinders}'),
          _row(S.addressLabel, order.address),
          const Divider(height: 24),
          _row(S.subtotal, '${order.total.toStringAsFixed(0)} ${S.currency}'),
          _row(S.deliveryFee, S.free),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(S.total, style: AppTextStyles.titleMedium),
              const Spacer(),
              Text('${order.total.toStringAsFixed(0)} ${S.currency}',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
