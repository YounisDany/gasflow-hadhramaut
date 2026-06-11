import 'package:cloud_firestore/cloud_firestore.dart';

import '../dummy/dummy_data.dart';

/// One-time Firestore seeding from the bundled demo data. Safe to call on every
/// launch — it no-ops once `agents` has any document. Trigger it from an
/// authenticated admin context so security rules allow the writes.
class SeedService {
  SeedService._();

  static Future<void> seedIfEmpty() async {
    final db = FirebaseFirestore.instance;
    final existing = await db.collection('agents').limit(1).get();
    if (existing.docs.isNotEmpty) return;

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
    await batch.commit();
  }
}
