import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/metric_card.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading admin dashboard...');
        }

        final d = controller.dashboard.value;
        if (d == null) {
          return const Center(child: Text('Dashboard data unavailable'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Financial Overview
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NET PLATFORM PROFIT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.taka(d.netProfit),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Revenue', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(AppFormatters.taka(d.totalIncome),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Expenses', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(AppFormatters.taka(d.totalExpense),
                                  style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Operational KPI grid
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Total Orders',
                        value: '${d.totalOrders}',
                        icon: Icons.shopping_bag_outlined,
                        accentColor: AppColors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Products',
                        value: '${d.totalProducts}',
                        icon: Icons.inventory_2_outlined,
                        accentColor: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Customers',
                        value: '${d.totalCustomers}',
                        icon: Icons.people_outline,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Reviews',
                        value: '${d.totalReviews}',
                        icon: Icons.star_outline,
                        accentColor: AppColors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Order Status Distribution
                const Text('Order Pipeline', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: d.orderStatusMap.entries.map((e) {
                    final color = AppFormatters.getStatusColor(e.key);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${e.value}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Top Products
                if (d.topViewedProducts.isNotEmpty) ...[
                  const Text('Top Performing Products', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: d.topViewedProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = d.topViewedProducts[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Text('#${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(p.category, style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Text(
                              '${p.viewCount} views',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigo),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
