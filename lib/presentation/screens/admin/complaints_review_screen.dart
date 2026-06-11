import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/models/complaint_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';

class ComplaintsReviewScreen extends StatefulWidget {
  const ComplaintsReviewScreen({super.key});

  @override
  State<ComplaintsReviewScreen> createState() =>
      _ComplaintsReviewScreenState();
}

class _ComplaintsReviewScreenState extends State<ComplaintsReviewScreen> {
  List<ComplaintModel> get _items => appStore.complaints;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.complaintsReview),
      ),
      body: SafeArea(
        child: _items.isEmpty
            ? EmptyState(
                icon: Icons.inbox_rounded,
                title: S.nothingYet,
                message: S.nothingYetDesc,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = _items[i];
                  return AppCard(
                    onTap: () => _showDetails(c),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warningSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.report_rounded,
                                  color: AppColors.warning, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title,
                                      style: AppTextStyles.titleMedium),
                                  const SizedBox(height: 2),
                                  Text('#${c.id}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textHint,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              ),
                            ),
                            StatusChip(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(c.description,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                },
              ),
      ),
    ),
    );
  }

  void _showDetails(ComplaintModel c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.complaintDetails,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          )),
                      const SizedBox(height: 4),
                      Text(c.title,
                          style: AppTextStyles.headlineMedium),
                    ],
                  ),
                ),
                StatusChip(status: c.status),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Avatar(initials: 'AO', size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.reportedBy,
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: 2),
                        Text(L10n.isAr ? 'أحمد العتيبي' : 'Ahmed Al-Otaibi',
                            style: AppTextStyles.titleMedium),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(S.reportedOn,
                          style: AppTextStyles.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(c.description, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 22),
            if (c.status != AppStatus.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    appStore.resolveComplaint(c);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(S.markResolved),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
