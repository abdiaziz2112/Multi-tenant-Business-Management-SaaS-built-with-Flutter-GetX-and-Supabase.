/// Purpose: DTO parsing is the contract seam with the database — prove it
/// survives nulls, missing keys, and unknown values without crashing.
library;

import 'package:auth/auth.dart';
import 'package:auth/data/dtos/business_dto.dart';
import 'package:auth/data/dtos/device_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BusinessDto parses a full row', () {
    final b = BusinessDto.fromMap({
      'id': 'x',
      'name': 'Hanti Shop',
      'owner_name': 'Cali',
      'email': 'shop@x.so',
      'country': 'Somalia',
      'status': 'rejected',
      'rejection_reason': 'Missing details',
      'resubmission_count': 2,
      'setup_completed': false,
    });
    expect(b.status, BusinessStatus.rejected);
    expect(b.ownerName, 'Cali');
    expect(b.canResubmit, isTrue);
  });

  test('BusinessDto tolerates missing/unknown values (fails closed)', () {
    final b = BusinessDto.fromMap({'id': 'x', 'status': 'weird_future_state'});
    expect(b.status, BusinessStatus.unknown);
    expect(b.resubmissionCount, 0);
    expect(b.setupCompleted, isFalse);
  });

  test('DeviceDto derives trust correctly', () {
    final trusted = DeviceDto.fromMap({
      'id': 'd1',
      'device_fingerprint': 'fp',
      'expires_at':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    });
    expect(trusted.isCurrentlyTrusted, isTrue);

    final revoked = DeviceDto.fromMap({
      'id': 'd2',
      'device_fingerprint': 'fp2',
      'expires_at':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'revoked_at': DateTime.now().toIso8601String(),
    });
    expect(revoked.isCurrentlyTrusted, isFalse);

    final expired = DeviceDto.fromMap({
      'id': 'd3',
      'device_fingerprint': 'fp3',
      'expires_at':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    });
    expect(expired.isCurrentlyTrusted, isFalse);
  });
}
