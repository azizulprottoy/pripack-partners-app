import 'package:get/get.dart';
import 'home_shell_controller.dart';

class HomeShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeShellController>(HomeShellController());
  }
}
