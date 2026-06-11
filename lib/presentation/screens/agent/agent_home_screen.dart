import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/map_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/sync_indicator.dart';
import '../shell/main_shell.dart';

String _timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return S.justNow;
  if (d.inMinutes < 60) return S.minutesAgo(d.inMinutes);
  if (d.inHours < 24) return S.hoursAgo(d.inHours);
  return S.daysAgo(d.inDays);
}

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final stats = {
          'citizens': appStore.approvedCitizens.length,
          'pending': appStore.pendingOrders.length,
          'today': appStore.orders.length,
          'completed': appStore.ordersByStatus(AppStatus.completed).length,
        };
        final pending = appStore.pendingOrders;
        return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const _Header(),
            const SizedBox(height: 14),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SyncIndicator(),
            ),
            const SizedBox(height: 14),
            const _StatusBanner(),
            const SizedBox(height: 24),
            const _AreaMapCard(),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                StatCard(
                  icon: Icons.group_rounded,
                  label: S.myCitizens,
                  value: '${stats['citizens']}',
                  color: AppColors.primary,
                  softColor: AppColors.primarySoft,
                ),
                StatCard(
                  icon: Icons.pending_actions_rounded,
                  label: S.pending,
                  value: '${stats['pending']}',
                  color: AppColors.warning,
                  softColor: AppColors.warningSoft,
                ),
                StatCard(
                  icon: Icons.local_shipping_rounded,
                  label: S.todaysOrders,
                  value: '${stats['today']}',
                  color: AppColors.success,
                  softColor: AppColors.successSoft,
                  trend: '+5',
                ),
                StatCard(
                  icon: Icons.verified_rounded,
                  label: S.completedLabel,
                  value: '${stats['completed']}',
                  color: AppColors.info,
                  softColor: AppColors.infoSoft,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: S.quickLinks, action: S.viewAll),
            const SizedBox(height: 12),
            const _QuickLinks(),
            const SizedBox(height: 24),
            SectionHeader(
              title: S.latestNotifications,
              action: S.viewAll,
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            const SizedBox(height: 12),
            if (appStore.notifications.isEmpty)
              Text(S.allCaughtUp, style: AppTextStyles.bodySmall)
            else
              ...appStore.notifications.take(4).map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Notification(
                        icon: n.icon,
                        color: n.color,
                        title: n.title,
                        message: n.body,
                        time: _timeAgo(n.createdAt),
                      ),
                    ),
                  ),
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionHeader(
                title: S.awaitingAction,
                action: S.viewAll,
                onAction: () => MainShell.of(context)?.goToTab(2),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  children: [
                    Avatar(initials: pending.first.citizenAvatar, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pending.first.citizenName,
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            S.cylinderCount(
                                pending.first.cylinders, pending.first.size),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: pending.first.status),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Avatar(initials: 'KH', size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.hello(L10n.isAr ? 'خالد' : 'Khalid'),
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(L10n.isAr ? 'حي القرن' : 'Al Qarn district',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const LangToggle(),
        const SizedBox(width: 8),
        _IconBadge(
          icon: Icons.notifications_active_rounded,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.sendNotification),
        ),
        const SizedBox(width: 8),
        _IconBadge(
          icon: Icons.qr_code_scanner_rounded,
          onTap: () => MainShell.of(context)?.goToTab(3),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.power_settings_new_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.youreOnline, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(S.acceptingOrders, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaMapCard extends StatelessWidget {
  const _AreaMapCard();

  @override
  Widget build(BuildContext context) {
    final citizens =
        appStore.approvedCitizens.where((c) => c.hasLocation).toList();
    final lat = Session.latNotifier.value;
    final lng = Session.lngNotifier.value;
    final userLoc = (lat != null && lng != null)
        ? LatLng(lat, lng)
        : const LatLng(15.9437, 48.7888); // Seiyun (demo agent base)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              L10n.isAr ? 'منطقتي وعملائي' : 'My area & citizens',
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: MapView(
              pins: [
                for (final c in citizens)
                  MapPin(
                    point: LatLng(c.lat!, c.lng!),
                    label: c.name,
                    avatar: c.avatar,
                    color: AppColors.success,
                  ),
              ],
              userLocation: userLoc,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Q(Icons.person_add_alt_rounded, S.citizenRequestsShort,
          AppColors.primary, () => MainShell.of(context)?.goToTab(1)),
      _Q(Icons.local_fire_department_rounded, S.gasOrdersShort,
          AppColors.success, () => MainShell.of(context)?.goToTab(2)),
      _Q(Icons.notifications_active_rounded, S.sendNotifications,
          AppColors.warning,
          () => Navigator.pushNamed(context, AppRoutes.sendNotification)),
      _Q(Icons.qr_code_scanner_rounded, S.scanBarcodeShort, AppColors.danger,
          () => MainShell.of(context)?.goToTab(3)),
    ];
    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                      end: a == actions.last ? 0 : 10),
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: a.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                Icon(a.icon, color: a.color, size: 22),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            a.label,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _Q {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _Q(this.icon, this.label, this.color, this.onTap);
}

class _Notification extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;

  const _Notification({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(title,
                            style: AppTextStyles.titleMedium)),
                    Text(time, style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBadge({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

