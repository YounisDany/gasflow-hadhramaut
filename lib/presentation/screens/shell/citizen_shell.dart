import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../citizen/citizen_home_screen.dart';
import '../citizen/complaints_screen.dart';
import '../citizen/order_status_screen.dart';
import '../citizen/request_gas_screen.dart';
import '../citizen/settings_screen.dart';
import 'main_shell.dart';

/// Citizen role shell: map home + the four action pages, all under one
/// persistent bottom bar. Action tabs are guest-gated; home and settings
/// (language / theme) stay open to guests.
class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShell(
      tabs: [
        ShellTab(
          icon: Icons.map_rounded,
          label: S.tabHome,
          child: const CitizenHomeScreen(),
        ),
        ShellTab(
          icon: Icons.flash_on_rounded,
          label: S.tabRequest,
          requiresAuth: true,
          authMessage: S.signInToRequest,
          child: const RequestGasScreen(embedded: true),
        ),
        ShellTab(
          icon: Icons.receipt_long_rounded,
          label: S.tabOrders,
          requiresAuth: true,
          authMessage: S.signInToTrack,
          child: const OrderStatusScreen(embedded: true),
        ),
        ShellTab(
          icon: Icons.support_agent_rounded,
          label: S.tabSupport,
          requiresAuth: true,
          authMessage: S.signInToSupport,
          child: const ComplaintsScreen(embedded: true),
        ),
        ShellTab(
          icon: Icons.settings_rounded,
          label: S.settings,
          child: const SettingsScreen(embedded: true),
        ),
      ],
    );
  }
}
