import 'package:get/get.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/models/seller_order_model.dart';
import '../../chat/chat_repository.dart';
import '../seller_repository.dart';

class SellerDashboardController extends GetxController {
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();
  final ChatRepository _chatRepo = Get.find<ChatRepository>();
  final SessionStorage _session = Get.find<SessionStorage>();

  final profile = Rx<PartnerModel?>(null);
  final orders = <SellerOrderModel>[].obs;
  final conversations = <SellerCustomerConversationModel>[].obs;
  final adminMessages = <ChatMessageModel>[].obs;

  final isLoading = true.obs;

  int get totalOrders => orders.where((o) => o.status != AppConstants.orderCancelled).length;
  int get pendingOrders => orders.where((o) => o.status == AppConstants.orderPending).length;

  num get profitEarned => orders
      .where((o) => o.status == AppConstants.orderDelivered)
      .fold<num>(0, (sum, o) => sum + o.totals.profit);

  num get profitInProgress => orders
      .where((o) => o.status != AppConstants.orderDelivered && o.status != AppConstants.orderCancelled)
      .fold<num>(0, (sum, o) => sum + o.totals.profit);

  int get unreadMessagesCount =>
      conversations.fold<int>(0, (sum, c) => sum + c.unreadCount) +
      adminMessages.where((m) => m.isFromAdmin && !m.readByPartner).length;

  List<SellerOrderModel> get recentOrders => orders.take(5).toList();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final p = await _sellerRepo.getProfile();
      profile.value = p;

      final oList = await _sellerRepo.getMyOrders();
      orders.assignAll(oList);

      final sellerId = _session.user?['userId']?.toString() ?? _session.user?['_id']?.toString() ?? '';
      if (sellerId.isNotEmpty) {
        final convList = await _sellerRepo.getCustomerConversations(sellerId);
        conversations.assignAll(convList);
      }

      final aMsgs = await _chatRepo.getMyChat();
      adminMessages.assignAll(aMsgs);
    } catch (e, st) {
      AppLogger.error('SellerDashboardController.loadDashboard failed', e, st);
    }
    isLoading.value = false;
  }
}
