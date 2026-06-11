import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Single source of truth for the device's online/offline state. Everything that
/// reacts to connectivity (the sync queue, the status banner, per-screen
/// indicators) listens to [online] instead of subscribing to the plugin twice.
class ConnectivityService {
  ConnectivityService._();

  static final ValueNotifier<bool> online = ValueNotifier(true);
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  static Future<void> init() async {
    final c = Connectivity();
    try {
      _apply(await c.checkConnectivity());
    } catch (_) {
      // Plugin unavailable on this platform — assume online.
    }
    _sub ??= c.onConnectivityChanged.listen(_apply);
  }

  static void _apply(List<ConnectivityResult> results) {
    final isOnline =
        results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
    online.value = isOnline;
  }
}
