import 'package:get/get.dart';
import '../../features/auth/login/login_binding.dart';
import '../../features/auth/login/login_view.dart';
import '../../features/auth/register/partner_register_binding.dart';
import '../../features/auth/register/partner_register_view.dart';
import '../../features/home_shell/home_shell_binding.dart';
import '../../features/home_shell/home_shell_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import 'routes_path.dart';

class AppPages {
  AppPages._();

  static const String initial = RoutesPath.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: RoutesPath.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
