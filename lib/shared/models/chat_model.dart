class ChatMessageModel {
  final String id;
  final String sender; // 'admin' | 'partner' | 'seller' | 'supplier' | 'user'
  final String text;
  final String? attachment;
  final bool readByPartner;
  final bool readByAdmin;
  final dynamic createdAt;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.attachment,
    this.readByPartner = false,
    this.readByAdmin = false,
    this.createdAt,
  });

  bool get isFromAdmin => sender == 'admin';
  bool get isFromMe => !isFromAdmin;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      text: json['text']?.toString() ?? json['message']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      readByPartner: json['readByPartner'] == true,
      readByAdmin: json['readByAdmin'] == true,
      createdAt: json['createdAt'] ?? json['date'],
    );
  }
}

class PartnerThreadModel {
  final String id;
  final String type; // 'seller' | 'supplier'
  final String partnerId;
  final String partnerName;
  final String shopName;
  final int unreadCount;
  final String lastMessage;
  final dynamic lastTime;

  PartnerThreadModel({
    required this.id,
    required this.type,
    required this.partnerId,
    required this.partnerName,
    required this.shopName,
    this.unreadCount = 0,
    required this.lastMessage,
    this.lastTime,
  });

  factory PartnerThreadModel.fromJson(Map<String, dynamic> json) {
    return PartnerThreadModel(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'seller',
      partnerId: json['partnerId']?.toString() ?? json['_id']?.toString() ?? '',
      partnerName: json['partnerName']?.toString() ?? json['name']?.toString() ?? 'Partner',
      shopName: json['shopName']?.toString() ?? '',
      unreadCount: int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastTime: json['lastTime'] ?? json['updatedAt'],
    );
  }
}

class SellerCustomerConversationModel {
  final String id;
  final String customerName;
  final String lastMessage;
  final int unreadCount;
  final dynamic lastTime;

  SellerCustomerConversationModel({
    required this.id,
    required this.customerName,
    required this.lastMessage,
    this.unreadCount = 0,
    this.lastTime,
  });

  factory SellerCustomerConversationModel.fromJson(Map<String, dynamic> json) {
    return SellerCustomerConversationModel(
      id: json['_id']?.toString() ?? json['supportId']?.toString() ?? '',
      customerName: json['bName']?.toString() ?? json['customerName']?.toString() ?? 'Customer',
      lastMessage: json['lastMessage']?.toString() ?? '',
      unreadCount: int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      lastTime: json['lastTime'] ?? json['time'],
    );
  }
}
