import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../admin_repository.dart';

class AdminPartnersController extends GetxController {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();

  final currentKind = 'seller'.obs; // 'seller' or 'supplier'
  final statusFilter = 'all'.obs; // 'all', 'pending', 'approved', 'rejected', 'suspended'

  final sellers = <PartnerModel>[].obs;
  final suppliers = <PartnerModel>[].obs;

  final isLoading = true.obs;

  List<PartnerModel> get currentList {
    final list = currentKind.value == 'seller' ? sellers : suppliers;
    if (statusFilter.value == 'all') return list;
    return list.where((p) => p.status == statusFilter.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadPartners();
  }

  Future<void> loadPartners() async {
    isLoading.value = true;
    try {
      final sList = await _adminRepo.getSellers();
      sellers.assignAll(sList);

      final supList = await _adminRepo.getSuppliers();
      suppliers.assignAll(supList);
    } catch (e, st) {
      AppLogger.error('AdminPartnersController.loadPartners failed', e, st);
    }
    isLoading.value = false;
  }

  void switchKind(String kind) {
    currentKind.value = kind;
  }

  void setFilter(String filter) {
    statusFilter.value = filter;
  }

  Future<void> updatePartnerStatus(String id, String newStatus, [String? note]) async {
    try {
      await _adminRepo.updatePartnerStatus(
        kind: currentKind.value,
        id: id,
        status: newStatus,
        note: note,
      );
      SnackMessage.success('Partner status updated to $newStatus.');
      await loadPartners();
    } catch (e) {
      SnackMessage.error('Failed to update status.');
    }
  }
}
