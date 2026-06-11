import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _base = TextEditingController(
      text: appStore.basePrice.toStringAsFixed(0));
  late final TextEditingController _fee = TextEditingController(
      text: appStore.serviceFee.toStringAsFixed(0));

  @override
  void dispose() {
    _base.dispose();
    _fee.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return S.priceRequired;
    final n = double.tryParse(v.trim());
    if (n == null || n < 0) return S.priceRequired;
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await appStore.setPricing(
      base: double.parse(_base.text.trim()),
      fee: double.parse(_fee.text.trim()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content:
            Text(S.pricingSaved, style: const TextStyle(color: Colors.white)),
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
        title: Text(S.pricingTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(S.pricingNote,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _base,
                    label: S.basePriceLabel,
                    hint: S.basePriceHint,
                    icon: Icons.sell_outlined,
                    keyboardType: TextInputType.number,
                    validator: _validate,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _fee,
                    label: S.serviceFeeLabel,
                    hint: S.serviceFeeHint,
                    icon: Icons.local_shipping_outlined,
                    keyboardType: TextInputType.number,
                    validator: _validate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: S.savePricing,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
