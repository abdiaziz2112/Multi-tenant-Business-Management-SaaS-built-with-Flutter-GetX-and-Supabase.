/// Purpose: Translate a raw devices row (Map) into the TrustedDevice entity.
/// Responsibilities: Defensive parsing incl. nullable timestamps.
/// Dependencies: domain entities.
/// Usage: DeviceDto.fromMap(row) inside the data layer.
library;

import '../../domain/entities/trusted_device.dart';

class DeviceDto {
  static DateTime? _ts(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);

  static TrustedDevice fromMap(Map<String, dynamic> m) => TrustedDevice(
        id: m['id'] as String,
        fingerprint: (m['device_fingerprint'] as String?) ?? '',
        name: m['device_name'] as String?,
        platform: m['platform'] as String?,
        trustedAt: _ts(m['trusted_at']),
        expiresAt: _ts(m['expires_at']),
        revokedAt: _ts(m['revoked_at']),
        lastSeenAt: _ts(m['last_seen_at']),
      );
}
