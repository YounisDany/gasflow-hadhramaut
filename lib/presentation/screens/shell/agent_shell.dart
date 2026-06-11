import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../agent/agent_home_screen.dart';
import '../agent/barcode_scanner_screen.dart';
import '../agent/citizen_requests_screen.dart';
import '../agent/gas_orders_screen.dart';
import 'main_shell.dart';

/// Agent role shell: dashboard + the three operational pages under one
/// persistent bottom bar.
class AgentShell extends StatelessWidget {
  const AgentShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShell(
      tabs: [
        ShellTab(
          icon: Icons.home_rounded,
          label: S.tabHome,
          child: const AgentHomeScreen(),
        ),
        ShellTab(
          icon: Icons.person_add_alt_rounded,
          label: S.tabRequests,
          child: const CitizenRequestsScreen(embedded: true),
        ),
        ShellTab(
          icon: Icons.local_shipping_rounded,
          label: S.tabOrders,
          child: const GasOrdersScreen(embedded: true),
        ),
        ShellTab(
          icon: Icons.qr_code_scanner_rounded,
          label: S.tabScan,
          child: const BarcodeScannerScreen(embedded: true),
        ),
      ],
    );
  }
}
