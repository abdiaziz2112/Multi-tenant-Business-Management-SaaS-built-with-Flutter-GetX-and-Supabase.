/// Purpose: Public API of the core package. Apps import ONLY this file.
/// Responsibilities: Re-export config, network, errors, utils, services.
/// Dependencies: none beyond src/.
/// Usage: import 'package:core/core.dart';
library core;

export 'src/config/env_config.dart';
export 'src/network/supabase_service.dart';
export 'src/errors/failure.dart';
export 'src/utils/validators.dart';
export 'src/services/session_service.dart';
export 'src/constants/app_constants.dart';
