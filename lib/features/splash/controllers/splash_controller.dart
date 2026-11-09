import 'package:get/get.dart';
import '../../../core/storage/session_storage.dart';
import '../../../app/routes/routes_path.dart';

class SplashController extends GetxController {
  final SessionStorage _session = Get.find<SessionStorage>();

  @override
  void onInit() {
    super.onInit();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1600));

    if (_session.isLoggedIn) {
      Get.offAllNamed(RoutesPath.home);
    } else {
      Get.offAllNamed(RoutesPath.login);
    }
  }
}
