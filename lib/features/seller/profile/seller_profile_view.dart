import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/multi_select_dialog.dart';
import '../../../shared/widgets/status_badge.dart';
import 'seller_profile_controller.dart';

class SellerProfileView extends GetView<SellerProfileController> {
  const SellerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading profile...');
        }

        final p = controller.profile.value;
        if (p == null) {
          return const Center(child: Text('Profile information unavailable'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadProfile,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seller Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      if (p.shopPic != null)
                        AppNetworkImage(
                          url: p.shopPic,
                          width: 80,
                          height: 80,
                          borderRadius: BorderRadius.circular(20),
                        )
                      else
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.storefront, size: 36, color: AppColors.primary),
                        ),
                      const SizedBox(height: 14),
                      Text(p.shopName.isNotEmpty ? p.shopName : p.name, style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(p.name, style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 10),
                      StatusBadge(status: p.status),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),

                      _buildInfoRow(Icons.email_outlined, 'Email', p.email),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone_outlined, 'Phone', p.phone),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on_outlined, 'Address', '${p.address}, ${p.district ?? ''}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Categories Box with Edit Option
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('My Product Categories', style: AppTextStyles.h3),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            onPressed: () => _showCategoryPicker(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (p.categories.isEmpty)
                        const Text('No categories selected yet.', style: AppTextStyles.caption)
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: p.categories.map((cat) {
                            return Chip(
                              label: Text(cat, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout button
                OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textLight),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: AppTextStyles.bodyMuted),
        ),
      ],
    );
  }

  void _showCategoryPicker(BuildContext context) async {
    final all = controller.allCategories.map((c) => c.name).toList();
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (_) => MultiSelectDialog(
        title: 'Select Categories You Sell',
        items: all,
        initialSelected: controller.profile.value?.categories ?? [],
      ),
    );

    if (selected != null) {
      controller.updateCategories(selected);
    }
  }
}
