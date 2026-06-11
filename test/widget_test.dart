// Smoke tests that don't require Firebase — they exercise pure model logic so
// they run anywhere without network or a configured Firebase project.

import 'package:flutter_test/flutter_test.dart';

import 'package:gas_app/data/models/app_status.dart';
import 'package:gas_app/data/models/order_model.dart';

void main() {
  test('appStatusFromName parses known and falls back to pending', () {
    expect(appStatusFromName('accepted'), AppStatus.accepted);
    expect(appStatusFromName('completed'), AppStatus.completed);
    expect(appStatusFromName('rejected'), AppStatus.rejected);
    expect(appStatusFromName('not-a-status'), AppStatus.pending);
    expect(appStatusFromName(null), AppStatus.pending);
  });

  test('OrderModel round-trips through toMap/fromMap', () {
    final order = OrderModel(
      id: 'ORD-1',
      citizenNameEn: 'Test',
      citizenNameAr: 'تجربة',
      citizenAvatar: 'TT',
      addressEn: 'Street 1',
      addressAr: 'شارع 1',
      cylinders: 2,
      size: '12 kg',
      total: 14000,
      requestedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      status: AppStatus.accepted,
    );
    final restored = OrderModel.fromMap('ORD-1', order.toMap());
    expect(restored.cylinders, 2);
    expect(restored.size, '12 kg');
    expect(restored.total, 14000);
    expect(restored.status, AppStatus.accepted);
    expect(restored.requestedAt, order.requestedAt);
  });
}
