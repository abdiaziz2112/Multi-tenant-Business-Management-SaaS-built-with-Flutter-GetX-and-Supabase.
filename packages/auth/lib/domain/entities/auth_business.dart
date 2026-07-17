/// Purpose: The caller's own business as seen during authentication flows.
/// Responsibilities: Immutable value object; no behavior beyond derived flags.
/// Dependencies: BusinessStatus.
/// Usage: built by BusinessDto in the data layer; consumed by controllers.
library;

import 'business_status.dart';

class AuthBusiness {
  final String id;
  final String name;
  final String ownerName;   // prefill for the resubmission form
  final String email;       // prefill for the resubmission form
  final String country;     // prefill for the resubmission form
  final BusinessStatus status;
  final String? rejectionReason;
  final int resubmissionCount;
  final bool setupCompleted;

  const AuthBusiness({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.country,
    required this.status,
    required this.rejectionReason,
    required this.resubmissionCount,
    required this.setupCompleted,
  });

  bool get canResubmit =>
      status == BusinessStatus.rejected && resubmissionCount < 3;
}
