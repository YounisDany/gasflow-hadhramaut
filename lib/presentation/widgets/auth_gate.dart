import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

/// Guard for protected actions. Call [AuthGate.requireAuth] before any flow
/// that needs a logged-in user — shows a polished bottom sheet asking the
/// guest to sign in, with an inline button that pushes the login screen.
class AuthGate {
  AuthGate._();

  static void requireAuth(BuildContext context, {String? message}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SignInRequiredSheet(message: message),
    );
  }
}

class _SignInRequiredSheet extends StatelessWidget {
  final String? message;
  const _SignInRequiredSheet({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(S.signInRequired, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            message ?? S.signInToContinue,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: S.signIn,
            icon: Icons.login_rounded,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.notNow),
          ),
        ],
      ),
    );
  }
}
