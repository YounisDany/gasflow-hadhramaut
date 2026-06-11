import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/prefs.dart';
import '../../core/services/sync_service.dart';
import '../../core/session/session.dart';
import '../dummy/dummy_data.dart';
import '../models/agent_model.dart';
import '../models/app_status.dart';
import '../models/citizen_model.dart';
import '../models/complaint_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';

/// Single source of truth, backed by **Cloud Firestore**. [bind] attaches
/// realtime listeners that keep the in-memory lists in sync; every mutation is
/// a Firestore write that ripples back through those listeners (and into a
/// Cloud Function that sends the FCM push).
///
/// If Firebase isn't configured yet, [useLocalDemo] fills the same lists from
/// the bundled demo data and routes mutations to memory — so the whole UI is
/// fully usable on a device before `flutterfire configure` is run. The widget
/// layer listens to this `ChangeNotifier` either way.
class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  // Lazy so the singleton can be built even before Firebase is initialized
  // (demo mode never touches Firestore).
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final List<StreamSubscription> _subs = [];
  bool _bound = false;
  bool localMode = false; // true when running on the bundled demo data
  String? _currentOrderId;
  int _seq = 0;

  final List<AgentModel> agents = [];
  final List<CitizenModel> citizens = [];
  final List<OrderModel> orders = [];
  final List<ComplaintModel> complaints = [];
  final List<NotificationModel> notifications = [];

  CollectionReference<Map<String, dynamic>> get _agentsCol =>
      _db.collection('agents');
  CollectionReference<Map<String, dynamic>> get _citizensCol =>
      _db.collection('citizens');
  CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _complaintsCol =>
      _db.collection('complaints');
  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _db.collection('notifications');

  /// Attach realtime Firestore listeners. Idempotent — safe to call from `main`.
  void bind() {
    if (_bound) return;
    _bound = true;
    localMode = false;

    _subs.add(_agentsCol.snapshots().listen((s) {
      agents
        ..clear()
        ..addAll(s.docs.map((d) => AgentModel.fromMap(d.id, d.data())));
      notifyListeners();
    }));

    _subs.add(_citizensCol.snapshots().listen((s) {
      citizens
        ..clear()
        ..addAll(s.docs.map((d) => CitizenModel.fromMap(d.id, d.data())));
      notifyListeners();
    }));

    _subs.add(_ordersCol
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .listen((s) {
      orders
        ..clear()
        ..addAll(s.docs.map((d) => OrderModel.fromMap(d.id, d.data())));
      notifyListeners();
    }));

    _subs.add(_complaintsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      complaints
        ..clear()
        ..addAll(s.docs.map((d) => ComplaintModel.fromMap(d.id, d.data())));
      notifyListeners();
    }));

    _subs.add(_notificationsCol
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((s) {
      notifications
        ..clear()
        ..addAll(s.docs.map((d) => NotificationModel.fromMap(d.id, d.data())));
      notifyListeners();
    }));
  }

  /// Fallback when Firebase isn't available yet: populate everything from the
  /// bundled demo data so the app is fully browsable (reads + in-memory writes).
  /// Offline-first: previously-saved local data is restored from [Prefs] so the
  /// user's changes survive relaunch; only a first run falls back to the seed.
  void useLocalDemo() {
    if (_bound) return;
    localMode = true;
    if (!_loadLocal()) {
      agents
        ..clear()
        ..addAll(DummyData.agents);
      citizens
        ..clear()
        ..addAll(DummyData.citizenRequests);
      orders
        ..clear()
        ..addAll(DummyData.orders);
      complaints
        ..clear()
        ..addAll(DummyData.complaints);
      notifications
        ..clear()
        ..addAll([
          NotificationModel(
            id: 'L-seed-1',
            type: NotificationType.order,
            titleEn: 'New gas order',
            titleAr: 'طلب غاز جديد',
            bodyEn: 'Ahmed Ba-Obaid ordered 2 × 12kg cylinders.',
            bodyAr: 'طلب أحمد باعبيد 2 × اسطوانة 12 كجم.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          ),
          NotificationModel(
            id: 'L-seed-2',
            type: NotificationType.citizenApproved,
            titleEn: 'New citizen request',
            titleAr: 'طلب انضمام جديد',
            bodyEn: 'Sara Al-Kathiri wants to join your district.',
            bodyAr: 'سارة الكثيري ترغب بالانضمام لمنطقتك.',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ]);
      _persistLocal();
    }
    notifyListeners();
  }

  // ─────────────── Local persistence (offline-first demo store) ───────────────
  static const _kSeeded = 'store_seeded';
  static const _kSeq = 'store_seq';
  static const _kAgents = 'store_agents';
  static const _kCitizens = 'store_citizens';
  static const _kOrders = 'store_orders';
  static const _kComplaints = 'store_complaints';
  static const _kNotifs = 'store_notifications';

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  String _encode(Iterable<Map<String, dynamic>> rows) => jsonEncode(rows.toList());

  /// Restore the persisted demo store. Returns false on a first run (nothing
  /// saved yet) so the caller seeds the bundled demo data instead.
  bool _loadLocal() {
    if (!Prefs.getBool(_kSeeded)) return false;
    _seq = int.tryParse(Prefs.getString(_kSeq) ?? '') ?? 0;
    agents
      ..clear()
      ..addAll(_decode(Prefs.getString(_kAgents))
          .map((m) => AgentModel.fromMap(m['id'] as String, m)));
    citizens
      ..clear()
      ..addAll(_decode(Prefs.getString(_kCitizens))
          .map((m) => CitizenModel.fromMap(m['id'] as String, m)));
    orders
      ..clear()
      ..addAll(_decode(Prefs.getString(_kOrders))
          .map((m) => OrderModel.fromMap(m['id'] as String, m)));
    complaints
      ..clear()
      ..addAll(_decode(Prefs.getString(_kComplaints))
          .map((m) => ComplaintModel.fromMap(m['id'] as String, m)));
    notifications
      ..clear()
      ..addAll(_decode(Prefs.getString(_kNotifs))
          .map((m) => NotificationModel.fromMap(m['id'] as String, m)));
    return true;
  }

  void _persistLocal() {
    if (!localMode) return;
    Prefs.setBool(_kSeeded, true);
    Prefs.setString(_kSeq, '$_seq');
    Prefs.setString(_kAgents,
        _encode(agents.map((e) => {'id': e.id, ...e.toMap()})));
    Prefs.setString(_kCitizens,
        _encode(citizens.map((e) => {'id': e.id, ...e.toMap()})));
    Prefs.setString(_kOrders,
        _encode(orders.map((e) => {'id': e.id, ...e.toMap()})));
    Prefs.setString(_kComplaints,
        _encode(complaints.map((e) => {'id': e.id, ...e.toMap()})));
    Prefs.setString(_kNotifs,
        _encode(notifications.map((e) => {'id': e.id, ...e.toMap()})));
  }

  /// Persist the local store, record the mutation in the sync queue and notify
  /// listeners — the single commit point for every demo-mode write.
  void _localCommit(String op) {
    _persistLocal();
    SyncService.enqueue(op);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _bound = false;
    super.dispose();
  }

  // ─────────────── Queries ───────────────
  int get unreadCount => notifications.where((n) => !n.read).length;

  List<OrderModel> ordersByStatus(AppStatus? s) =>
      s == null ? orders : orders.where((o) => o.status == s).toList();

  List<OrderModel> get pendingOrders =>
      orders.where((o) => o.status == AppStatus.pending).toList();

  List<CitizenModel> get approvedCitizens =>
      citizens.where((c) => c.status == AppStatus.accepted).toList();

  OrderModel? get currentOrder {
    if (_currentOrderId != null) {
      final i = orders.indexWhere((o) => o.id == _currentOrderId);
      if (i >= 0) return orders[i];
    }
    return orders.isNotEmpty ? orders.first : null;
  }

  AgentModel? get nearestAgent {
    if (agents.isEmpty) return null;
    final sorted = List.of(agents)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return sorted.first;
  }

  // ─────────────── Agents (admin) ───────────────
  Future<void> setAgentStatus(AgentModel agent, AppStatus status) async {
    if (localMode) {
      final i = agents.indexWhere((a) => a.id == agent.id);
      if (i >= 0) agents[i] = agents[i].copyWith(status: status);
    } else {
      _agentsCol.doc(agent.id).update({'status': status.name});
    }
    if (status == AppStatus.accepted) {
      _push(
        NotificationType.agentApproved,
        titleEn: 'Agent application approved',
        titleAr: 'تمت الموافقة على طلب الوكيل',
        bodyEn: '${agent.nameEn} is now an active agent and can serve citizens.',
        bodyAr: 'أصبح ${agent.nameAr} وكيلاً نشطاً ويمكنه خدمة العملاء.',
      );
    }
    if (localMode) _localCommit('agentStatus');
  }

  // ─────────────── Citizens (agent) ───────────────
  Future<CitizenModel> setCitizenStatus(
      CitizenModel citizen, AppStatus status) async {
    final digits = citizen.id.replaceAll(RegExp(r'[^0-9]'), '');
    final barcode = status == AppStatus.accepted
        ? (citizen.barcodeId ?? 'GF-9C-$digits')
        : citizen.barcodeId;
    final updated = citizen.copyWith(status: status, barcodeId: barcode);
    if (localMode) {
      final i = citizens.indexWhere((c) => c.id == citizen.id);
      if (i >= 0) citizens[i] = updated;
    } else {
      _citizensCol.doc(citizen.id).update({
        'status': status.name,
        'barcodeId': barcode,
      });
    }
    if (status == AppStatus.accepted) {
      _push(
        NotificationType.citizenApproved,
        titleEn: 'You have been approved',
        titleAr: 'تم قبولك من الوكيل',
        bodyEn:
            '${citizen.nameEn} approved — QR code $barcode generated. You can order gas now.',
        bodyAr:
            'تمت الموافقة على ${citizen.nameAr} — رمز QR $barcode. يمكنك طلب الغاز الآن.',
      );
    }
    if (localMode) _localCommit('citizenStatus');
    return updated;
  }

  /// A newly-registered citizen submits a join request → shows up in the
  /// agent's "citizen requests" list (status pending).
  Future<void> submitCitizenRequest({
    required String name,
    required String phone,
    required String address,
    double? lat,
    double? lng,
  }) async {
    final c = CitizenModel(
      id: localMode ? 'L-c-${_seq++}' : 'tmp',
      nameEn: name,
      nameAr: name,
      addressEn: address,
      addressAr: address,
      phone: phone,
      avatar: _initials(name),
      status: AppStatus.pending,
      lat: lat,
      lng: lng,
    );
    if (localMode) {
      citizens.add(c);
    } else {
      _citizensCol.add(c.toMap());
    }
    _push(
      NotificationType.system,
      titleEn: 'New citizen request',
      titleAr: 'طلب انضمام جديد',
      bodyEn: '$name requested to join. Review it in citizen requests.',
      bodyAr: 'طلب $name الانضمام. راجِعه في طلبات العملاء.',
    );
    if (localMode) _localCommit('citizenRequest');
  }

  /// A newly-registered agent submits an application → shows up in the admin's
  /// "manage agents" list (status pending).
  Future<void> submitAgentRequest({
    required String name,
    required String area,
    required String phone,
    double? lat,
    double? lng,
  }) async {
    final a = AgentModel(
      id: localMode ? 'L-a-${_seq++}' : 'tmp',
      nameEn: name,
      nameAr: name,
      areaEn: area,
      areaAr: area,
      phone: phone,
      avatar: _initials(name),
      rating: 0,
      distanceKm: 0,
      citizens: 0,
      status: AppStatus.pending,
      lat: lat,
      lng: lng,
    );
    if (localMode) {
      agents.add(a);
    } else {
      _agentsCol.add(a.toMap());
    }
    _push(
      NotificationType.system,
      titleEn: 'New agent application',
      titleAr: 'طلب وكيل جديد',
      bodyEn: '$name applied to become an agent. Review it in manage agents.',
      bodyAr: 'تقدّم $name ليصبح وكيلاً. راجِعه في إدارة الوكلاء.',
    );
    if (localMode) _localCommit('agentRequest');
  }

  // ─────────────── Orders ───────────────
  Future<OrderModel> addOrder({
    required int cylinders,
    required String size,
    required double total,
    required AgentModel agent,
  }) async {
    final name = Session.nameNotifier.value.trim();
    final region = Session.regionNotifier.value.trim();
    final ref = localMode ? null : _ordersCol.doc();
    final id = ref?.id ?? 'L-ord-${_seq++}';
    final order = OrderModel(
      id: id,
      citizenNameEn: name.isEmpty ? 'You' : name,
      citizenNameAr: name.isEmpty ? 'أنت' : name,
      citizenAvatar: _initials(name),
      addressEn: region.isEmpty ? 'Your address' : region,
      addressAr: region.isEmpty ? 'عنوانك' : region,
      cylinders: cylinders,
      size: size,
      total: total,
      requestedAt: DateTime.now(),
      status: AppStatus.pending,
    );
    _currentOrderId = id;
    if (localMode) {
      orders.insert(0, order);
    } else {
      ref!.set(order.toMap()); // queued locally, synced on reconnect
    }
    _push(
      NotificationType.order,
      titleEn: 'Request sent',
      titleAr: 'تم إرسال الطلب',
      bodyEn: 'Your request was sent to ${agent.nameEn}. Awaiting acceptance.',
      bodyAr: 'تم إرسال طلبك إلى ${agent.nameAr}. بانتظار القبول.',
    );
    if (localMode) _localCommit('addOrder');
    return order;
  }

  Future<void> setOrderStatus(OrderModel order, AppStatus status) async {
    if (localMode) {
      final i = orders.indexWhere((o) => o.id == order.id);
      if (i >= 0) orders[i] = orders[i].copyWith(status: status);
    } else {
      _ordersCol.doc(order.id).update({'status': status.name});
    }
    if (status == AppStatus.accepted) {
      _push(
        NotificationType.order,
        titleEn: 'Order accepted',
        titleAr: 'تم قبول الطلب',
        bodyEn:
            'Order ${order.id} was accepted. We will notify you before and after the refill.',
        bodyAr: 'تم قبول الطلب ${order.id}. سنبلّغك قبل وبعد التعبئة.',
      );
    } else if (status == AppStatus.completed) {
      _push(
        NotificationType.order,
        titleEn: 'Refill completed',
        titleAr: 'تمت التعبئة',
        bodyEn: 'Order ${order.id} has been delivered/refilled successfully.',
        bodyAr: 'تم توصيل/تعبئة الطلب ${order.id} بنجاح.',
      );
    }
    if (localMode) _localCommit('orderStatus');
  }

  /// Agent → customer refill notice (before/after refill).
  void pushCustomerNotice(String name, String message) => _push(
        NotificationType.order,
        titleEn: 'Refill update',
        titleAr: 'تحديث التعبئة',
        bodyEn: '$name — $message',
        bodyAr: '$name — $message',
      );

  // ─────────────── Complaints ───────────────
  Future<void> addComplaint({
    required String title,
    required String description,
  }) async {
    final c = ComplaintModel(
      id: localMode ? 'L-cmp-${_seq++}' : 'tmp',
      titleEn: title,
      titleAr: title,
      descriptionEn: description,
      descriptionAr: description,
      createdAt: DateTime.now(),
      status: AppStatus.pending,
    );
    if (localMode) {
      complaints.insert(0, c);
      _localCommit('addComplaint');
    } else {
      _complaintsCol.add(c.toMap());
    }
  }

  Future<void> resolveComplaint(ComplaintModel c) async {
    if (localMode) {
      final i = complaints.indexWhere((e) => e.id == c.id);
      if (i >= 0) complaints[i] = complaints[i].copyWith(status: AppStatus.completed);
      _localCommit('resolveComplaint');
      return;
    }
    _complaintsCol.doc(c.id).update({'status': AppStatus.completed.name});
  }

  // ─────────────── Notifications ───────────────
  Future<void> markAllRead() async {
    final unread = notifications.where((n) => !n.read).toList();
    if (unread.isEmpty) return;
    if (localMode) {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(read: true);
      }
      _localCommit('markRead');
      return;
    }
    final batch = _db.batch();
    for (final n in unread) {
      batch.update(_notificationsCol.doc(n.id), {'read': true});
    }
    batch.commit();
  }

  // Fire-and-forget: in Firebase mode the write hits the local cache instantly
  // and queues for sync; in demo mode it just prepends to the in-memory list.
  void _push(
    NotificationType type, {
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
  }) {
    if (localMode) {
      notifications.insert(
        0,
        NotificationModel(
          id: 'L-n-${_seq++}',
          type: type,
          titleEn: titleEn,
          titleAr: titleAr,
          bodyEn: bodyEn,
          bodyAr: bodyAr,
          createdAt: DateTime.now(),
        ),
      );
      _persistLocal();
      notifyListeners();
      return;
    }
    _notificationsCol.add({
      'type': type.name,
      'titleEn': titleEn,
      'titleAr': titleAr,
      'bodyEn': bodyEn,
      'bodyAr': bodyAr,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'read': false,
      // Forward-compat: a Cloud Function can target this. 'all' broadcasts.
      'to': 'all',
    });
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AO';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length <= 2 ? p : p.substring(0, 2)).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

/// Convenience accessor.
AppStore get appStore => AppStore.instance;
