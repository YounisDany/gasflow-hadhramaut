import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';

class SendNotificationScreen extends StatelessWidget {
  const SendNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        // Only citizens accepted by the agent receive notifications.
        final approved = appStore.approvedCitizens;
        return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.sendNotifications),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.notifyCustomer,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                            )),
                        const SizedBox(height: 2),
                        Text(S.pickupNote,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...approved.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(initials: c.avatar, size: 46),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: AppTextStyles.titleMedium),
                                const SizedBox(height: 2),
                                Text(c.address,
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          if (c.barcodeId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(c.barcodeId!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  )),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _NotifyButton(
                              icon: Icons.schedule_rounded,
                              label: S.notifyBefore,
                              softColor: AppColors.warningSoft,
                              color: AppColors.warning,
                              onTap: () =>
                                  _send(context, c.name, S.beforeRefillMsg),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NotifyButton(
                              icon: Icons.check_circle_rounded,
                              label: S.notifyAfter,
                              softColor: AppColors.successSoft,
                              color: AppColors.success,
                              onTap: () =>
                                  _send(context, c.name, S.afterRefillMsg),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  void _send(BuildContext context, String name, String message) {
    appStore.pushCustomerNotice(name, message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${S.notificationSent}: $message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  const _NotifyButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
