import 'package:get/get.dart';
import '../auth_repository.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
