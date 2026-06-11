import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/services/prefs.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/avatar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
      text: Session.nameNotifier.value.isEmpty
          ? S.adminName
          : Session.nameNotifier.value);
  late final TextEditingController _email = TextEditingController(
      text: Session.emailNotifier.value.isEmpty
          ? 'admin@gmail.com'
          : Session.emailNotifier.value);
  late final TextEditingController _phone =
      TextEditingController(text: Session.phoneNotifier.value);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    Session.saveProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );
    if (Prefs.rememberMe) {
      await Prefs.saveSession(
        role: 'admin',
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        region: Session.regionNotifier.value,
        profileComplete: true,
        isJoined: false,
        lat: Session.latNotifier.value,
        lng: Session.lngNotifier.value,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(S.savedSuccessfully,
            style: const TextStyle(color: Colors.white)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.adminProfileTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Column(
                children: [
                  const Avatar(initials: 'AD', size: 88),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(S.superAdmin,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _name,
                    label: S.fullNameLabel,
                    hint: S.fullNameHint,
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? S.nameRequired : null,
                  ),
                  const SizedBox(height: 16),
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
                    controller: _phone,
                    label: S.phoneLabel,
                    hint: S.phoneHint,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: S.save,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
