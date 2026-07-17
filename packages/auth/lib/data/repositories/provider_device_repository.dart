/// Purpose: DeviceRepository implementation over the AUTH-007 RPCs.
/// Responsibilities: One method per deployed RPC + registry listing.
/// Dependencies: core, dtos, mapper, contract.
/// Usage: Get.put<DeviceRepository>(ProviderDeviceRepository()) in bindings.
library;

import 'package:core/core.dart';

import '../../domain/entities/trusted_device.dart';
import '../../domain/repositories/device_repository.dart';
import '../auth_failure_mapper.dart';
import '../dtos/device_dto.dart';

class ProviderDeviceRepository implements DeviceRepository {
  @override
  Future<bool> isDeviceTrusted(String fingerprint) async {
    try {
      final r = await SupabaseService.client
          .rpc('is_device_trusted', params: {'p_fingerprint': fingerprint});
      return r as bool;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<String> trustDevice({
    required String fingerprint,
    required String name,
    required String platform,
  }) async {
    try {
      final r = await SupabaseService.client.rpc('trust_device', params: {
        'p_fingerprint': fingerprint,
        'p_name': name,
        'p_platform': platform,
      });
      return r as String;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> touchDevice(String fingerprint) async {
    try {
      await SupabaseService.client
          .rpc('touch_device', params: {'p_fingerprint': fingerprint});
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<List<TrustedDevice>> listDevices() async {
    try {
      final rows = await SupabaseService.client
          .from('devices')
          .select()
          .order('last_seen_at', ascending: false);
      return rows.map<TrustedDevice>(DeviceDto.fromMap).toList();
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    try {
      await SupabaseService.client
          .rpc('revoke_device', params: {'p_device_id': deviceId});
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<int> revokeAllDevices() async {
    try {
      final r = await SupabaseService.client.rpc('revoke_all_devices');
      return r as int;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }

  @override
  Future<int> revokeOtherDevices(String currentFingerprint) async {
    try {
      final r = await SupabaseService.client.rpc('revoke_other_devices',
          params: {'p_current_fingerprint': currentFingerprint});
      return r as int;
    } catch (e) {
      throw AuthFailureMapper.map(e);
    }
  }
}
