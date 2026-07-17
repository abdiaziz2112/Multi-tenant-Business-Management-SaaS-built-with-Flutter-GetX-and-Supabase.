/// Purpose: Every place the app can land a user after evaluating auth state.
/// Responsibilities: Enum only — the decision lives in AuthFlowResolver.
/// Dependencies: none.
/// Usage: switch (resolver.resolve(...)) { AuthDestination.login => ... }
enum AuthDestination {
  login,            // no session
  verifyEmail,      // session but email unverified
  continueRegistration, // verified user with no business linked (app died mid-flow)
  pending,          // business awaiting platform approval
  rejected,         // business rejected (reason + maybe resubmit)
  suspended,        // business suspended by platform
  setupWizard,      // approved but setup incomplete
  otpChallenge,     // approved+setup but THIS device is not trusted
  unlock,           // trusted device: biometric / PIN gate
  dashboard,        // fully through
}
