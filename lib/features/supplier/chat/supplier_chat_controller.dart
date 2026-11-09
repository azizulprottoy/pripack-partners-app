import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../../chat/chat_repository.dart';

class SupplierChatController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final textController = TextEditingController();

  final messages = <ChatMessageModel>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    try {
      final list = await _chatRepo.getMyChat();
      messages.assignAll(list);
      _chatRepo.markMyChatRead();
    } catch (e, st) {
      AppLogger.error('SupplierChatController.loadMessages failed', e, st);
    }
    isLoading.value = false;
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    try {
      await _chatRepo.sendMyMessage(text);
      textController.clear();
      final list = await _chatRepo.getMyChat();
      messages.assignAll(list);
    } catch (e) {
      SnackMessage.error('Failed to send message.');
    } finally {
      isSending.value = false;
    }
  }
}
