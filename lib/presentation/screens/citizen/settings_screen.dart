import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/prefs.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/messaging_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class SettingsScreen extends StatefulWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;

  // Editable profile data — seeded from the session (captured at registration).
  late String _userName = Session.nameNotifier.value.isNotEmpty
      ? Session.nameNotifier.value
      : (L10n.isAr ? 'مستخدم' : 'User');
  late String _userEmail = Session.emailNotifier.value;
  late String _userPhone = Session.phoneNotifier.value;
  late String _userRegion = Session.regionNotifier.value.isNotEmpty
      ? Session.regionNotifier.value
      : (L10n.isAr ? 'سيئون، حضرموت' : 'Seiyun, Hadhramaut');

  void _openEditProfile() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final regionCtrl = TextEditingController(text: _userRegion);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(S.editProfile, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: nameCtrl,
                  label: S.fullNameLabel,
                  hint: S.fullNameHint,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: emailCtrl,
                  label: S.email,
                  hint: S.emailHint,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: phoneCtrl,
                  label: S.phoneLabel,
                  hint: S.phoneHint,
                  icon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: regionCtrl,
                  label: S.regionLabel,
                  hint: S.regionHint,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: S.save,
                  icon: Icons.check_rounded,
                  onPressed: () {
                    setState(() {
                      _userName = nameCtrl.text;
                      _userEmail = emailCtrl.text;
                      _userPhone = phoneCtrl.text;
                      _userRegion = regionCtrl.text;
                    });
                    Session.saveProfile(
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      phone: phoneCtrl.text,
                      region: regionCtrl.text,
                    );
                    if (Prefs.signedIn) {
                      Prefs.saveSession(
                        role: Session.role,
                        name: nameCtrl.text,
                        email: emailCtrl.text,
                        phone: phoneCtrl.text,
                        region: regionCtrl.text,
                        profileComplete: Session.profileComplete,
                        isJoined: Session.isJoined,
                        lat: Session.latNotifier.value,
                        lng: Session.lngNotifier.value,
                      );
                    }
                    AuthService.saveProfile({
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'phone': phoneCtrl.text,
                      'region': regionCtrl.text,
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.savedSuccessfully),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutApp() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // App icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.appName,
              style: AppTextStyles.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                S.aboutAppDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.madeWithLove,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.allRightsReserved,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(S.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Premium collapsible app bar ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            leading: widget.embedded
                ? null
                : IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF0D47A1), Color(0xFF0A3A7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: Session.isGuestNotifier,
                    builder: (_, isGuest, __) => Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar with glow ring
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Avatar(
                              initials: isGuest ? '?' : 'AO',
                              size: 68,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isGuest
                                ? (L10n.isAr ? 'ضيف' : 'Guest')
                                : _userName,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuest
                                ? (L10n.isAr ? 'سجّل دخولك للوصول الكامل' : 'Sign in for full access')
                                : _userEmail,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Settings content ───
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(20, 24, 20, widget.embedded ? 116 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Profile Actions ───
                  ValueListenableBuilder<bool>(
                    valueListenable: Session.isGuestNotifier,
                    builder: (_, isGuest, __) => isGuest
                        ? const SizedBox.shrink()
                        : _Section(
                            title: S.profile,
                            children: [
                              if (!Session.profileComplete) ...[
                                _SettingsTile(
                                  icon: Icons.assignment_late_rounded,
                                  iconColor: AppColors.warning,
                                  title: S.completeProfileTitle,
                                  subtitle: S.completeProfileDesc,
                                  trailing: Icon(Icons.chevron_right_rounded,
                                      color: AppColors.textHint),
                                  onTap: () => Navigator.pushNamed(
                                      context, AppRoutes.dataRegistration),
                                ),
                                const _TileDivider(),
                              ],
                              _SettingsTile(
                                icon: Icons.person_outline_rounded,
                                iconColor: AppColors.primary,
                                title: S.editProfile,
                                subtitle: _userPhone,
                                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                                onTap: _openEditProfile,
                              ),
                            ],
                          ),
                  ),

                  // ─── General ───
                  _Section(
                    title: S.general,
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF6366F1),
                        title: L10n.isAr ? 'اللغة' : 'Language',
                        subtitle: L10n.isAr ? 'العربية' : 'English',
                        trailing: const LangToggle(),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: S.notifications,
                        subtitle: S.notificationsDesc2,
                        trailing: Switch(
                          value: _notificationsOn,
                          onChanged: (v) => setState(() => _notificationsOn = v),
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: S.darkMode,
                        trailing: Switch(
                          value: ThemeController.isDark,
                          onChanged: (v) => ThemeController.setDark(v),
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // ─── Support ───
                  _Section(
                    title: S.support,
                    children: [
                      _SettingsTile(
                        icon: Icons.star_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: S.rateApp,
                        subtitle: S.rateAppDesc,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(L10n.isAr ? 'شكراً لتقييمك!' : 'Thank you for your rating!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.share_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: S.shareApp,
                        subtitle: S.shareAppDesc,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(L10n.isAr ? 'تم نسخ رابط التطبيق' : 'App link copied'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: S.contactUs,
                        subtitle: S.contactUsDesc,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('support@gasflow.com'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // ─── About ───
                  _Section(
                    title: S.aboutApp,
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFF06B6D4),
                        title: S.aboutApp,
                        subtitle: S.tagline,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: _showAboutApp,
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: S.terms,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () {},
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: S.privacy,
                        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        onTap: () {},
                      ),
                      const _TileDivider(),
                      _SettingsTile(
                        icon: Icons.verified_rounded,
                        iconColor: AppColors.textHint,
                        title: S.version,
                        trailing: Text(
                          '1.0.0',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ─── Logout ───
                  ValueListenableBuilder<bool>(
                    valueListenable: Session.isGuestNotifier,
                    builder: (_, isGuest, __) => isGuest
                        ? const SizedBox.shrink()
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  await MessagingService.clearToken();
                                  await AuthService.signOut();
                                  await Prefs.clearSession();
                                  Session.signOut();
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, AppRoutes.login, (_) => false);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        S.logout,
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          S.madeWithLove,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.allRightsReserved,
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Private Widgets
// ═══════════════════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.textHint,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Gradient icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
    );
  }
}
