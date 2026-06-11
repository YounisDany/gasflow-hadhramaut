import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/agent_model.dart';
import '../../../data/models/app_status.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';

class ManageAgentsScreen extends StatefulWidget {
  const ManageAgentsScreen({super.key});

  @override
  State<ManageAgentsScreen> createState() => _ManageAgentsScreenState();
}

class _ManageAgentsScreenState extends State<ManageAgentsScreen> {
  AppStatus? _filter;
  final _search = TextEditingController();

  void _setStatus(AgentModel a, AppStatus status) {
    appStore.setAgentStatus(a, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          status == AppStatus.accepted
              ? S.approvedMsg(a.name)
              : S.rejectedMsg(a.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.manageAgentsTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: S.searchAgentsHint,
                  prefixIcon:
                      const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: S.all,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  ...AppStatus.values.map((s) => _FilterChip(
                        label: s.label,
                        selected: _filter == s,
                        onTap: () => setState(() => _filter = s),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: appStore,
                builder: (context, _) {
                  final filtered = appStore.agents.where((a) {
                    final q = _search.text.toLowerCase();
                    final matchesSearch = q.isEmpty ||
                        a.name.toLowerCase().contains(q) ||
                        a.area.toLowerCase().contains(q);
                    final matchesStatus =
                        _filter == null || a.status == _filter;
                    return matchesSearch && matchesStatus;
                  }).toList();
                  return filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: S.noAgentsFound,
                          message: S.noAgentsFoundDesc,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final a = filtered[i];
                        return AppCard(
                          onTap: () => _showAgentDetails(a),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Avatar(initials: a.avatar, size: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.name,
                                            style:
                                                AppTextStyles.titleMedium),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                                Icons.location_on_rounded,
                                                size: 14,
                                                color: AppColors.textHint),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                a.area,
                                                style:
                                                    AppTextStyles.bodySmall,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(status: a.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    _Stat(
                                        label: S.citizens,
                                        value: '${a.citizens}'),
                                    _Divider(),
                                    _Stat(
                                        label: S.rating,
                                        value: a.rating.toStringAsFixed(1)),
                                    _Divider(),
                                    _Stat(
                                        label: S.distance,
                                        value:
                                            '${a.distanceKm.toStringAsFixed(1)} km'),
                                  ],
                                ),
                              ),
                              if (a.status == AppStatus.pending) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _setStatus(
                                            a, AppStatus.rejected),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.danger,
                                          side: const BorderSide(
                                              color: AppColors.danger),
                                          minimumSize:
                                              const Size.fromHeight(44),
                                        ),
                                        icon: const Icon(Icons.close_rounded,
                                            size: 18),
                                        label: Text(S.reject),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _setStatus(
                                            a, AppStatus.accepted),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(44),
                                        ),
                                        icon: const Icon(Icons.check_rounded,
                                            size: 18),
                                        label: Text(S.approve),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentDetails(AgentModel a) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
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
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Avatar(initials: a.avatar, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 2),
                      Text('${S.agentIdLabel}${a.id}',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                StatusChip(status: a.status),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(icon: Icons.phone_rounded, label: a.phone),
            const SizedBox(height: 10),
            _DetailRow(icon: Icons.location_on_rounded, label: a.area),
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.star_rounded,
              label: S.ratingCitizens(a.rating, a.citizens),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
