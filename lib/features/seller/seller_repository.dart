import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/catalog_product_model.dart';
import '../../shared/models/chat_model.dart';
import '../../shared/models/partner_model.dart';
import '../../shared/models/seller_order_model.dart';
import '../../shared/models/seller_payment_model.dart';

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
    Map<String, File> unitFiles = const {},
  }) async {
    final formMap = <String, dynamic>{
      'orderFor': orderFor,
      'items': jsonEncode(items),
      'note': note ?? '',
    };
    if (orderFor == 'customer' && customer != null) {
      formMap['customer'] = jsonEncode(customer.toJson());
    }
    for (final entry in unitFiles.entries) {
      formMap[entry.key] = await MultipartFile.fromFile(
        entry.value.path,
        filename: entry.value.path.split('/').last,
      );
    }

    final res = await _dio.post(ApiEndpoints.sellerOrders, data: FormData.fromMap(formMap));
    final data = res.data as Map<String, dynamic>;
    return SellerOrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  Future<List<SellerOrderModel>> getMyOrders() async {
    final res = await _dio.get(ApiEndpoints.sellerOrders);
    final data = res.data as Map<String, dynamic>;
    final list = data['orders'] as List? ?? [];
    return list.map((e) => SellerOrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SellerPaymentDue> getPaymentDue() async {
    final res = await _dio.get(ApiEndpoints.sellerPaymentDue);
    final data = res.data as Map<String, dynamic>;
    final due = num.tryParse(data['due']?.toString() ?? '0') ?? 0;
    final orders = (data['orders'] as List? ?? [])
        .map((e) => SellerDueOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return SellerPaymentDue(due: due, orders: orders);
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final res = await _dio.get(ApiEndpoints.paymentMethods);
    final list = res.data as List? ?? [];
    return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SellerPaymentModel> submitPayment({
    required String method,
    required String paymentNumber,
    required String transactionId,
    List<String>? orderIds,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.sellerPayments,
      data: {
        'method': method,
        'paymentNumber': paymentNumber,
        'transactionId': transactionId,
        if (orderIds != null && orderIds.isNotEmpty) 'orderIds': orderIds,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return SellerPaymentModel.fromJson(data['payment'] as Map<String, dynamic>);
  }

  Future<List<SellerPaymentModel>> getMyPayments() async {
    final res = await _dio.get(ApiEndpoints.sellerPayments);
    final data = res.data as Map<String, dynamic>;
    final list = data['payments'] as List? ?? [];
    return list.map((e) => SellerPaymentModel.fromJson(e as Map<String, dynamic>)).toList();
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
