import 'package:get/get.dart';
import '../auth_repository.dart';
import 'partner_register_controller.dart';

class PartnerRegisterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<PartnerRegisterController>(() => PartnerRegisterController());
  }
}
