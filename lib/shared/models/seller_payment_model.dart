class PaymentMethodModel {
  final String id;
  final String method;
  final String number;
  final String? extraDetails;

  PaymentMethodModel({required this.id, required this.method, required this.number, this.extraDetails});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      extraDetails: json['extradetails']?.toString(),
    );
  }
}

class SellerDueOrderModel {
  final String id;
  final String referenceCode;
  final num cost;
  final dynamic createdAt;

  SellerDueOrderModel({
    required this.id,
    required this.referenceCode,
    required this.cost,
    this.createdAt,
  });

  factory SellerDueOrderModel.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>?;
    return SellerDueOrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      referenceCode: json['referenceCode']?.toString() ?? '',
      cost: num.tryParse(totals?['cost']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'],
    );
  }
}

class SellerPaymentDue {
  final num due;
  final List<SellerDueOrderModel> orders;

  SellerPaymentDue({required this.due, required this.orders});
}

class SellerPaymentModel {
  final String id;
  final num amount;
  final String method;
  final String paymentNumber;
  final String transactionId;
  final String status; // 'Pending Verification' | 'Verified' | 'Rejected'
  final String? note;
  final String? sellerName;
  final String? shopName;
  final String? sellerPhone;
  final dynamic createdAt;
  final dynamic verifiedAt;

  SellerPaymentModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.paymentNumber,
    required this.transactionId,
    required this.status,
    this.note,
    this.sellerName,
    this.shopName,
    this.sellerPhone,
    this.createdAt,
    this.verifiedAt,
  });

  bool get isPending => status == 'Pending Verification';
  bool get isVerified => status == 'Verified';
  bool get isRejected => status == 'Rejected';

  factory SellerPaymentModel.fromJson(Map<String, dynamic> json) {
    return SellerPaymentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: num.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      method: json['method']?.toString() ?? '',
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending Verification',
      note: json['note']?.toString(),
      sellerName: json['sellerName']?.toString(),
      shopName: json['shopName']?.toString(),
      sellerPhone: json['sellerPhone']?.toString(),
      createdAt: json['createdAt'],
      verifiedAt: json['verifiedAt'],
    );
  }
}
