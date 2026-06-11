import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final stats = {
          'users': appStore.citizens.length,
          'agents': appStore.agents
              .where((a) => a.status == AppStatus.accepted)
              .length,
          'orders': appStore.orders.length,
          'pending': appStore.agents
              .where((a) => a.status == AppStatus.pending)
              .length,
        };
        return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _Header(),
            const SizedBox(height: 24),
            const _BalanceBanner(),
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
                  icon: Icons.people_alt_rounded,
                  label: S.totalUsers,
                  value: '${stats['users']}',
                  color: AppColors.primary,
                  softColor: AppColors.primarySoft,
                  trend: '+12%',
                ),
                StatCard(
                  icon: Icons.delivery_dining_rounded,
                  label: S.activeAgents,
                  value: '${stats['agents']}',
                  color: AppColors.success,
                  softColor: AppColors.successSoft,
                  trend: '+4%',
                ),
                StatCard(
                  icon: Icons.local_shipping_rounded,
                  label: S.totalOrders,
                  value: '${stats['orders']}',
                  color: AppColors.warning,
                  softColor: AppColors.warningSoft,
                  trend: '+8%',
                ),
                StatCard(
                  icon: Icons.pending_actions_rounded,
                  label: S.pendingRequests,
                  value: '${stats['pending']}',
                  color: AppColors.danger,
                  softColor: AppColors.dangerSoft,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: S.quickActions,
              action: S.viewAll,
              onAction: () {},
            ),
            const SizedBox(height: 12),
            const _QuickActionsRow(),
            const SizedBox(height: 24),
            SectionHeader(
              title: S.pendingAgentRequests,
              action: S.manage,
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.manageAgents),
            ),
            const SizedBox(height: 12),
            ...appStore.agents.take(3).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Avatar(initials: a.avatar, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name,
                                    style: AppTextStyles.titleMedium),
                                const SizedBox(height: 2),
                                Text(a.area,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          StatusChip(status: a.status),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: const _AdminBottomNav(currentIndex: 0),
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
        const Avatar(initials: 'AD', size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.welcomeAdmin,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text(S.opsDashboard, style: AppTextStyles.headlineMedium),
            ],
          ),
        ),
        const LangToggle(),
        const SizedBox(width: 8),
        _IconButton(
          icon: Icons.notifications_rounded,
          badge: appStore.unreadCount > 0 ? '${appStore.unreadCount}' : null,
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
      ],
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.todaysOverview,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(L10n.isAr ? '٢٩ أبريل' : 'Apr 29',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(L10n.isAr ? '١٨٤' : '184',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 38,
                  )),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(S.cylindersDelivered,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(S.aboveYesterday,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.person_add_alt_rounded, S.manageAgents,
          () => Navigator.pushNamed(context, AppRoutes.manageAgents)),
      _QA(Icons.group_rounded, S.usersShort,
          () => Navigator.pushNamed(context, AppRoutes.usersManagement)),
      _QA(Icons.report_rounded, S.viewComplaints,
          () => Navigator.pushNamed(context, AppRoutes.complaintsReview)),
      _QA(Icons.settings_rounded, S.settings,
          () => Navigator.pushNamed(context, AppRoutes.usersManagement)),
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
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(a.icon,
                                color: AppColors.primary, size: 22),
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

class _QA {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _QA(this.icon, this.label, this.onTap);
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _IconButton({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          if (badge != null)
            PositionedDirectional(
              end: -2,
              top: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const _AdminBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) async {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.manageAgents);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.usersManagement);
          if (i == 3) {
            await AuthService.signOut();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (_) => false);
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded), label: S.dashboard),
          BottomNavigationBarItem(
              icon: const Icon(Icons.delivery_dining_rounded),
              label: S.agentsTab),
          BottomNavigationBarItem(
              icon: const Icon(Icons.group_rounded), label: S.usersShort),
          BottomNavigationBarItem(
              icon: const Icon(Icons.logout_rounded), label: S.logout),
        ],
      ),
    );
  }
}
