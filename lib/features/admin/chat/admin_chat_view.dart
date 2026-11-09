import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'admin_chat_controller.dart';

class AdminChatView extends GetView<AdminChatController> {
  const AdminChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading partner chats...');
        }

        // If a thread is opened, show conversation screen
        if (controller.activeThread.value != null) {
          return _buildConversationView(context, controller.activeThread.value!);
        }

        // Threads list
        final list = controller.threads;
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No Partner Conversations',
            message: 'Messages from sellers and suppliers will be listed here.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadThreads,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final thread = list[index];
              return InkWell(
                onTap: () => controller.openThread(thread),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: thread.type == 'seller'
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.cyan.withValues(alpha: 0.1),
                        child: Icon(
                          thread.type == 'seller' ? Icons.storefront : Icons.factory_outlined,
                          color: thread.type == 'seller' ? AppColors.primary : AppColors.cyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  thread.shopName.isNotEmpty ? thread.shopName : thread.partnerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    thread.type.toUpperCase(),
                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              thread.lastMessage,
                              style: AppTextStyles.bodyMuted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildConversationView(BuildContext context, PartnerThreadModel thread) {
    return Column(
      children: [
        // Top bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: controller.closeThread,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.shopName.isNotEmpty ? thread.shopName : thread.partnerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text('${thread.type.toUpperCase()} • ${thread.partnerName}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Messages list
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMessages.value) {
              return const LoadingIndicator(message: 'Loading conversation...');
            }

            final msgs = controller.activeMessages;
            if (msgs.isEmpty) {
              return const EmptyState(
                icon: Icons.chat_bubble_outline,
                title: 'No Messages',
                message: 'Send a message below to reach this partner.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (context, index) {
                final msg = msgs[index];
                final isMe = msg.isFromAdmin; // Admin sent this

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.indigo : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                      border: !isMe ? Border.all(color: AppColors.border) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMe ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatDateTime(msg.createdAt),
                          style: TextStyle(
                            fontSize: 9,
                            color: isMe ? Colors.white70 : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Chat Input
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
                      hintText: 'Type your message to partner...',
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
                  icon: const Icon(Icons.send_rounded, color: AppColors.indigo),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
