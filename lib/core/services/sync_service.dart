import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'connectivity_service.dart';
import 'prefs.dart';

enum SyncState { synced, syncing, pending, offline }

/// Tracks unsynced local mutations and drives the app-wide sync indicator.
///
/// Every offline-capable write records a marker here. While offline the markers
/// pile up (and survive relaunch via [Prefs]); when the connection returns they
/// are flushed automatically. In demo mode there is no remote backend, so a
/// flush simply drains the queue — but the queue/indicator behave exactly as
/// they will once Firestore (whose own offline cache mirrors this state) is on.
class SyncService {
  SyncService._();

  static const _kQueue = 'sync_queue';

  static final ValueNotifier<SyncState> state = ValueNotifier(SyncState.synced);
  static final ValueNotifier<int> pending = ValueNotifier(0);

  static final List<Map<String, dynamic>> _queue = [];
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    final raw = Prefs.getString(_kQueue);
    if (raw != null && raw.isNotEmpty) {
      try {
        _queue.addAll(
          (jsonDecode(raw) as List).cast<Map<String, dynamic>>(),
        );
      } catch (_) {}
    }
    pending.value = _queue.length;
    ConnectivityService.online.addListener(_onConnectivityChanged);
    _recompute();
    if (ConnectivityService.online.value && _queue.isNotEmpty) {
      scheduleMicrotask(flush);
    }
  }

  static void _onConnectivityChanged() {
    if (ConnectivityService.online.value) {
      flush();
    } else {
      state.value = SyncState.offline;
    }
  }

  /// Record a local mutation that still needs to reach the backend.
  static void enqueue(String op) {
    _queue.add({'op': op, 'ts': DateTime.now().millisecondsSinceEpoch});
    pending.value = _queue.length;
    _persist();
    if (ConnectivityService.online.value) {
      flush();
    } else {
      state.value = SyncState.offline;
    }
  }

  static Future<void> flush() async {
    if (_queue.isEmpty) {
      _recompute();
      return;
    }
    if (!ConnectivityService.online.value) {
      state.value = SyncState.offline;
      return;
    }
    if (state.value == SyncState.syncing) return;
    state.value = SyncState.syncing;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!ConnectivityService.online.value) {
      state.value = SyncState.offline;
      return;
    }
    _queue.clear();
    pending.value = 0;
    _persist();
    state.value = SyncState.synced;
  }

  static void _recompute() {
    if (!ConnectivityService.online.value) {
      state.value = SyncState.offline;
    } else if (_queue.isEmpty) {
      state.value = SyncState.synced;
    } else {
      state.value = SyncState.pending;
    }
  }

  static void _persist() => Prefs.setString(_kQueue, jsonEncode(_queue));
}
