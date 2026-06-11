import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/prefs.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/messaging_service.dart';
import '../../../data/services/seed_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _rememberMe = Prefs.rememberMe;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _anim, curve: Curves.easeOut);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Demo mode (Firebase not configured yet): route by email without real auth
    // so every role is reachable on-device. `flutterfire configure` switches
    // this to real Firebase Auth automatically.
    if (!AuthService.ready) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Session.isGuest = false;
      final email = _email.text.trim().toLowerCase();
      final String role;
      if (email == AuthService.adminEmail) {
        role = 'admin';
      } else if (email.contains('agent')) {
        role = 'agent';
      } else {
        role = 'citizen';
        Session.profileComplete = true;
        Session.isJoined = true;
      }
      Session.role = role;
      if (Session.emailNotifier.value.isEmpty) {
        Session.saveProfile(email: email);
      }
      await _rememberSession(role);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, _routeForRole(role));
      return;
    }

    try {
      await AuthService.signIn(_email.text, _password.text);
      final role = await AuthService.roleForCurrentUser();
      // Admin context can seed the demo collections on first run.
      if (role == 'admin') {
        await SeedService.seedIfEmpty();
      }
      final prof = await AuthService.profileForCurrentUser();
      Session.isGuest = false;
      if (prof != null) {
        Session.saveProfile(
          name: prof['name'] as String?,
          email: prof['email'] as String?,
          phone: prof['phone'] as String?,
          region: prof['region'] as String?,
        );
        Session.profileComplete = prof['profileComplete'] == true;
        Session.isJoined = prof['isJoined'] == true;
      }
      Session.role = role;
      await MessagingService.registerToken();
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, _routeForRole(role));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_authError(e.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(L10n.isAr ? 'تعذّر تسجيل الدخول' : 'Sign-in failed');
    }
  }

  String _routeForRole(String role) => role == 'admin'
      ? AppRoutes.adminDashboard
      : role == 'agent'
          ? AppRoutes.agentHome
          : AppRoutes.citizenHome;

  /// Persist the demo session when "remember me" is on, otherwise forget any
  /// previously remembered session (the current in-memory session still works).
  Future<void> _rememberSession(String role) async {
    await Prefs.setRememberMe(_rememberMe);
    if (_rememberMe) {
      await Prefs.saveSession(
        role: role,
        name: Session.nameNotifier.value,
        email: Session.emailNotifier.value,
        phone: Session.phoneNotifier.value,
        region: Session.regionNotifier.value,
        profileComplete: Session.profileComplete,
        isJoined: Session.isJoined,
        lat: Session.latNotifier.value,
        lng: Session.lngNotifier.value,
      );
    } else {
      await Prefs.clearSession();
    }
  }

  /// Demo social sign-in: signs in as a citizen on-device. Real OAuth is wired
  /// automatically once Firebase is configured.
  Future<void> _demoSocialSignIn(String provider) async {
    if (_loading) return;
    if (AuthService.ready) {
      _showError(L10n.isAr ? 'سيتوفر قريباً' : 'Coming soon');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Session.isGuest = false;
    Session.role = 'citizen';
    Session.profileComplete = true;
    Session.isJoined = true;
    if (Session.nameNotifier.value.isEmpty) {
      Session.saveProfile(name: L10n.isAr ? 'مستخدم تجريبي' : 'Demo User');
    }
    if (Session.emailNotifier.value.isEmpty) {
      Session.saveProfile(email: '$provider@demo.gasflow');
    }
    await _rememberSession('citizen');
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.citizenHome);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _authError(String code) {
    final ar = L10n.isAr;
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return ar
            ? 'البريد أو كلمة المرور غير صحيحة'
            : 'Invalid email or password';
      case 'invalid-email':
        return ar ? 'بريد إلكتروني غير صالح' : 'Invalid email';
      case 'user-disabled':
        return ar ? 'الحساب موقوف' : 'Account disabled';
      case 'too-many-requests':
        return ar ? 'محاولات كثيرة، حاول لاحقاً' : 'Too many attempts, try later';
      case 'network-request-failed':
        return ar ? 'تحقّق من اتصال الإنترنت' : 'Check your connection';
      default:
        return ar ? 'تعذّر تسجيل الدخول' : 'Sign-in failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Premium gradient header ───
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Center(child: LangToggle()),
              ),
            ],
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
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Logo with glow
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.1),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.appName,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.tagline,
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

          // ─── Form body ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.welcomeBack, style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 6),
                    Text(S.signInSubtitle, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 28),

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _email,
                            label: S.email,
                            hint: S.emailHint,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? S.emailRequired : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _password,
                            label: S.password,
                            hint: S.passwordHint,
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) =>
                                (v == null || v.length < 6) ? S.passwordMin : null,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => setState(
                                      () => _rememberMe = !_rememberMe),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (v) => setState(
                                              () => _rememberMe = v ?? false),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          S.rememberMe,
                                          style: AppTextStyles.bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.forgotPassword),
                                child: Text(S.forgotPassword),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      label: S.signIn,
                      icon: Icons.arrow_forward_rounded,
                      loading: _loading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            S.orContinueWith,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: S.google,
                            color: const Color(0xFFDB4437),
                            onPressed: () => _demoSocialSignIn('google'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.apple_rounded,
                            label: S.apple,
                            color: AppColors.textPrimary,
                            onPressed: () => _demoSocialSignIn('apple'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.noAccount, style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.signup),
                          child: Text(
                            S.signUp,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Social login button with brand color accent
// ═══════════════════════════════════════════════════════════════════

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
