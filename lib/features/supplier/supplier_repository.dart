import 'package:get/get.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../shared/models/partner_model.dart';
import '../../shared/models/supplier_job_model.dart';

class SupplierRepository extends GetxService {
  final DioClient _dio = Get.find<DioClient>();

  Future<PartnerModel?> getProfile() async {
    final res = await _dio.get(ApiEndpoints.supplierMe);
    final data = res.data as Map<String, dynamic>;
    if (data['supplier'] is Map<String, dynamic>) {
      return PartnerModel.fromJson(data['supplier'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<String>> updateCategories(List<String> categories) async {
    final res = await _dio.put(
      ApiEndpoints.supplierMeCategories,
      data: {'categories': categories},
    );
    final data = res.data as Map<String, dynamic>;
    return (data['categories'] as List? ?? []).map((e) => e.toString()).toList();
  }

  Future<List<SupplierJobModel>> getJobs() async {
    final res = await _dio.get(ApiEndpoints.supplierJobs);
    final data = res.data as Map<String, dynamic>;
    final list = data['jobs'] as List? ?? [];
    return list.map((e) => SupplierJobModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> updateJob({
    required String type,
    required String id,
    required String action, // 'start' | 'pickup'
    String? note,
  }) async {
    final res = await _dio.patch(
      '${ApiEndpoints.updateSupplierJob}/$type/$id',
      data: {
        'action': action,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final data = res.data as Map<String, dynamic>;
    return data['supplierStatus']?.toString() ?? '';
  }
}
