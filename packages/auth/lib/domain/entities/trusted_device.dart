/// Purpose: One row of the user's device registry (AUTH-007).
/// Responsibilities: Immutable value object + derived trust state.
/// Dependencies: none.
/// Usage: listed on the Device Management screen.
class TrustedDevice {
  final String id;
  final String fingerprint;
  final String? name;
  final String? platform;
  final DateTime? trustedAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime? lastSeenAt;

  const TrustedDevice({
    required this.id,
    required this.fingerprint,
    required this.name,
    required this.platform,
    required this.trustedAt,
    required this.expiresAt,
    required this.revokedAt,
    required this.lastSeenAt,
  });

  /// Mirrors the database's is_device_trusted() logic for display purposes.
  /// The DATABASE remains the authority; this only paints the list.
  bool get isCurrentlyTrusted =>
      revokedAt == null &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());
}
