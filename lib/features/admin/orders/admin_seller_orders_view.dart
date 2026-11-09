import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/seller_order_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import 'admin_seller_orders_controller.dart';

class AdminSellerOrdersView extends GetView<AdminSellerOrdersController> {
  const AdminSellerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      'All',
      AppConstants.orderPending,
      AppConstants.orderTransferred,
      AppConstants.orderDelivered,
      AppConstants.orderCancelled,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 38,
              child: Obx(() {
                final selectedStatus = controller.filterStatus.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = filterOptions[index];
                    final isSelected = selectedStatus == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) => controller.setFilter(status),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.inputBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    );
                  },
                );
              }),
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading seller orders...');
              }

              final list = controller.filteredOrders;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders',
                  message: 'No seller orders match the filter.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = list[index];
                    return _AdminOrderCard(
                      order: order,
                      onTap: () => _showOrderActions(context, order),
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

  void _showOrderActions(BuildContext context, SellerOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminOrderActionSheet(
        order: order,
        controller: controller,
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final SellerOrderModel order;
  final VoidCallback onTap;

  const _AdminOrderCard({required this.order, required this.onTap});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.referenceCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Seller: ${order.sellerName ?? 'Seller'} (${order.sellerPhone ?? ''})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 2),
            Text(
              '${AppFormatters.formatDateTime(order.createdAt)} • ${order.isCustomerOrder ? 'For Customer: ${order.customer?.name}' : 'For Self'}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} item(s)', style: AppTextStyles.caption),
                if (order.supplier != null)
                  Text(
                    'Supplier: ${order.supplier?['name']}',
                    style: const TextStyle(fontSize: 12, color: AppColors.indigo, fontWeight: FontWeight.bold),
                  ),
                Text(
                  'Wholesale: ${AppFormatters.taka(order.totals.cost)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderActionSheet extends StatefulWidget {
  final SellerOrderModel order;
  final AdminSellerOrdersController controller;

  const _AdminOrderActionSheet({required this.order, required this.controller});

  @override
  State<_AdminOrderActionSheet> createState() => _AdminOrderActionSheetState();
}

class _AdminOrderActionSheetState extends State<_AdminOrderActionSheet> {
  String? selectedSupplierId;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSupplierId = widget.order.supplier?['_id']?.toString();
    final approved = widget.controller.approvedSuppliers;
    if (selectedSupplierId == null && approved.isNotEmpty) {
      selectedSupplierId = approved.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final approvedSuppliers = widget.controller.approvedSuppliers;

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage Order #${o.referenceCode}', style: AppTextStyles.h2),
                        Text('Seller: ${o.sellerName ?? 'Seller'}', style: AppTextStyles.caption),
                      ],
                    ),
                    StatusBadge(status: o.status),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Items details
                    const Text('Order Items', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    ...o.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.units}x ${item.productName} (${item.variantLabel})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(AppFormatters.taka(item.cost), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Admin Action Box: Transfer to Supplier
                    if (o.status == AppConstants.orderPending || o.status == AppConstants.orderTransferred) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.indigo.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transfer / Assign to Supplier',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.indigo),
                            ),
                            const SizedBox(height: 10),
                            const Text('Select Supplier Factory:', style: AppTextStyles.caption),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedSupplierId,
                                  hint: const Text('Choose approved supplier'),
                                  items: approvedSuppliers.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s.id,
                                      child: Text('${s.shopName.isNotEmpty ? s.shopName : s.name} (${s.district ?? ''})'),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => selectedSupplierId = val),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                hintText: 'Production instructions note (optional)...',
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: selectedSupplierId == null
                                  ? null
                                  : () async {
                                      final ok = await widget.controller.updateOrder(
                                        orderId: o.id,
                                        action: 'transfer',
                                        supplierId: selectedSupplierId,
                                        note: noteController.text.trim(),
                                      );
                                      if (ok) Get.back();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.indigo,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                              ),
                              child: const Text('Verify & Assign to Supplier'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Mark Picked Up
                    if (o.status == AppConstants.orderTransferred &&
                        o.supplierStatus == AppConstants.jobPickupRequested) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await widget.controller.updateOrder(orderId: o.id, action: 'pickedup');
                          if (ok) Get.back();
                        },
                        icon: const Icon(Icons.airport_shuttle_outlined),
                        label: const Text('Confirm Rider Picked Up from Supplier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Mark Delivered
                    if (o.status == AppConstants.orderTransferred) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await widget.controller.updateOrder(orderId: o.id, action: 'deliver');
                          if (ok) Get.back();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark Order as Delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Cancel Order
                    if (o.status != AppConstants.orderDelivered && o.status != AppConstants.orderCancelled) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await widget.controller.updateOrder(orderId: o.id, action: 'cancel');
                          if (ok) Get.back();
                        },
                        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                        label: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
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
