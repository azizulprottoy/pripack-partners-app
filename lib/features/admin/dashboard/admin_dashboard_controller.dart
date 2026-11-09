import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/admin_dashboard_model.dart';
import '../admin_repository.dart';

class AdminDashboardController extends GetxController {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();

  final dashboard = Rx<AdminDashboardModel?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final data = await _adminRepo.getDashboard();
      dashboard.value = data;
    } catch (e, st) {
      AppLogger.error('AdminDashboardController.loadDashboard failed', e, st);
    }
    isLoading.value = false;
  }
}
