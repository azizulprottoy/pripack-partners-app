import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
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

  // Books a CC-Delivery rider for this order. Unlike updateOrder, failures
  // here are surfaced verbatim — the backend's message tells the admin
  // exactly what's missing (e.g. a supplier's pickup address isn't saved
  // yet), which is the whole point of the two-step flow.
  Future<bool> requestRider({
    required String orderId,
    Map<String, dynamic>? pickup,
    required Map<String, dynamic> delivery,
  }) async {
    isUpdating.value = true;
    try {
      await _adminRepo.requestRider(orderId: orderId, pickup: pickup, delivery: delivery);
      SnackMessage.success('Rider requested.');
      await loadOrders();
      return true;
    } on DioException catch (e, st) {
      AppLogger.error('AdminSellerOrdersController.requestRider failed', e, st);
      final message = (e.response?.data is Map) ? e.response?.data['message']?.toString() : null;
      SnackMessage.error(message ?? 'Failed to request rider.');
      return false;
    } catch (e, st) {
      AppLogger.error('AdminSellerOrdersController.requestRider failed', e, st);
      SnackMessage.error('Failed to request rider.');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
