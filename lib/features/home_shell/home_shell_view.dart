import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/theme/app_colors.dart';
import '../admin/chat/admin_chat_view.dart';
import '../admin/dashboard/admin_dashboard_view.dart';
import '../admin/orders/admin_seller_orders_view.dart';
import '../admin/partners/admin_partners_view.dart';
import '../admin/pricing/admin_pricing_view.dart';
import '../admin/profile/admin_profile_view.dart';
import '../seller/catalog/seller_catalog_view.dart';
import '../seller/chat/seller_chat_view.dart';
import '../seller/dashboard/seller_dashboard_view.dart';
import '../seller/orders/seller_orders_view.dart';
import '../seller/profile/seller_profile_view.dart';
import '../supplier/chat/supplier_chat_view.dart';
import '../supplier/jobs/supplier_jobs_view.dart';
import '../supplier/profile/supplier_profile_view.dart';
import 'home_shell_controller.dart';

class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Pripack ${controller.roleDisplayName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          body: Obx(() {
            final tab = controller.currentTabIndex.value;

            if (controller.isSeller) {
              return IndexedStack(
                index: tab,
                children: [
                  SellerDashboardView(onNavigateTab: controller.changeTab),
                  SellerCatalogView(onOrderPlaced: () => controller.changeTab(2)),
                  const SellerOrdersView(),
                  const SellerChatView(),
                  const SellerProfileView(),
                ],
              );
            } else if (controller.isSupplier) {
              return IndexedStack(
                index: tab,
                children: const [
                  SupplierJobsView(),
                  SupplierChatView(),
                  SupplierProfileView(),
                ],
              );
            } else {
              // Admin
              return IndexedStack(
                index: tab,
                children: const [
                  AdminDashboardView(),
                  AdminSellerOrdersView(),
                  AdminPartnersView(),
                  AdminPricingView(),
                  AdminChatView(),
                  AdminProfileView(),
                ],
              );
            }
          }),
          bottomNavigationBar: Obx(() {
            final tab = controller.currentTabIndex.value;

            if (controller.isSeller) {
              return BottomNavigationBar(
                currentIndex: tab,
                onTap: controller.changeTab,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_shopping_cart_outlined),
                    activeIcon: Icon(Icons.add_shopping_cart),
                    label: 'Catalog',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: 'My Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_outlined),
                    activeIcon: Icon(Icons.chat),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              );
            } else if (controller.isSupplier) {
              return BottomNavigationBar(
                currentIndex: tab,
                onTap: controller.changeTab,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.precision_manufacturing_outlined),
                    activeIcon: Icon(Icons.precision_manufacturing),
                    label: 'Production',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.support_agent_outlined),
                    activeIcon: Icon(Icons.support_agent),
                    label: 'Admin Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business_outlined),
                    activeIcon: Icon(Icons.business),
                    label: 'Factory',
                  ),
                ],
              );
            } else {
              // Admin Navigation
              return BottomNavigationBar(
                currentIndex: tab,
                onTap: controller.changeTab,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined),
                    activeIcon: Icon(Icons.analytics),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_outlined),
                    activeIcon: Icon(Icons.shopping_bag),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    activeIcon: Icon(Icons.people),
                    label: 'Partners',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.price_change_outlined),
                    activeIcon: Icon(Icons.price_change),
                    label: 'Pricing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.forum_outlined),
                    activeIcon: Icon(Icons.forum),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shield_outlined),
                    activeIcon: Icon(Icons.shield),
                    label: 'Admin',
                  ),
                ],
              );
            }
          }),
        );
      },
    );
  }
}
