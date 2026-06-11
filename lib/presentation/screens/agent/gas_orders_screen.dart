import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_status.dart';
import '../../../data/models/order_model.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_tile.dart';

class GasOrdersScreen extends StatefulWidget {
  final bool embedded;
  const GasOrdersScreen({super.key, this.embedded = false});

  @override
  State<GasOrdersScreen> createState() => _GasOrdersScreenState();
}

class _GasOrdersScreenState extends State<GasOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 4, vsync: this, initialIndex: 0);

  void _setStatus(OrderModel o, AppStatus s) => appStore.setOrderStatus(o, s);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.gasOrdersTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(text: S.tabAll),
                Tab(text: S.tabPending),
                Tab(text: S.tabAccepted),
                Tab(text: S.tabDone),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: appStore,
          builder: (context, _) => TabBarView(
            controller: _tab,
            children: [
              _buildList(appStore.ordersByStatus(null)),
              _buildList(appStore.ordersByStatus(AppStatus.pending)),
              _buildList(appStore.ordersByStatus(AppStatus.accepted)),
              _buildList(appStore.ordersByStatus(AppStatus.completed)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.local_shipping_rounded,
        title: S.noOrdersHere,
        message: S.noOrdersHereDesc,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = orders[i];
        return OrderTile(
          order: o,
          actions: o.status == AppStatus.pending
              ? [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setStatus(o, AppStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(S.reject),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _setStatus(o, AppStatus.accepted),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(S.accept),
                    ),
                  ),
                ]
              : (o.status == AppStatus.accepted
                  ? [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _setStatus(o, AppStatus.completed),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18),
                          label: Text(S.markDelivered),
                        ),
                      ),
                    ]
                  : const []),
        );
      },
    );
  }
}
