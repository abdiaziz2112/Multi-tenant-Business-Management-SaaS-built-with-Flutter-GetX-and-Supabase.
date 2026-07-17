/// Purpose: Public API of the shared authentication package.
/// Responsibilities: Export domain entities/contracts, data implementations,
/// and application services. Apps import ONLY this file.
/// Dependencies: src layers below.
/// Usage: import 'package:auth/auth.dart';
library auth;

export 'domain/entities/auth_route.dart';
export 'domain/entities/business_status.dart';
export 'domain/entities/auth_business.dart';
export 'domain/entities/trusted_device.dart';
export 'domain/entities/setup_data.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/repositories/business_repository.dart';
export 'domain/repositories/device_repository.dart';
export 'data/repositories/provider_auth_repository.dart';
export 'data/repositories/provider_business_repository.dart';
export 'data/repositories/provider_device_repository.dart';
export 'application/auth_flow_resolver.dart';
export 'application/device_identity_service.dart';
export 'application/pin_service.dart';
export 'application/biometric_service.dart';
