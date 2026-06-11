import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/sync_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A compact status chip that reflects the live [SyncService] state. Drop it in
/// home headers so the user always sees whether their data is saved, queued, or
/// actively syncing. When [compact] is true only the icon dot is shown.
class SyncIndicator extends StatelessWidget {
  final bool compact;

  /// When true the chip disappears once everything is synced — handy over busy
  /// surfaces (e.g. the map header) where a permanent badge would add clutter.
  final bool hideWhenSynced;

  const SyncIndicator({
    super.key,
    this.compact = false,
    this.hideWhenSynced = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncState>(
      valueListenable: SyncService.state,
      builder: (context, state, _) {
        if (hideWhenSynced && state == SyncState.synced) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<int>(
          valueListenable: SyncService.pending,
          builder: (context, pending, __) {
            final (color, icon, label) = _styleFor(state, pending);
            final spinning = state == SyncState.syncing;
            final dot = _Dot(color: color, icon: icon, spinning: spinning);
            if (compact) return dot;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dot,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  (Color, IconData, String) _styleFor(SyncState state, int pending) {
    switch (state) {
      case SyncState.offline:
        return (AppColors.warning, Icons.cloud_off_rounded, S.syncOffline);
      case SyncState.syncing:
        return (AppColors.primary, Icons.sync_rounded, S.syncSyncing);
      case SyncState.pending:
        return (
          AppColors.info,
          Icons.cloud_upload_rounded,
          S.syncPending(pending),
        );
      case SyncState.synced:
        return (AppColors.success, Icons.cloud_done_rounded, S.syncSynced);
    }
  }
}

class _Dot extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool spinning;
  const _Dot({required this.color, required this.icon, required this.spinning});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _c.repeat();
  }

  @override
  void didUpdateWidget(_Dot old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.spinning && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(widget.icon, color: widget.color, size: 14);
    if (!widget.spinning) return icon;
    return RotationTransition(turns: _c, child: icon);
  }
}
