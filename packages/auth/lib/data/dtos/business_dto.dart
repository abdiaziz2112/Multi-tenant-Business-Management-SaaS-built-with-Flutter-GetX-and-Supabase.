/// Purpose: Translate a raw businesses row (Map) into the AuthBusiness entity.
/// Responsibilities: Defensive parsing ONLY — never trust column presence.
/// Dependencies: domain entities.
/// Usage: BusinessDto.fromMap(row) inside the data layer.
library;

import '../../domain/entities/auth_business.dart';
import '../../domain/entities/business_status.dart';

class BusinessDto {
  static AuthBusiness fromMap(Map<String, dynamic> m) => AuthBusiness(
        id: m['id'] as String,
        name: (m['name'] as String?) ?? '',
        status: BusinessStatus.parse(m['status'] as String?),
        rejectionReason: m['rejection_reason'] as String?,
        resubmissionCount: (m['resubmission_count'] as int?) ?? 0,
        setupCompleted: (m['setup_completed'] as bool?) ?? false,
      );
}
