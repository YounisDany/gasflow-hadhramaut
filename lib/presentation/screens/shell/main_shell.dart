import 'package:flutter/material.dart';

import '../../../core/session/session.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/auth_gate.dart';

/// One tab in a [MainShell]: its nav icon/label, the screen it shows, and an
/// optional guest gate (tapping a gated tab as a guest opens the sign-in sheet
/// instead of switching).
class ShellTab {
  final IconData icon;
  final String label;
  final Widget child;
  final bool requiresAuth;
  final String? authMessage;
  const ShellTab({
    required this.icon,
    required this.label,
    required this.child,
    this.requiresAuth = false,
    this.authMessage,
  });
}

/// Persistent tab scaffold shared by both role shells. Keeps every visited tab
/// alive in an [IndexedStack] (so scroll position / form state survive tab
/// switches) and renders the floating [AppBottomNav] over all of them, so the
/// bar stays visible on every main page. Tabs are built lazily — a tab's widget
/// isn't created until its first visit — to keep startup light.
class MainShell extends StatefulWidget {
  final List<ShellTab> tabs;
  final int initialIndex;
  const MainShell({super.key, required this.tabs, this.initialIndex = 0});

  /// Lets a descendant inside a tab switch tabs (e.g. confirming an order jumps
  /// to the orders tab). Returns null when not hosted in a shell.
  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;
  late final Set<int> _loaded = {widget.initialIndex};

  int get index => _index;

  /// Switch tabs programmatically. Honors the same guest gate as a nav tap.
  void goToTab(int i) => _go(i);

  void _go(int i) {
    if (i < 0 || i >= widget.tabs.length) return;
    final tab = widget.tabs[i];
    if (tab.requiresAuth && Session.isGuest) {
      AuthGate.requireAuth(context, message: tab.authMessage);
      return;
    }
    if (i == _index) return;
    setState(() {
      _loaded.add(i);
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          for (int i = 0; i < widget.tabs.length; i++)
            _loaded.contains(i)
                ? widget.tabs[i].child
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _go,
        items: [for (final t in widget.tabs) AppNavItem(t.icon, t.label)],
      ),
    );
  }
}
