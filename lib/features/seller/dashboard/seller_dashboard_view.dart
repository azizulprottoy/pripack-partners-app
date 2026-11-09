import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/status_badge.dart';
import 'seller_dashboard_controller.dart';

class SellerDashboardView extends GetView<SellerDashboardController> {
  final ValueChanged<int>? onNavigateTab;

  const SellerDashboardView({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingIndicator(message: 'Loading dashboard...');
      }

      final profile = controller.profile.value;

      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome & Status Banner
              if (profile != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.shopName.isNotEmpty ? profile.shopName : profile.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seller Partner • ${profile.phone}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: profile.status),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Active Orders',
                      value: '${controller.totalOrders}',
                      icon: Icons.shopping_bag_outlined,
                      accentColor: AppColors.indigo,
                      onTap: () => onNavigateTab?.call(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Pending Verif.',
                      value: '${controller.pendingOrders}',
                      icon: Icons.hourglass_top_outlined,
                      accentColor: AppColors.amber,
                      onTap: () => onNavigateTab?.call(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Profit Earned',
                      value: AppFormatters.taka(controller.profitEarned),
                      icon: Icons.check_circle_outline,
                      accentColor: AppColors.emerald,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Profit In Progress',
                      value: AppFormatters.taka(controller.profitInProgress),
                      icon: Icons.trending_up,
                      accentColor: AppColors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MetricCard(
                title: 'Unread Messages',
                value: '${controller.unreadMessagesCount}',
                icon: Icons.chat_bubble_outline,
                accentColor: controller.unreadMessagesCount > 0 ? AppColors.error : AppColors.textDark,
                subtitle: 'Customer & Admin inquiries',
                onTap: () => onNavigateTab?.call(3),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text('Quick Operations', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.add_shopping_cart,
                      title: 'Place Order',
                      subtitle: 'Browse catalog & client order',
                      color: AppColors.primary,
                      onTap: () => onNavigateTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Admin Chat',
                      subtitle: 'Direct help & custom jobs',
                      color: AppColors.indigo,
                      onTap: () => onNavigateTab?.call(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Orders', style: AppTextStyles.h3),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(2),
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (controller.recentOrders.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Yet',
                  message: 'Explore the wholesale catalog to place your first customer order.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = controller.recentOrders[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              StatusBadge(status: order.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${AppFormatters.formatDate(order.createdAt)} • ${order.isCustomerOrder ? (order.customer?.name ?? 'Customer') : 'For Myself'}',
                            style: AppTextStyles.bodyMuted,
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${order.items.length} item(s)',
                                style: AppTextStyles.caption,
                              ),
                              if (order.isCustomerOrder)
                                Text(
                                  'Profit: ${AppFormatters.taka(order.totals.profit)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: order.totals.profit >= 0 ? AppColors.emerald : AppColors.error,
                                  ),
                                ),
                              Text(
                                'Total: ${AppFormatters.taka(order.isCustomerOrder ? order.totals.selling : order.totals.cost)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
