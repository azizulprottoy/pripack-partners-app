import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../../chat/chat_repository.dart';
import '../seller_repository.dart';

class SellerChatController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();
  final SessionStorage _session = Get.find<SessionStorage>();

  final textController = TextEditingController();
  final adminMessages = <ChatMessageModel>[].obs;
  final customerConversations = <SellerCustomerConversationModel>[].obs;

  final activeTab = 0.obs; // 0 = Admin Chat, 1 = Customer Inquiries
  final isLoading = true.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> loadChats() async {
    isLoading.value = true;
    try {
      final msgs = await _chatRepo.getMyChat();
      adminMessages.assignAll(msgs);
      _chatRepo.markMyChatRead();

      final sellerId = _session.user?['userId']?.toString() ?? _session.user?['_id']?.toString() ?? '';
      if (sellerId.isNotEmpty) {
        final convs = await _sellerRepo.getCustomerConversations(sellerId);
        customerConversations.assignAll(convs);
      }
    } catch (e, st) {
      AppLogger.error('SellerChatController.loadChats failed', e, st);
    }
    isLoading.value = false;
  }

  Future<void> sendAdminMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    try {
      await _chatRepo.sendMyMessage(text);
      textController.clear();
      final msgs = await _chatRepo.getMyChat();
      adminMessages.assignAll(msgs);
    } catch (e) {
      SnackMessage.error('Failed to send message.');
    } finally {
      isSending.value = false;
    }
  }
}
