import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'supplier_chat_controller.dart';

class SupplierChatView extends GetView<SupplierChatController> {
  const SupplierChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading chat...');
              }

              final msgs = controller.messages;
              if (msgs.isEmpty) {
                return const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Admin Support Chat',
                  message: 'Communicate with Pripack operations team regarding order specifications and pickup scheduling.',
                );
              }

              return ListView.builder(
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
                            isFromAdmin ? 'Pripack Admin' : 'You (Supplier)',
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
              );
            }),
          ),

          // Message Input
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
                    onPressed: controller.sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
