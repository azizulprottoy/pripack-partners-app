import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/models/supplier_job_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../supplier_repository.dart';

class SupplierJobsController extends GetxController {
  final SupplierRepository _supplierRepo = Get.find<SupplierRepository>();

  final profile = Rx<PartnerModel?>(null);
  final jobs = <SupplierJobModel>[].obs;
  final filter = 'active'.obs; // 'active', 'pickup', 'done', 'all'
  final isLoading = true.obs;
  final isActing = false.obs;

  bool get canAct => profile.value?.status == AppConstants.statusApproved;

  List<SupplierJobModel> get filteredJobs {
    switch (filter.value) {
      case 'active':
        return jobs.where((j) => j.isAssigned || j.isInProduction).toList();
      case 'pickup':
        return jobs.where((j) => j.isPickupRequested).toList();
      case 'done':
        return jobs.where((j) => j.isPickedUp).toList();
      case 'all':
      default:
        return jobs;
    }
  }

  int get countActive => jobs.where((j) => j.isAssigned || j.isInProduction).length;
  int get countPickup => jobs.where((j) => j.isPickupRequested).length;
  int get countDone => jobs.where((j) => j.isPickedUp).length;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
  }

  Future<void> loadJobs() async {
    isLoading.value = true;
    try {
      profile.value = await _supplierRepo.getProfile();
      final list = await _supplierRepo.getJobs();
      jobs.assignAll(list);
    } catch (e, st) {
      AppLogger.error('SupplierJobsController.loadJobs failed', e, st);
    }
    isLoading.value = false;
  }

  void setFilter(String f) {
    filter.value = f;
  }

  Future<void> actOnJob({
    required SupplierJobModel job,
    required String action, // 'start' | 'pickup'
    String? note,
  }) async {
    if (!canAct) {
      SnackMessage.error('Your supplier account must be approved by admin.');
      return;
    }

    isActing.value = true;
    try {
      await _supplierRepo.updateJob(
        type: job.type,
        id: job.id,
        action: action,
        note: note,
      );
      SnackMessage.success(
        action == 'start'
            ? 'Production started for order #${job.referenceCode}.'
            : 'Pickup requested! Admin & rider notified.',
      );
      await loadJobs();
    } catch (e) {
      SnackMessage.error('Failed to update order status.');
    } finally {
      isActing.value = false;
    }
  }
}
