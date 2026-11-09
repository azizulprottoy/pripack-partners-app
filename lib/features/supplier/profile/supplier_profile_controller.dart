import 'package:get/get.dart';
import '../../../app/routes/routes_path.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../../auth/auth_repository.dart';
import '../supplier_repository.dart';

class SupplierProfileController extends GetxController {
  final SupplierRepository _supplierRepo = Get.find<SupplierRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final SessionStorage _session = Get.find<SessionStorage>();

  final profile = Rx<PartnerModel?>(null);
  final allCategories = <CategoryModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _supplierRepo.getProfile();
      final cats = await _authRepo.getCategories();
      allCategories.assignAll(cats);
    } catch (e, st) {
      AppLogger.error('SupplierProfileController.loadProfile failed', e, st);
    }
    isLoading.value = false;
  }

  Future<void> updateCategories(List<String> newCats) async {
    try {
      final updated = await _supplierRepo.updateCategories(newCats);
      if (profile.value != null) {
        profile.value = PartnerModel(
          id: profile.value!.id,
          name: profile.value!.name,
          shopName: profile.value!.shopName,
          email: profile.value!.email,
          phone: profile.value!.phone,
          address: profile.value!.address,
          district: profile.value!.district,
          categories: updated,
          status: profile.value!.status,
          statusNote: profile.value!.statusNote,
          shopPic: profile.value!.shopPic,
          nidFront: profile.value!.nidFront,
          nidBack: profile.value!.nidBack,
          createdAt: profile.value!.createdAt,
        );
      }
      SnackMessage.success('Production categories updated successfully.');
    } catch (e) {
      SnackMessage.error('Failed to update categories.');
    }
  }

  Future<void> logout() async {
    await _session.clear();
    Get.offAllNamed(RoutesPath.login);
  }
}
