/// Purpose: The lifecycle states a business can be in (mirrors DB contract).
/// Responsibilities: Safe parsing from the database string; nothing else.
/// Dependencies: none (pure Dart).
/// Usage: BusinessStatus.parse(row['status'])
enum BusinessStatus {
  pending,
  approved,
  rejected,
  suspended,
  unknown; // defensive: an unrecognized DB value must never crash the app

  static BusinessStatus parse(String? raw) => switch (raw) {
        'pending' => pending,
        'approved' => approved,
        'rejected' => rejected,
        'suspended' => suspended,
        _ => unknown,
      };
}
