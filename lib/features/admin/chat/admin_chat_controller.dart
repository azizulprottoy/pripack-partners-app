import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../../chat/chat_repository.dart';

class AdminChatController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();

  final threads = <PartnerThreadModel>[].obs;
  final activeThread = Rx<PartnerThreadModel?>(null);
  final activeMessages = <ChatMessageModel>[].obs;

  final textController = TextEditingController();
  final isLoading = true.obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThreads();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> loadThreads() async {
    isLoading.value = true;
    try {
      final list = await _chatRepo.getAdminThreads();
      threads.assignAll(list);
    } catch (e, st) {
      AppLogger.error('AdminChatController.loadThreads failed', e, st);
    }
    isLoading.value = false;
  }

  Future<void> openThread(PartnerThreadModel thread) async {
    activeThread.value = thread;
    isLoadingMessages.value = true;
    try {
      final msgs = await _chatRepo.getThreadMessages(thread.type, thread.partnerId);
      activeMessages.assignAll(msgs);
    } catch (e, st) {
      AppLogger.error('AdminChatController.openThread failed', e, st);
    }
    isLoadingMessages.value = false;
  }

  Future<void> sendMessage() async {
    final thread = activeThread.value;
    final text = textController.text.trim();
    if (thread == null || text.isEmpty) return;

    isSending.value = true;
    try {
      await _chatRepo.sendMessageToPartner(thread.type, thread.partnerId, text);
      textController.clear();
      final msgs = await _chatRepo.getThreadMessages(thread.type, thread.partnerId);
      activeMessages.assignAll(msgs);
    } catch (e) {
      SnackMessage.error('Failed to send message.');
    } finally {
      isSending.value = false;
    }
  }

  void closeThread() {
    activeThread.value = null;
    activeMessages.clear();
  }
}
