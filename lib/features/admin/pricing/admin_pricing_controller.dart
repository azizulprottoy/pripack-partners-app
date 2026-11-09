import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/catalog_product_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../admin_repository.dart';

class AdminPricingController extends GetxController {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();

  final products = <CatalogProductModel>[].obs;
  final isLoading = true.obs;
  final isSavingPrices = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final list = await _adminRepo.getProducts();
      products.assignAll(list);
    } catch (e, st) {
      AppLogger.error('AdminPricingController.loadProducts failed', e, st);
    }
    isLoading.value = false;
  }

  Future<Map<String, num>> getPricesForProduct(String productId) async {
    return _adminRepo.getSellerPrices(productId);
  }

  Future<void> savePrices(String productId, Map<String, num> prices) async {
    isSavingPrices.value = true;
    try {
      await _adminRepo.setSellerPrices(productId, prices);
      SnackMessage.success('Wholesale seller prices updated.');
      await loadProducts();
    } catch (e) {
      SnackMessage.error('Failed to update seller prices.');
    } finally {
      isSavingPrices.value = false;
    }
  }
}
