import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return S.justNow;
    if (d.inMinutes < 60) return S.minutesAgo(d.inMinutes);
    if (d.inHours < 24) return S.hoursAgo(d.inHours);
    return S.daysAgo(d.inDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.notificationsTitle),
        actions: [
          ListenableBuilder(
            listenable: appStore,
            builder: (_, __) => appStore.unreadCount == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: TextButton.icon(
                      onPressed: appStore.markAllRead,
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: Text(S.markAllRead),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStore,
          builder: (_, __) {
            final items = appStore.notifications;
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_off_rounded,
                title: S.noNotifications,
                message: S.noNotificationsDesc,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationCard(
                item: items[i],
                timeAgo: _ago(items[i].createdAt),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final String timeAgo;
  const _NotificationCard({required this.item, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final unread = !item.read;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? item.color.withValues(alpha: 0.06) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unread
              ? item.color.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: AppTextStyles.titleMedium),
                    ),
                    Text(timeAgo, style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.body, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          if (unread)
            Container(
              margin: const EdgeInsetsDirectional.only(start: 6, top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color,
              ),
            ),
        ],
      ),
    );
  }
}
