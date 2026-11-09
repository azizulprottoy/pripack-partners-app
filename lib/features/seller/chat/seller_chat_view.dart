import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
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
      body: Column(
        children: [
          // Sub-tabs: Admin Chat vs Customer Inquiries
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              final tab = controller.activeTab.value;
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSubTab('Admin Support', 0, tab == 0),
                    ),
                    Expanded(
                      child: _buildSubTab('Customer Chats', 1, tab == 1),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Chat content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading messages...');
              }

              if (controller.activeTab.value == 0) {
                return _buildAdminChatArea();
              } else {
                return _buildCustomerConversationsArea();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab(String title, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminChatArea() {
    final msgs = controller.adminMessages;

    return Column(
      children: [
        Expanded(
          child: msgs.isEmpty
              ? const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No Messages Yet',
                  message: 'Send a message below to reach out directly to the Pripack admin team.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    final isFromAdmin = msg.isFromAdmin;

                    return Align(
                      alignment: isFromAdmin ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                        decoration: BoxDecoration(
                          color: isFromAdmin ? Colors.white : AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isFromAdmin ? 0 : 16),
                            bottomRight: Radius.circular(isFromAdmin ? 16 : 0),
                          ),
                          border: isFromAdmin ? Border.all(color: AppColors.border) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isFromAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Text(
                              isFromAdmin ? 'Admin' : 'You',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFromAdmin ? AppColors.indigo : Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: isFromAdmin ? AppColors.textDark : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatDateTime(msg.createdAt),
                              style: TextStyle(
                                fontSize: 9,
                                color: isFromAdmin ? AppColors.textLight : Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Chat Input Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message to Admin...',
                      fillColor: AppColors.inputBg,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: controller.sendAdminMessage,
                ),
              ],
            ),
          ),
        ),
      ],
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
