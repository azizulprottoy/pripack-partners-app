import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/constants.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'partner_register_controller.dart';

class PartnerRegisterView extends GetView<PartnerRegisterController> {
  const PartnerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.role.value == AppConstants.roleSeller
                  ? 'Seller Registration'
                  : 'Supplier Registration',
            )),
      ),
      body: Obx(() {
        if (controller.isFetchingOptions.value) {
          return const LoadingIndicator(message: 'Loading options...');
        }

        final isSeller = controller.role.value == AppConstants.roleSeller;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isSeller
                            ? 'Apply as a Seller to get wholesale prices, manage client packaging orders, and earn profits.'
                            : 'Apply as a Supplier/Manufacturer to receive and fulfill customer and seller print jobs.',
                        style: AppTextStyles.bodyMuted.copyWith(color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              CustomTextField(
                label: 'Full Name',
                hint: 'e.g. John Doe',
                controller: controller.nameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: isSeller ? 'Shop / Brand Name' : 'Factory / Company Name',
                hint: isSeller ? 'e.g. Pripack Store Dhaka' : 'e.g. Apex Packaging Mills',
                controller: controller.shopNameController,
                prefixIcon: const Icon(Icons.store_outlined, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email Address',
                hint: 'partner@example.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                hint: '01700000000',
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Account Password',
                hint: 'At least 6 characters',
                controller: controller.passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),

              // District Selector
              const Text(
                'District',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textNormal),
              ),
              const SizedBox(height: 6),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedDistrictId.value.isEmpty
                            ? null
                            : controller.selectedDistrictId.value,
                        hint: const Text('Select your district', style: TextStyle(color: AppColors.textLight)),
                        items: controller.districts.map((d) {
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(d.name, style: AppTextStyles.body),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedDistrictId.value = val;
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Full Address',
                hint: 'House, Road, Area, Thana',
                controller: controller.addressController,
                maxLines: 2,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),

              // Categories Selection
              Text(
                isSeller ? 'Product Categories You Sell' : 'Categories You Can Produce',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textNormal),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.categories.map((c) {
                      final selected = controller.selectedCategories.contains(c.name);
                      return FilterChip(
                        label: Text(c.name),
                        selected: selected,
                        onSelected: (_) => controller.toggleCategory(c.name),
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primaryDark : AppColors.textNormal,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 24),

              // Identity Documents & Shop Photo
              const Text(
                'Verification Documents',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload National ID and business photo for admin review',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildImageUploadCard(
                      label: 'NID Front',
                      fileRx: controller.nidFront,
                      onTap: () => controller.pickImage('nidFront'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageUploadCard(
                      label: 'NID Back',
                      fileRx: controller.nidBack,
                      onTap: () => controller.pickImage('nidBack'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildImageUploadCard(
                label: isSeller ? 'Shop Front / Premises Photo' : 'Factory / Workshop Photo',
                fileRx: controller.shopPic,
                onTap: () => controller.pickImage('shopPic'),
                isWide: true,
              ),
              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    text: 'Submit Application',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.register,
                  )),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImageUploadCard({
    required String label,
    required Rx<File?> fileRx,
    required VoidCallback onTap,
    bool isWide = false,
  }) {
    return Obx(() {
      final file = fileRx.value;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: isWide ? 100 : 110,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: file != null ? AppColors.primary : AppColors.border,
              width: file != null ? 1.5 : 1,
            ),
          ),
          child: file != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(file, fit: BoxFit.cover),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    const Text('Tap to upload', style: AppTextStyles.caption),
                  ],
                ),
        ),
      );
    });
  }
}
