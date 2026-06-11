import 'package:cloud_firestore/cloud_firestore.dart';

import '../dummy/dummy_data.dart';

/// Firestore seeding from the bundled Hadhramaut demo data. Version-gated so
/// updating the demo set (and bumping [_seedVersion]) refreshes it once on the
/// next admin launch, overwriting the same doc IDs in place — no deletes, no
/// orphans. Trigger from an authenticated admin context so rules allow writes.
class SeedService {
  SeedService._();

  /// Bump whenever [DummyData] changes to force a one-time refresh on launch.
  static const int _seedVersion = 2;

  static Future<void> seedIfEmpty() async {
    final db = FirebaseFirestore.instance;
    final marker = await db.collection('settings').doc('seed').get();
    final current = (marker.data()?['version'] as int?) ?? 0;
    final hasAgents =
        (await db.collection('agents').limit(1).get()).docs.isNotEmpty;
    if (hasAgents && current >= _seedVersion) return;

    final batch = db.batch();
    for (final a in DummyData.agents) {
      batch.set(db.collection('agents').doc(a.id), a.toMap());
    }
    for (final c in DummyData.citizenRequests) {
      batch.set(db.collection('citizens').doc(c.id), c.toMap());
    }
    for (final o in DummyData.orders) {
      batch.set(db.collection('orders').doc(o.id), o.toMap());
    }
    for (final cm in DummyData.complaints) {
      batch.set(db.collection('complaints').doc(cm.id), cm.toMap());
    }
    batch.set(db.collection('settings').doc('seed'),
        {'version': _seedVersion}, SetOptions(merge: true));
    await batch.commit();
  }
}
