import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (_emailCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      await AuthService.sendPasswordReset(_emailCtrl.text);
      // Demo mode returns instantly; pause so the loading state is believable.
      if (!AuthService.ready) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.isAr
                ? 'تم إرسال رابط استعادة كلمة المرور بنجاح!'
                : 'Password reset link sent successfully!',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.isAr ? 'تعذّر إرسال الرابط' : 'Could not send the link',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          L10n.isAr ? 'استعادة كلمة المرور' : 'Reset Password',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                L10n.isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?', 
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                L10n.isAr 
                    ? 'أدخل بريدك الإلكتروني المسجل لدينا وسنرسل لك رابطاً لإعادة تعيين كلمة المرور بكل سهولة.' 
                    : 'Enter your registered email and we will send you a password reset link.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailCtrl,
                label: S.email,
                hint: S.emailHint,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: L10n.isAr ? 'إرسال الرابط' : 'Send Link',
                loading: _loading,
                onPressed: _sendLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
