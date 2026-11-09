import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/geo_model.dart';

class AuthRepository extends GetxService {
  final DioClient _dio = Get.find<DioClient>();

  Future<Map<String, dynamic>> customerLogin({
    required String emailOrPhone,
    required String password,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.customerLogin,
      data: {
        'emailOrPhone': emailOrPhone.trim(),
        'password': password,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> staffLogin({
    required String remail,
    required String pass,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.staffLogin,
      data: {
        'remail': remail.trim(),
        'pass': pass,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerSeller(FormData formData) async {
    final res = await _dio.post(ApiEndpoints.sellerRegister, data: formData);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerSupplier(FormData formData) async {
    final res = await _dio.post(ApiEndpoints.supplierRegister, data: formData);
    return res.data as Map<String, dynamic>;
  }

  Future<List<DistrictModel>> getDistricts() async {
    try {
      final res = await _dio.get(ApiEndpoints.districts);
      final list = res.data as List? ?? [];
      return list.map((e) => DistrictModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      AppLogger.error('AuthRepository.getDistricts failed', e, st);
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get(ApiEndpoints.getCat);
      final data = res.data;
      final list = data is List
          ? data
          : (data as Map<String, dynamic>?)?['categories'] as List? ?? [];
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      AppLogger.error('AuthRepository.getCategories failed', e, st);
      return [];
    }
  }
}
