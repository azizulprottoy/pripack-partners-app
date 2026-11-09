import 'package:get/get.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/chat_model.dart';

class ChatRepository extends GetxService {
  final DioClient _dio = Get.find<DioClient>();

  // ── Seller / Supplier side ─────────────────────────────
  Future<List<ChatMessageModel>> getMyChat() async {
    final res = await _dio.get(ApiEndpoints.partnerChat);
    final data = res.data as Map<String, dynamic>;
    final list = data['messages'] as List? ?? [];
    return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMyMessage(String text, {String? attachment}) async {
    final body = <String, dynamic>{'text': text};
    if (attachment != null) body['attachment'] = attachment;
    await _dio.post(ApiEndpoints.partnerChat, data: body);
  }

  Future<void> markMyChatRead() async {
    try {
      await _dio.post(ApiEndpoints.partnerChatRead, data: {});
    } catch (e, st) {
      AppLogger.error('ChatRepository.markMyChatRead failed', e, st);
    }
  }

  // ── Admin side ─────────────────────────────────────────
  Future<List<PartnerThreadModel>> getAdminThreads() async {
    final res = await _dio.get(ApiEndpoints.adminPartnerChats);
    final data = res.data as Map<String, dynamic>;
    final list = data['threads'] as List? ?? [];
    return list.map((e) => PartnerThreadModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChatMessageModel>> getThreadMessages(String type, String partnerId) async {
    final res = await _dio.get('${ApiEndpoints.adminPartnerChatThread}/$type/$partnerId');
    final data = res.data as Map<String, dynamic>;
    final list = data['messages'] as List? ?? [];
    return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessageToPartner(String type, String partnerId, String text) async {
    await _dio.post(
      '${ApiEndpoints.adminPartnerChatThread}/$type/$partnerId',
      data: {'text': text},
    );
  }
}
