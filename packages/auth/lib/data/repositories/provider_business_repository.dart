/// Purpose: BusinessRepository implementation over the deployed 00012 RPCs.
/// Responsibilities: rpc() calls + own-row read; DTO translation; mapped errors.
/// Dependencies: core, dtos, mapper, contract.
/// Usage: Get.put<BusinessRepository>(ProviderBusinessRepository()) in bindings.
library;

import 'package:core/core.dart';

import '../../domain/entities/auth_business.dart';
import '../../domain/entities/setup_data.dart';
import '../../domain/repositories/business_repository.dart';
import '../auth_failure_mapper.dart';
import '../dtos/business_dto.dart';

class ProviderBusinessRepository implements BusinessRepository {
  @override
  Future<String> registerBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  }) async {
    try {
      final id = await SupabaseService.client.rpc('register_business', params: {
        'p_business_name': businessName,
        'p_business_email': businessEmail,
        'p_country': country,
        'p_owner_name': ownerName,
      });
      return id as String;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> resubmitBusiness({
    required String businessName,
    required String businessEmail,
    required String country,
    required String ownerName,
  }) async {
    try {
      await SupabaseService.client.rpc('resubmit_business', params: {
        'p_business_name': businessName,
        'p_business_email': businessEmail,
        'p_country': country,
        'p_owner_name': ownerName,
      });
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<AuthBusiness?> fetchOwnBusiness() async {
    try {
      final rows = await SupabaseService.client
          .from('businesses')
          .select('id, name, owner_name, email, country, status, rejection_reason, resubmission_count, setup_completed')
          .limit(1);
      if (rows.isEmpty) return null;
      return BusinessDto.fromMap(rows.first);
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> completeSetup(SetupData data) async {
    try {
      await SupabaseService.client.rpc('complete_setup', params: {
        'p_business': data.toBusinessJson(),
        'p_branch': data.toBranchJson(),
      });
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }
}
