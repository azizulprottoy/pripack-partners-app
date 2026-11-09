import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/seller_order_model.dart';
import '../seller_repository.dart';

class SellerOrdersController extends GetxController {
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();

  final orders = <SellerOrderModel>[].obs;
  final filterStatus = 'All'.obs;
  final isLoading = true.obs;

  List<SellerOrderModel> get filteredOrders {
    if (filterStatus.value == 'All') return orders;
    return orders.where((o) => o.status == filterStatus.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final list = await _sellerRepo.getMyOrders();
      orders.assignAll(list);
    } catch (e, st) {
      AppLogger.error('SellerOrdersController.fetchOrders failed', e, st);
    }
    isLoading.value = false;
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }
}
