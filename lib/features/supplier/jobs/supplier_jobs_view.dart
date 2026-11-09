import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/supplier_job_model.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import 'supplier_jobs_controller.dart';

class SupplierJobsView extends GetView<SupplierJobsController> {
  const SupplierJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Obx(() {
              final f = controller.filter.value;
              return Row(
                children: [
                  _buildFilterBtn('To do (${controller.countActive})', 'active', f == 'active'),
                  const SizedBox(width: 8),
                  _buildFilterBtn('Pickup (${controller.countPickup})', 'pickup', f == 'pickup'),
                  const SizedBox(width: 8),
                  _buildFilterBtn('Done (${controller.countDone})', 'done', f == 'done'),
                  const SizedBox(width: 8),
                  _buildFilterBtn('All (${controller.jobs.length})', 'all', f == 'all'),
                ],
              );
            }),
          ),

          // Status Banner if not approved
          Obx(() {
            if (!controller.canAct && controller.profile.value != null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Account status is "${controller.profile.value!.status}". Admin approval required to accept and update jobs.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Jobs List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading production orders...');
              }

              final list = controller.filteredJobs;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.precision_manufacturing_outlined,
                  title: 'No Production Jobs',
                  message: 'When admin assigns customer or seller orders to your factory, they appear here.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadJobs,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final job = list[index];
                    return _JobCard(
                      job: job,
                      canAct: controller.canAct,
                      onAction: (action, note) => controller.actOnJob(job: job, action: action, note: note),
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

  Widget _buildFilterBtn(String title, String val, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatefulWidget {
  final SupplierJobModel job;
  final bool canAct;
  final void Function(String action, String? note) onAction;

  const _JobCard({
    required this.job,
    required this.canAct,
    required this.onAction,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final j = widget.job;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('#${j.referenceCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                j.type == 'seller' ? 'SELLER ORDER' : 'CUSTOMER ORDER',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Assigned ${AppFormatters.formatDate(j.date)}${j.deliveryPeriod != null && j.deliveryPeriod!.isNotEmpty ? ' • Period: ${j.deliveryPeriod}' : ''}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: j.supplierStatus),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textLight),
                ],
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items to Produce', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),

                  ...j.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.image != null) ...[
                            AppNetworkImage(
                              url: item.image,
                              width: 50,
                              height: 50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.units}x ${item.productName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                if (item.options.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(item.options.join(' • '), style: AppTextStyles.caption),
                                ],
                                if (item.unitDetails.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  ...item.unitDetails.map((u) {
                                    return Text('• ${u.description}',
                                        style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic));
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  // Actions
                  if (widget.canAct) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (j.isAssigned) ...[
                          OutlinedButton.icon(
                            onPressed: () => _promptAction(context, 'start'),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Start Production'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (j.isAssigned || j.isInProduction) ...[
                          ElevatedButton.icon(
                            onPressed: () => _promptAction(context, 'pickup'),
                            icon: const Icon(Icons.local_shipping_outlined, size: 16),
                            label: const Text('Order Complete, Request Pickup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyan,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  if (j.isPickupRequested)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Pickup requested. Waiting for rider collection.',
                        style: TextStyle(color: AppColors.indigo, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _promptAction(BuildContext context, String action) {
    final isPickup = action == 'pickup';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isPickup ? 'Request Pickup?' : 'Start Production?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPickup
                    ? 'A delivery rider will be assigned to collect this completed batch.'
                    : 'Notify the admin that factory production has started on this order.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: isPickup ? 'e.g. 2 boxes, ready by 4 PM (optional)' : 'Production note (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onAction(action, noteController.text.trim());
              },
              child: Text(isPickup ? 'Request Pickup' : 'Start Now'),
            ),
          ],
        );
      },
    );
  }
}
