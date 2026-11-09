import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import 'admin_partners_controller.dart';

class AdminPartnersView extends GetView<AdminPartnersController> {
  const AdminPartnersView({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'pending', 'approved', 'rejected', 'suspended'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Kind Switcher (Sellers vs Suppliers)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Obx(() {
              final isSeller = controller.currentKind.value == 'seller';
              return Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Sellers')),
                      selected: isSeller,
                      onSelected: (_) => controller.switchKind('seller'),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSeller ? Colors.white : AppColors.textDark,
                        fontWeight: isSeller
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Suppliers')),
                      selected: !isSeller,
                      onSelected: (_) => controller.switchKind('supplier'),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: !isSeller ? Colors.white : AppColors.textDark,
                        fontWeight: !isSeller
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          // Status Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 34,
              child: Obx(() {
                final current = controller.statusFilter.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final f = filters[index];
                    final isSelected = current == f;
                    return ChoiceChip(
                      label: Text(f.toUpperCase()),
                      selected: isSelected,
                      onSelected: (_) => controller.setFilter(f),
                      selectedColor: AppColors.textDark,
                      backgroundColor: AppColors.inputBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    );
                  },
                );
              }),
            ),
          ),

          // Partners List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading partners...');
              }

              final list = controller.currentList;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No Partners Found',
                  message: 'No accounts match the current filter.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadPartners,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final partner = list[index];
                    return _PartnerCard(
                      partner: partner,
                      onTap: () =>
                          _showPartnerDetails(context, partner, controller),
                      onAction: (status) =>
                          controller.updatePartnerStatus(partner.id, status),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showPartnerDetails(
    BuildContext context,
    PartnerModel partner,
    AdminPartnersController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PartnerDetailsSheet(
        partner: partner,
        onAction: (status) {
          controller.updatePartnerStatus(partner.id, status);
          Get.back();
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final PartnerModel partner;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  const _PartnerCard({
    required this.partner,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (partner.shopPic != null)
                  AppNetworkImage(
                    url: partner.shopPic,
                    width: 54,
                    height: 54,
                    borderRadius: BorderRadius.circular(12),
                  )
                else
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.storefront,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.shopName.isNotEmpty
                            ? partner.shopName
                            : partner.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${partner.name} • ${partner.phone}',
                        style: AppTextStyles.caption,
                      ),
                      if (partner.district != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'District: ${partner.district}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                StatusBadge(status: partner.status),
              ],
            ),

            if (partner.categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: partner.categories.map((c) {
                  return Chip(
                    label: Text(c, style: const TextStyle(fontSize: 10)),
                    backgroundColor: AppColors.inputBg,
                    padding: EdgeInsets.zero,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (partner.status != AppConstants.statusApproved) ...[
                  ElevatedButton(
                    onPressed: () => onAction('approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (partner.status != AppConstants.statusRejected) ...[
                  OutlinedButton(
                    onPressed: () => onAction('rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (partner.status == AppConstants.statusApproved) ...[
                  OutlinedButton(
                    onPressed: () => onAction('suspended'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.warning),
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Suspend',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerDetailsSheet extends StatelessWidget {
  final PartnerModel partner;
  final ValueChanged<String> onAction;

  const _PartnerDetailsSheet({required this.partner, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.shopName.isNotEmpty
                                ? partner.shopName
                                : partner.name,
                            style: AppTextStyles.h2,
                          ),
                          Text(partner.name, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    StatusBadge(status: partner.status),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        if (partner.shopPic != null)
                          AppNetworkImage(
                            url: partner.shopPic,
                            width: 64,
                            height: 64,
                            borderRadius: BorderRadius.circular(12),
                          )
                        else
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: AppColors.primary,
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Registered: ${AppFormatters.formatDate(partner.createdAt)}',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Contact Details', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: partner.name,
                    ),
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: partner.email,
                    ),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: partner.phone,
                    ),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value:
                          '${partner.address}${partner.district != null ? ', ${partner.district}' : ''}',
                    ),

                    if (partner.categories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Categories', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: partner.categories
                            .map(
                              (c) => Chip(
                                label: Text(
                                  c,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    if (partner.statusNote != null &&
                        partner.statusNote!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Status Note', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Text(partner.statusNote!, style: AppTextStyles.caption),
                    ],

                    const SizedBox(height: 20),
                    const Text(
                      'Verification Documents',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DocThumb(
                            label: 'NID Front',
                            url: partner.nidFront,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DocThumb(
                            label: 'NID Back',
                            url: partner.nidBack,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (partner.status != AppConstants.statusApproved) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => onAction('approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (partner.status != AppConstants.statusRejected) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => onAction('rejected'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                        if (partner.status == AppConstants.statusApproved) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => onAction('suspended'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.warning,
                                ),
                                foregroundColor: AppColors.warning,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Suspend'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocThumb extends StatelessWidget {
  final String label;
  final String? url;

  const _DocThumb({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1.4,
          child: AppNetworkImage(
            url: url,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
