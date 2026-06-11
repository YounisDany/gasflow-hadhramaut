import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/models/citizen_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';

class CitizenRequestsScreen extends StatefulWidget {
  final bool embedded;
  const CitizenRequestsScreen({super.key, this.embedded = false});

  @override
  State<CitizenRequestsScreen> createState() => _CitizenRequestsScreenState();
}

class _CitizenRequestsScreenState extends State<CitizenRequestsScreen> {
  AppStatus? _filter = AppStatus.pending;

  Future<void> _setStatus(CitizenModel c, AppStatus s) async {
    final updated = await appStore.setCitizenStatus(c, s);
    if (s == AppStatus.accepted && mounted) {
      _showApprovedSheet(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.citizenRequestsTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Chip(
                    label: S.all,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  ...AppStatus.values.where((s) => s != AppStatus.completed).map(
                        (s) => _Chip(
                          label: s.label,
                          selected: _filter == s,
                          onTap: () => setState(() => _filter = s),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: appStore,
                builder: (context, _) {
                  final filtered = appStore.citizens
                      .where((c) => _filter == null || c.status == _filter)
                      .toList();
                  return filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.inbox_rounded,
                          title: S.noRequests,
                          message: S.noRequestsDesc,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Avatar(initials: c.avatar, size: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(c.name,
                                            style:
                                                AppTextStyles.titleMedium),
                                        const SizedBox(height: 2),
                                        Text(c.phone,
                                            style: AppTextStyles
                                                .bodySmall),
                                      ],
                                    ),
                                  ),
                                  StatusChip(status: c.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(c.address,
                                        style: AppTextStyles.bodyMedium),
                                  ),
                                ],
                              ),
                              if (c.barcodeId != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code_2_rounded,
                                          size: 16,
                                          color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        c.barcodeId!,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (c.status == AppStatus.pending) ...[
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _setStatus(
                                            c, AppStatus.rejected),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.danger,
                                          side: const BorderSide(
                                              color: AppColors.danger),
                                          minimumSize:
                                              const Size.fromHeight(44),
                                        ),
                                        icon: const Icon(
                                            Icons.close_rounded,
                                            size: 18),
                                        label: Text(S.reject),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _setStatus(
                                            c, AppStatus.accepted),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(44),
                                        ),
                                        icon: const Icon(
                                            Icons.check_rounded,
                                            size: 18),
                                        label: Text(S.accept),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovedSheet(CitizenModel c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successSoft,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text(S.approvedSheetTitle(c.name),
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text(S.barcodeGeneratedDesc,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2_rounded,
                      size: 22, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    c.barcodeId ?? '',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryDark,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
