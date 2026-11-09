import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/routes_path.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/snack_message.dart';
import '../auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final SessionStorage _session = Get.find<SessionStorage>();

  final emailPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final input = emailPhoneController.text.trim();
    final pass = passwordController.text;

    if (input.isEmpty) {
      SnackMessage.error('Please enter your email or phone number.');
      return;
    }
    if (pass.isEmpty) {
      SnackMessage.error('Please enter your password.');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Try customerLogin first (authenticates Seller or Supplier)
      Map<String, dynamic>? partnerRes;
      try {
        partnerRes = await _authRepo.customerLogin(emailOrPhone: input, password: pass);
      } catch (e, st) {
        AppLogger.error('LoginController.login customerLogin failed', e, st);
        partnerRes = null;
      }

      if (partnerRes != null && partnerRes['success'] == true && partnerRes['token'] != null) {
        final user = (partnerRes['user'] as Map<String, dynamic>?) ?? {};
        final atype = user['atype']?.toString();

        if (atype == AppConstants.roleSeller) {
          await _session.saveSession(
            token: partnerRes['token'].toString(),
            user: user,
            role: AppConstants.roleSeller,
          );
          SnackMessage.success('Welcome back, ${user['name'] ?? 'Seller'}!');
          Get.offAllNamed(RoutesPath.home);
          return;
        } else if (atype == AppConstants.roleSupplier) {
          await _session.saveSession(
            token: partnerRes['token'].toString(),
            user: user,
            role: AppConstants.roleSupplier,
          );
          SnackMessage.success('Welcome back, ${user['name'] ?? 'Supplier'}!');
          Get.offAllNamed(RoutesPath.home);
          return;
        } else {
          SnackMessage.error('This account does not have partner portal access.');
          return;
        }
      }

      // 2. If not a seller or supplier, try staffLogin (Admin / Staff)
      try {
        final staffRes = await _authRepo.staffLogin(remail: input, pass: pass);
        if (staffRes['success'] == true && staffRes['token'] != null) {
          final user = (staffRes['user'] as Map<String, dynamic>?) ?? {};
          await _session.saveSession(
            token: staffRes['token'].toString(),
            user: user,
            role: AppConstants.roleAdmin,
          );
          SnackMessage.success('Welcome back, Admin!');
          Get.offAllNamed(RoutesPath.home);
          return;
        } else {
          SnackMessage.error(staffRes['message']?.toString() ?? 'Invalid credentials.');
        }
      } catch (err) {
        SnackMessage.error('Invalid email/phone or password. Please try again.');
      }
    } catch (e) {
      SnackMessage.error('An error occurred during login. Please check server connection.');
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister(String role) {
    Get.toNamed(RoutesPath.register, arguments: {'role': role});
  }
}
