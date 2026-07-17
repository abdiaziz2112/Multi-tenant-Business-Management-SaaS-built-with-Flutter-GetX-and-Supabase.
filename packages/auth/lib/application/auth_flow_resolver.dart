/// Purpose: THE routing brain of authentication — one pure function that maps
/// auth state to a destination. Every app uses it; tests own its truth table.
/// Responsibilities: Decision only. No IO, no widgets, no provider types.
/// Dependencies: domain entities.
/// Usage: AuthFlowResolver.resolve(hasSession: ..., ...) -> AuthDestination
library;

import '../domain/entities/auth_business.dart';
import '../domain/entities/auth_route.dart';
import '../domain/entities/business_status.dart';

class AuthFlowResolver {
  AuthFlowResolver._();

  static AuthDestination resolve({
    required bool hasSession,
    required bool emailVerified,
    required AuthBusiness? business,
    required bool deviceTrusted,
    bool pinConfigured = false,
    bool biometricAvailable = false,
  }) {
    if (!hasSession) return AuthDestination.login;
    if (!emailVerified) return AuthDestination.verifyEmail;
    if (business == null) return AuthDestination.continueRegistration;

    switch (business.status) {
      case BusinessStatus.pending:
        return AuthDestination.pending;
      case BusinessStatus.rejected:
        return AuthDestination.rejected;
      case BusinessStatus.suspended:
      case BusinessStatus.unknown: // fail CLOSED: unknown is treated as blocked
        return AuthDestination.suspended;
      case BusinessStatus.approved:
        if (!business.setupCompleted) return AuthDestination.setupWizard;
        if (!deviceTrusted) return AuthDestination.otpChallenge;
        // Trusted device: something must be able to open the door.
        if (!pinConfigured && !biometricAvailable) {
          return AuthDestination.pinSetup;
        }
        return AuthDestination.unlock;
    }
  }
}
