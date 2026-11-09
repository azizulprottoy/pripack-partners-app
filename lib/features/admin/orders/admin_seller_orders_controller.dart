import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/models/seller_order_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../admin_repository.dart';

class AdminSellerOrdersController extends GetxController {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();

  final orders = <SellerOrderModel>[].obs;
  final suppliers = <PartnerModel>[].obs;
  final filterStatus = 'All'.obs;

  final isLoading = true.obs;
  final isUpdating = false.obs;

  List<SellerOrderModel> get filteredOrders {
    if (filterStatus.value == 'All') return orders;
    return orders.where((o) => o.status == filterStatus.value).toList();
  }

  List<PartnerModel> get approvedSuppliers =>
      suppliers.where((s) => s.status == 'approved').toList();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final oList = await _adminRepo.getAllSellerOrders();
      orders.assignAll(oList);

      final sList = await _adminRepo.getSuppliers();
      suppliers.assignAll(sList);
    } catch (e, st) {
      AppLogger.error('AdminSellerOrdersController.loadOrders failed', e, st);
    }
    isLoading.value = false;
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  Future<bool> updateOrder({
    required String orderId,
    required String action, // 'transfer' | 'pickedup' | 'deliver' | 'cancel'
    String? supplierId,
    String? note,
  }) async {
    isUpdating.value = true;
    try {
      await _adminRepo.updateSellerOrder(
        orderId: orderId,
        action: action,
        supplierId: supplierId,
        note: note,
      );
      SnackMessage.success('Order status updated successfully.');
      await loadOrders();
      return true;
    } catch (e) {
      SnackMessage.error('Failed to update order status.');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
