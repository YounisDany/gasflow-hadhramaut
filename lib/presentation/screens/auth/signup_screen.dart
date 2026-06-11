import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/messaging_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _agree = true;

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
    _confirmPassword.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || !_agree) return;
    if (_password.text != _confirmPassword.text) return;
    setState(() => _loading = true);

    // Demo mode (Firebase not configured): skip account creation and go
    // straight to the details step.
    if (!AuthService.ready) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _loading = false);
      Session.isGuest = false;
      Session.profileComplete = false;
      Session.saveProfile(email: _email.text.trim());
      Navigator.pushReplacementNamed(context, AppRoutes.dataRegistration);
      return;
    }

    try {
      // Create the Firebase account now; role + details are captured next.
      await AuthService.signUp(
        email: _email.text,
        password: _password.text,
        role: 'citizen',
      );
      Session.isGuest = false;
      Session.profileComplete = false;
      Session.saveProfile(email: _email.text.trim());
      await MessagingService.registerToken();
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, AppRoutes.dataRegistration);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_authError(e.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(L10n.isAr ? 'تعذّر إنشاء الحساب' : 'Sign-up failed');
    }
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
      case 'email-already-in-use':
        return ar ? 'البريد الإلكتروني مستخدم مسبقاً' : 'Email already in use';
      case 'invalid-email':
        return ar ? 'بريد إلكتروني غير صالح' : 'Invalid email';
      case 'weak-password':
        return ar ? 'كلمة المرور ضعيفة' : 'Password is too weak';
      case 'network-request-failed':
        return ar ? 'تحقّق من اتصال الإنترنت' : 'Check your connection';
      default:
        return ar ? 'تعذّر إنشاء الحساب' : 'Sign-up failed';
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
            expandedHeight: 210,
            pinned: true,
            stretch: true,
            leading: IconButton(
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
                    colors: [
                      Color(0xFF1E88E5),
                      Color(0xFF0D47A1),
                      Color(0xFF0A3A7E)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Glowing icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            S.createAccount,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.isAr
                                ? 'أنشئ حسابك للبدء في استخدام التطبيق'
                                : 'Create your account to get started',
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

          // ─── Form body ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step indicator
                    _StepIndicator(currentStep: 1, totalSteps: 2),
                    const SizedBox(height: 24),

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
                            validator: (v) => (v == null || !v.contains('@'))
                                ? S.emailInvalid
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _password,
                            label: S.password,
                            hint: S.passwordHintLong,
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) => (v == null || v.length < 6)
                                ? S.passwordMin
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPassword,
                            label: S.confirmPassword,
                            hint: S.confirmPasswordHint,
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return S.passwordMin;
                              if (v != _password.text) {
                                return L10n.isAr
                                    ? 'كلمة المرور غير متطابقة'
                                    : 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms row
                    _TermsRow(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      label: S.createAccount,
                      icon: Icons.arrow_forward_rounded,
                      loading: _loading,
                      onPressed: _agree ? _signup : null,
                    ),
                    const SizedBox(height: 24),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.haveAccount, style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            S.signIn,
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
//  Step indicator — shows "Step 1 of 2"
// ═══════════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$currentStep',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.isAr
                      ? 'الخطوة $currentStep من $totalSteps'
                      : 'Step $currentStep of $totalSteps',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  L10n.isAr
                      ? 'بيانات الحساب الأساسية'
                      : 'Basic account credentials',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          // Progress dots
          Row(
            children: List.generate(totalSteps, (i) {
              final active = i < currentStep;
              return Container(
                width: active ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Terms Row
// ═══════════════════════════════════════════════════════════════════

class _TermsRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TermsRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(text: S.agreeTo),
                  TextSpan(
                    text: S.terms,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: S.and),
                  TextSpan(
                    text: S.privacy,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
