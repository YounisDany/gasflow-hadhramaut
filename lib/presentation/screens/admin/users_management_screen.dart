import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/models/citizen_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  AppStatus? _filter;

  Future<void> _exportData() async {
    final csv = appStore.exportCsv();
    if (appStore.agents.isEmpty &&
        appStore.citizens.isEmpty &&
        appStore.orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(S.exportEmpty),
        ),
      );
      return;
    }
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(
          utf8.encode(csv),
          mimeType: 'text/csv',
          name: 'gasflow_export.csv',
        ),
      ],
      text: 'GasFlow data export',
    ));
  }

  void _confirmDelete(CitizenModel c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.deleteUserTitle),
        content: Text(S.deleteUserDesc(c.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel),
          ),
          TextButton(
            onPressed: () {
              appStore.deleteCitizen(c);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  content: Text(S.deletedMsg(c.name)),
                ),
              );
            },
            child: Text(S.delete,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(S.all),
              trailing: _filter == null
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _filter = null);
                Navigator.pop(ctx);
              },
            ),
            for (final s in [
              AppStatus.pending,
              AppStatus.accepted,
              AppStatus.rejected,
            ])
              ListTile(
                title: Text(s.label),
                trailing: _filter == s
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _filter = s);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final citizens = _filter == null
            ? appStore.citizens
            : appStore.citizens.where((c) => c.status == _filter).toList();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(S.settingsAndUsers),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                SectionHeader(title: S.system),
                const SizedBox(height: 12),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.notifications_active_rounded,
                        title: S.notificationsLabel,
                        subtitle: S.notificationsDesc,
                        trailing: const _Toggle(value: true),
                      ),
                      const Divider(height: 1),
                      _SettingTile(
                        icon: Icons.shield_rounded,
                        title: S.twoFactor,
                        subtitle: S.twoFactorDesc,
                        trailing: const _Toggle(value: true),
                      ),
                      const Divider(height: 1),
                      _SettingTile(
                        icon: Icons.local_offer_rounded,
                        title: S.pricingRules,
                        subtitle: S.pricingRulesDesc,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.pricing),
                      ),
                      const Divider(height: 1),
                      _SettingTile(
                        icon: Icons.backup_rounded,
                        title: S.dataExport,
                        subtitle: S.dataExportDesc,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                        onTap: _exportData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: S.usersCount(citizens.length),
                  action: S.filter,
                  onAction: _showFilterSheet,
                ),
                const SizedBox(height: 12),
                ...citizens.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          Avatar(initials: c.avatar, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: AppTextStyles.titleMedium),
                                const SizedBox(height: 2),
                                Text(c.phone,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                          StatusChip(status: c.status),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded,
                                color: AppColors.textHint, size: 20),
                            onSelected: (v) {
                              if (v == 'delete') _confirmDelete(c);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline_rounded,
                                        color: AppColors.danger, size: 20),
                                    const SizedBox(width: 10),
                                    Text(S.delete,
                                        style: const TextStyle(
                                            color: AppColors.danger)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: S.account),
                const SizedBox(height: 12),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.person_rounded,
                        title: S.adminProfile,
                        subtitle: S.adminProfileDesc,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.adminProfile),
                      ),
                      const Divider(height: 1),
                      _SettingTile(
                        icon: Icons.logout_rounded,
                        title: S.signOut,
                        subtitle: S.signOutDesc,
                        iconColor: AppColors.danger,
                        titleColor: AppColors.danger,
                        onTap: () async {
                          await AuthService.signOut();
                          Session.signOut();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (_) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: iconColor ?? AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  const _Toggle({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
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
    );
  }
}
