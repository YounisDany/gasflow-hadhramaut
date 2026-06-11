import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart' show S;
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/primary_button.dart';
import '../shell/main_shell.dart';

class RequestGasScreen extends StatefulWidget {
  final bool embedded;
  const RequestGasScreen({super.key, this.embedded = false});

  @override
  State<RequestGasScreen> createState() => _RequestGasScreenState();
}

class _RequestGasScreenState extends State<RequestGasScreen> {
  int _quantity = 1;
  String _size = '12 kg';
  int _agentIndex = 0;

  double get _total {
    final unit = _size == '12 kg' ? 7000.0 : 12000.0;
    return unit * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final allAgents = appStore.agents;
        return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.requestGasTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(S.chooseSize,
                      style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SizeOption(
                          label: '12 kg',
                          price: 7000,
                          selected: _size == '12 kg',
                          onTap: () => setState(() => _size = '12 kg'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SizeOption(
                          label: '20 kg',
                          price: 12000,
                          selected: _size == '20 kg',
                          onTap: () => setState(() => _size = '20 kg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(S.quantity, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            size: 26, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.sizeCylinders(_size),
                                  style: AppTextStyles.titleMedium),
                              const SizedBox(height: 2),
                              Text(S.deliveredToAddress,
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        _QuantityStepper(
                          value: _quantity,
                          onChanged: (v) => setState(() => _quantity = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(S.chooseAgent, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  ...List.generate(allAgents.length, (i) {
                    final a = allAgents[i];
                    final selected = _agentIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _agentIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primarySoft
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Avatar(initials: a.avatar, size: 46),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(a.name,
                                        style: AppTextStyles.titleMedium),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            color: AppColors.warning,
                                            size: 14),
                                        const SizedBox(width: 3),
                                        Text(a.rating.toStringAsFixed(1),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  AppColors.textPrimary,
                                            )),
                                        Text('  •  ',
                                            style:
                                                AppTextStyles.bodySmall),
                                        Text(S.kmAway(a.distanceKm),
                                            style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.sendNotifications,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.primaryDark,
                                  )),
                              const SizedBox(height: 4),
                              Text(S.pickupNote,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _CheckoutBar(
              total: _total,
              onConfirm: () async {
                if (_agentIndex < allAgents.length) {
                  await appStore.addOrder(
                    cylinders: _quantity,
                    size: _size,
                    total: _total,
                    agent: allAgents[_agentIndex],
                  );
                }
                if (context.mounted) {
                  final shell = MainShell.of(context);
                  if (shell != null) {
                    shell.goToTab(2);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.orderStatus);
                  }
                }
              },
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}

class _SizeOption extends StatelessWidget {
  final String label;
  final double price;
  final bool selected;
  final VoidCallback onTap;

  const _SizeOption({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.titleMedium),
            const SizedBox(height: 2),
            Text(
              '${price.toStringAsFixed(0)} ${S.currency}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _round(Icons.remove_rounded,
              () => value > 1 ? onChanged(value - 1) : null),
          SizedBox(
            width: 30,
            child: Center(
              child: Text('$value',
                  style: AppTextStyles.titleMedium),
            ),
          ),
          _round(Icons.add_rounded, () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onConfirm;

  const _CheckoutBar({required this.total, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.total, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text('${total.toStringAsFixed(0)} ${S.currency}',
                  style: AppTextStyles.headlineMedium),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: S.confirmRequest,
              icon: Icons.flash_on_rounded,
              onPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
