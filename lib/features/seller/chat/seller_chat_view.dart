import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'seller_chat_controller.dart';

class SellerChatView extends GetView<SellerChatController> {
  const SellerChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading messages...');
        }
        return _buildCustomerConversationsArea();
      }),
    );
  }

  Widget _buildCustomerConversationsArea() {
    final convs = controller.customerConversations;

    if (convs.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No Customer Inquiries',
        message: 'Customer questions from your catalog listings will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: convs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final conv = convs[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  conv.customerName.isNotEmpty ? conv.customerName[0].toUpperCase() : 'C',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conv.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(
                      conv.lastMessage,
                      style: AppTextStyles.bodyMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (conv.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${conv.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
