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
import 'seller_orders_controller.dart';

class SellerOrdersView extends GetView<SellerOrdersController> {
  const SellerOrdersView({super.key});

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
          // Filter Chips Rail
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
                return const LoadingIndicator(message: 'Loading your orders...');
              }

              final list = controller.filteredOrders;
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Found',
                  message: 'No orders match the selected filter.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchOrders,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = list[index];
                    return _OrderCard(
                      order: order,
                      onTap: () => _showOrderDetail(context, order),
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

  void _showOrderDetail(BuildContext context, SellerOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final SellerOrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

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
                Text(
                  '#${order.referenceCode}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${AppFormatters.formatDateTime(order.createdAt)} • ${order.isCustomerOrder ? (order.customer?.name ?? 'Customer') : 'For Myself'}',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Items Summary
            Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.units}x ${item.productName} (${item.variantLabel})',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AppFormatters.taka(order.isCustomerOrder ? item.selling : item.cost),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.isCustomerOrder)
                  Text(
                    'Profit: ${AppFormatters.taka(order.totals.profit)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: order.totals.profit >= 0 ? AppColors.emerald : AppColors.error,
                    ),
                  )
                else
                  Text(
                    'Wholesale: ${AppFormatters.taka(order.totals.cost)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                Text(
                  'Total: ${AppFormatters.taka(order.isCustomerOrder ? order.totals.selling : order.totals.cost)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final SellerOrderModel order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
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
                        Text('Order #${order.referenceCode}', style: AppTextStyles.h2),
                        Text(AppFormatters.formatDateTime(order.createdAt), style: AppTextStyles.caption),
                      ],
                    ),
                    StatusBadge(status: order.status),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Customer Details
                    if (order.isCustomerOrder && order.customer != null) ...[
                      const Text('Customer Details', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.customer!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(order.customer!.phone, style: AppTextStyles.bodyMuted),
                            const SizedBox(height: 4),
                            Text(order.customer!.address, style: AppTextStyles.bodyMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Items breakdown
                    const Text('Products', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.productName} • ${item.variantLabel}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.units} units @ ${AppFormatters.taka(item.sellerPrice)}',
                                      style: AppTextStyles.caption),
                                  Text('Cost: ${AppFormatters.taka(item.cost)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              if (order.isCustomerOrder) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Selling: ${AppFormatters.taka(item.selling)}',
                                        style: AppTextStyles.caption),
                                    Text('Profit: ${AppFormatters.taka(item.profit)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: item.profit >= 0 ? AppColors.emerald : AppColors.error)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Financial totals
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Wholesale (Your Cost)'),
                              Text(AppFormatters.taka(order.totals.cost),
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (order.isCustomerOrder) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Customer Total'),
                                Text(AppFormatters.taka(order.totals.selling),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Net Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  AppFormatters.taka(order.totals.profit),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: order.totals.profit >= 0 ? AppColors.emerald : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Timeline History
                    if (order.statusHistory.isNotEmpty) ...[
                      const Text('Status Timeline', style: AppTextStyles.h3),
                      const SizedBox(height: 10),
                      ...order.statusHistory.map((h) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle, size: 10, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(h.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    if (h.note != null && h.note!.isNotEmpty)
                                      Text(h.note!, style: AppTextStyles.caption),
                                    Text(AppFormatters.formatDateTime(h.date),
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
