import 'package:get/get.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/catalog_product_model.dart';
import '../../shared/models/chat_model.dart';
import '../../shared/models/partner_model.dart';
import '../../shared/models/seller_order_model.dart';

class SellerCatalogResult {
  final List<String> categories;
  final List<CatalogProductModel> products;

  SellerCatalogResult({required this.categories, required this.products});
}

class SellerRepository extends GetxService {
  final DioClient _dio = Get.find<DioClient>();

  Future<PartnerModel?> getProfile() async {
    final res = await _dio.get(ApiEndpoints.sellerMe);
    final data = res.data as Map<String, dynamic>;
    if (data['seller'] is Map<String, dynamic>) {
      return PartnerModel.fromJson(data['seller'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<String>> updateCategories(List<String> categories) async {
    final res = await _dio.put(
      ApiEndpoints.sellerMeCategories,
      data: {'categories': categories},
    );
    final data = res.data as Map<String, dynamic>;
    return (data['categories'] as List? ?? []).map((e) => e.toString()).toList();
  }

  Future<SellerCatalogResult> getCatalog({String? category, String? query}) async {
    final params = <String, dynamic>{};
    if (category != null && category.isNotEmpty && category != 'All') {
      params['category'] = category;
    }
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }

    final res = await _dio.get(ApiEndpoints.sellerCatalog, queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final cats = (data['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final prods = (data['products'] as List? ?? [])
        .map((e) => CatalogProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SellerCatalogResult(categories: cats, products: prods);
  }

  Future<SellerOrderModel> placeOrder({
    required String orderFor,
    OrderCustomerInfo? customer,
    required List<Map<String, dynamic>> items,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'orderFor': orderFor,
      'items': items,
      'note': note ?? '',
    };
    if (orderFor == 'customer' && customer != null) {
      body['customer'] = customer.toJson();
    }

    final res = await _dio.post(ApiEndpoints.sellerOrders, data: body);
    final data = res.data as Map<String, dynamic>;
    return SellerOrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  Future<List<SellerOrderModel>> getMyOrders() async {
    final res = await _dio.get(ApiEndpoints.sellerOrders);
    final data = res.data as Map<String, dynamic>;
    final list = data['orders'] as List? ?? [];
    return list.map((e) => SellerOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SellerCustomerConversationModel>> getCustomerConversations(String sellerId) async {
    try {
      final res = await _dio.get('${ApiEndpoints.sellerChat}/$sellerId');
      final list = res.data as List? ?? [];
      return list
          .map((e) => SellerCustomerConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('SellerRepository.getCustomerConversations failed', e, st);
      return [];
    }
  }
}
