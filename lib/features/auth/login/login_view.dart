import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/constants.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront_rounded, size: 44, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pripack Partner Portal',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your registered partner or admin credentials',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Unified Input Fields
              CustomTextField(
                label: 'Email or Phone Number',
                hint: 'Enter your registered email or phone',
                controller: controller.emailPhoneController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textLight),
              ),
              const SizedBox(height: 18),
              Obx(() => CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textLight,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),
              const SizedBox(height: 28),

              // Single Unified Sign In Button
              Obx(() => CustomButton(
                    text: 'Sign In',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                  )),
              const SizedBox(height: 36),

              // Apply / Register Links
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Interested in partnering with Pripack?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textNormal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.goToRegister(AppConstants.roleSeller),
                      icon: const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                      label: const Text('Become a Seller', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.goToRegister(AppConstants.roleSupplier),
                      icon: const Icon(Icons.factory_outlined, size: 16, color: AppColors.cyan),
                      label: const Text('Become a Supplier', style: TextStyle(fontSize: 12, color: AppColors.cyan)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cyan),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
