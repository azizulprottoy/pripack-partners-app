import 'package:get/get.dart';
import '../../core/storage/session_storage.dart';
import '../admin/admin_repository.dart';
import '../admin/chat/admin_chat_controller.dart';
import '../admin/dashboard/admin_dashboard_controller.dart';
import '../admin/orders/admin_seller_orders_controller.dart';
import '../admin/partners/admin_partners_controller.dart';
import '../admin/pricing/admin_pricing_controller.dart';
import '../auth/auth_repository.dart';
import '../chat/chat_repository.dart';
import '../seller/catalog/seller_catalog_controller.dart';
import '../seller/chat/seller_chat_controller.dart';
import '../seller/dashboard/seller_dashboard_controller.dart';
import '../seller/orders/seller_orders_controller.dart';
import '../seller/profile/seller_profile_controller.dart';
import '../seller/seller_repository.dart';
import '../supplier/chat/supplier_chat_controller.dart';
import '../supplier/jobs/supplier_jobs_controller.dart';
import '../supplier/profile/supplier_profile_controller.dart';
import '../supplier/supplier_repository.dart';

class HomeShellController extends GetxController {
  final SessionStorage session = Get.find<SessionStorage>();

  final currentTabIndex = 0.obs;

  bool get isSeller => session.isSeller;
  bool get isSupplier => session.isSupplier;
  bool get isAdmin => session.isAdmin;

  String get roleDisplayName {
    if (isSeller) return 'Seller';
    if (isSupplier) return 'Supplier';
    return 'Admin';
  }

  @override
  void onInit() {
    super.onInit();
    _initRoleControllers();
  }

  void _initRoleControllers() {
    // Ensure all shared repos
    if (!Get.isRegistered<AuthRepository>()) Get.put(AuthRepository(), permanent: true);
    if (!Get.isRegistered<ChatRepository>()) Get.put(ChatRepository(), permanent: true);

    if (isSeller) {
      if (!Get.isRegistered<SellerRepository>()) Get.put(SellerRepository(), permanent: true);
      if (!Get.isRegistered<SellerDashboardController>()) Get.put(SellerDashboardController());
      if (!Get.isRegistered<SellerCatalogController>()) Get.put(SellerCatalogController());
      if (!Get.isRegistered<SellerOrdersController>()) Get.put(SellerOrdersController());
      if (!Get.isRegistered<SellerChatController>()) Get.put(SellerChatController());
      if (!Get.isRegistered<SellerProfileController>()) Get.put(SellerProfileController());
    } else if (isSupplier) {
      if (!Get.isRegistered<SupplierRepository>()) Get.put(SupplierRepository(), permanent: true);
      if (!Get.isRegistered<SupplierJobsController>()) Get.put(SupplierJobsController());
      if (!Get.isRegistered<SupplierChatController>()) Get.put(SupplierChatController());
      if (!Get.isRegistered<SupplierProfileController>()) Get.put(SupplierProfileController());
    } else if (isAdmin) {
      if (!Get.isRegistered<AdminRepository>()) Get.put(AdminRepository(), permanent: true);
      if (!Get.isRegistered<AdminDashboardController>()) Get.put(AdminDashboardController());
      if (!Get.isRegistered<AdminSellerOrdersController>()) Get.put(AdminSellerOrdersController());
      if (!Get.isRegistered<AdminPartnersController>()) Get.put(AdminPartnersController());
      if (!Get.isRegistered<AdminPricingController>()) Get.put(AdminPricingController());
      if (!Get.isRegistered<AdminChatController>()) Get.put(AdminChatController());
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
