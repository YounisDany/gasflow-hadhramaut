import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/agent_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/auth_gate.dart';
import '../../widgets/avatar.dart';
import '../../widgets/map_view.dart';
import '../../widgets/sync_indicator.dart';
import '../shell/main_shell.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  late final PageController _pageCtrl =
      PageController(viewportFraction: 0.86, initialPage: 0);

  int _selected = 0;

  // Nearest located agents first, capped at four for the map + slider.
  List<AgentModel> get _agents {
    final list = appStore.agents.where((a) => a.hasLocation).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list.take(4).toList();
  }

  LatLng? get _userLocation {
    final lat = Session.latNotifier.value;
    final lng = Session.lngNotifier.value;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _select(int i) {
    setState(() => _selected = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onRequestPressed() {
    if (Session.isGuest) {
      AuthGate.requireAuth(context, message: S.signInToRequest);
      return;
    }
    // Account created but data not submitted → finish registration first.
    if (!Session.profileComplete) {
      Navigator.pushNamed(context, AppRoutes.dataRegistration);
      return;
    }
    // Registered but not yet approved by an agent → still pending.
    if (!Session.isJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.profilePendingDesc),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    MainShell.of(context)?.goToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: appStore,
        builder: (context, _) {
          final agents = _agents;
          return Stack(
        children: [
          // ─── Full-screen map ───
          Positioned.fill(
            child: MapView(
              pins: [
                for (final a in agents)
                  MapPin(
                    point: LatLng(a.lat!, a.lng!),
                    label: a.name,
                    avatar: a.avatar,
                  ),
              ],
              selectedIndex: _selected,
              onSelect: _select,
              userLocation: _userLocation,
            ),
          ),

          // ─── Floating header ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: _Header(),
              ),
            ),
          ),

          // ─── Complete-profile banner ───
          if (!Session.isGuest && !Session.profileComplete)
            Positioned(
              left: 16,
              right: 16,
              top: 78,
              child: _CompleteProfileBanner(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.dataRegistration),
              ),
            ),

          // ─── Bottom slider with agent cards (sits above the floating nav) ───
          Positioned(
            left: 0,
            right: 0,
            bottom: 96,
            child: SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: agents.length,
                onPageChanged: (i) => setState(() => _selected = i),
                itemBuilder: (_, i) {
                  final a = agents[i];
                  final selected = i == _selected;
                  return ValueListenableBuilder<bool>(
                    valueListenable: Session.isJoinedNotifier,
                    builder: (context, isJoined, child) {
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: selected ? 1 : 0.94,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                          child: _AgentCard(
                            agent: a,
                            selected: selected,
                            isJoined: isJoined,
                            onRequest: _onRequestPressed,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }
}

class _CompleteProfileBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteProfileBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warningSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.assignment_late_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.completeProfileTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        )),
                    Text(S.completeProfileCta,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.warning),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12, bottom: 32, left: 24, right: 24),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(L10n.isAr ? 'تغيير الموقع' : 'Change Location', 
                 style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
              ),
              title: Text(L10n.isAr ? 'استخدام موقعي الحالي' : 'Use current location',
                          style: AppTextStyles.titleMedium),
              onTap: () => Navigator.pop(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on_rounded, color: AppColors.textSecondary),
              title: Text(L10n.isAr ? 'سيئون، حضرموت' : 'Seiyun, Hadhramaut',
                          style: AppTextStyles.titleMedium),
              trailing: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_city_rounded, color: AppColors.textHint),
              title: Text(L10n.isAr ? 'تريم، حضرموت' : 'Tarim, Hadhramaut',
                          style: AppTextStyles.bodyMedium),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _Pill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    L10n.isAr ? 'سيئون، حضرموت' : 'Seiyun, Hadhramaut',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
            onTap: () => _showLocationPicker(context),
          ),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsetsDirectional.only(end: 8),
          child: SyncIndicator(hideWhenSynced: true),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: Session.isGuestNotifier,
          builder: (_, isGuest, __) => isGuest
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsetsDirectional.only(end: 8),
                  child: _NotifBell(),
                ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: Session.isGuestNotifier,
          builder: (_, isGuest, __) => isGuest
              ? _SignInPill(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                )
              : const Avatar(initials: 'AO', size: 40),
        ),
      ],
    );
  }
}

class _NotifBell extends StatelessWidget {
  const _NotifBell();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final count = appStore.unreadCount;
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(Icons.notifications_rounded,
                    color: AppColors.textPrimary, size: 20),
              ),
              if (count > 0)
                PositionedDirectional(
                  end: -2,
                  top: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pill({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SignInPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                S.signIn,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final AgentModel agent;
  final bool selected;
  final bool isJoined;
  final VoidCallback onRequest;

  const _AgentCard({
    required this.agent,
    required this.selected,
    required this.isJoined,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.12 : 0.06),
            blurRadius: selected ? 20 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(initials: agent.avatar, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(agent.area,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      agent.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(S.kmAway(agent.distanceKm),
                  style: AppTextStyles.bodySmall),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(110, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    isJoined ? Icons.flash_on_rounded : Icons.person_add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    isJoined ? S.requestNow : S.requestToJoin,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

