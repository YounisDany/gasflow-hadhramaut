import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Wraps the whole app (via `MaterialApp.builder`) and shows a thin bar at the
/// bottom that reflects the live [SyncService] state: a reassuring "offline —
/// saved locally" notice while disconnected, and a brief "syncing" notice when
/// the connection returns and queued changes flush.
class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        ValueListenableBuilder<SyncState>(
          valueListenable: SyncService.state,
          builder: (context, state, _) {
            final visible =
                state == SyncState.offline || state == SyncState.syncing;
            final syncing = state == SyncState.syncing;
            return AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: !visible
                  ? const SizedBox(width: double.infinity)
                  : Material(
                      color:
                          syncing ? AppColors.primary : AppColors.primaryDark,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                syncing
                                    ? Icons.sync_rounded
                                    : Icons.cloud_off_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  syncing
                                      ? S.syncingNotice
                                      : S.offlineNotice,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
