import 'package:get/get.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/admin_dashboard_model.dart';
import '../../shared/models/catalog_product_model.dart';
import '../../shared/models/partner_model.dart';
import '../../shared/models/seller_order_model.dart';

class AdminRepository extends GetxService {
  final DioClient _dio = Get.find<DioClient>();

  Future<AdminDashboardModel> getDashboard() async {
    final res = await _dio.get(ApiEndpoints.adminDashboard);
    return AdminDashboardModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<PartnerModel>> getSellers() async {
    final res = await _dio.get(ApiEndpoints.adminSellers);
    final list = res.data as List? ?? [];
    return list.map((e) => PartnerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PartnerModel>> getSuppliers() async {
    final res = await _dio.get(ApiEndpoints.adminSuppliers);
    final list = res.data as List? ?? [];
    return list.map((e) => PartnerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updatePartnerStatus({
    required String kind, // 'seller' | 'supplier'
    required String id,
    required String status, // 'pending' | 'approved' | 'rejected' | 'suspended'
    String? note,
  }) async {
    final path = kind == 'seller'
        ? '${ApiEndpoints.adminSellerStatus}/$id/status'
        : '${ApiEndpoints.adminSupplierStatus}/$id/status';
    await _dio.patch(path, data: {'status': status, 'note': note ?? ''});
  }

  Future<List<SellerOrderModel>> getAllSellerOrders() async {
    final res = await _dio.get(ApiEndpoints.adminSellerOrders);
    final data = res.data as Map<String, dynamic>;
    final list = data['orders'] as List? ?? [];
    return list.map((e) => SellerOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateSellerOrder({
    required String orderId,
    required String action, // 'transfer' | 'pickedup' | 'deliver' | 'cancel'
    String? supplierId,
    String? note,
  }) async {
    final body = <String, dynamic>{'action': action};
    if (supplierId != null) body['supplierId'] = supplierId;
    if (note != null && note.isNotEmpty) body['note'] = note;
    await _dio.patch('${ApiEndpoints.adminUpdateSellerOrder}/$orderId', data: body);
  }

  Future<List<CatalogProductModel>> getProducts() async {
    final res = await _dio.get(ApiEndpoints.getProducts);
    final data = res.data;
    List list = [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['products'] is List) {
      list = data['products'] as List;
    }
    return list.map((e) => CatalogProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, num>> getSellerPrices(String productId) async {
    try {
      final res = await _dio.get('${ApiEndpoints.adminSellerPrices}/$productId');
      final data = res.data as Map<String, dynamic>;
      final rawMap = data['prices'] as Map? ?? {};
      final result = <String, num>{};
      rawMap.forEach((k, v) {
        final parsed = num.tryParse(v.toString());
        if (parsed != null) result[k.toString()] = parsed;
      });
      return result;
    } catch (e, st) {
      AppLogger.error('AdminRepository.getSellerPrices failed', e, st);
      return {};
    }
  }

  Future<void> setSellerPrices(String productId, Map<String, num> prices) async {
    await _dio.put(
      '${ApiEndpoints.adminSellerPrices}/$productId',
      data: {'prices': prices},
    );
  }
}
