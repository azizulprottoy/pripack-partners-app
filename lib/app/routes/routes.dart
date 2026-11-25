import 'package:get/get.dart';
import '../../core/storage/session_storage.dart';
import '../../features/auth/login/login_binding.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/auth/register/partner_register_binding.dart';
import '../../features/auth/register/partner_register_view.dart';
import '../../features/home_shell/home_shell_binding.dart';
import '../../features/home_shell/home_shell_view.dart';
import 'routes_path.dart';

class AppPages {
  AppPages._();

  // SessionStorage is already registered (main.dart, before runApp) so this
  // resolves synchronously — no splash screen needed to wait for it.
  static String get initial =>
      Get.find<SessionStorage>().isLoggedIn ? RoutesPath.home : RoutesPath.login;

  static final List<GetPage> routes = [
    GetPage(
      name: RoutesPath.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: RoutesPath.register,
      page: () => const PartnerRegisterView(),
      binding: PartnerRegisterBinding(),
    ),
    GetPage(
      name: RoutesPath.home,
      page: () => const HomeShellView(),
      binding: HomeShellBinding(),
    ),
  ];
}
