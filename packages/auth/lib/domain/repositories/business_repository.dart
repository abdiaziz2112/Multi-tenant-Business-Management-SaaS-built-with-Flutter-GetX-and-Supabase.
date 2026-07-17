/// Purpose: Contract for the business lifecycle RPCs of migration 00012.
/// Responsibilities: Pure interface over register/resubmit/fetch/completeSetup.
/// Dependencies: entities only.
/// Usage: injected into registration/status/wizard controllers.
library;

import '../entities/auth_business.dart';
import '../entities/setup_data.dart';

abstract interface class BusinessRepository {
  Future<String> registerBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  });

  Future<void> resubmitBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  });

  /// The caller's own business row, ANY status (Pending/Rejected screens
  /// depend on the status-blind read policy from 00012).
  Future<AuthBusiness?> fetchOwnBusiness();

  Future<void> completeSetup(SetupData data);
}
