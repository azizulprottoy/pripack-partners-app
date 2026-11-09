class OrderItemModel {
  final String productId;
  final String productName;
  final String variantLabel;
  final String? image;
  final int units;
  final num sellerPrice;
  final num sellingPrice;
  final num cost;
  final num selling;
  final num profit;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.variantLabel,
    this.image,
    required this.units,
    required this.sellerPrice,
    required this.sellingPrice,
    required this.cost,
    required this.selling,
    required this.profit,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Product',
      variantLabel: json['variantLabel']?.toString() ?? '',
      image: json['image']?.toString(),
      units: int.tryParse(json['units']?.toString() ?? '1') ?? 1,
      sellerPrice: num.tryParse(json['sellerPrice']?.toString() ?? '0') ?? 0,
      sellingPrice: num.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0,
      cost: num.tryParse(json['cost']?.toString() ?? '0') ?? 0,
      selling: num.tryParse(json['selling']?.toString() ?? '0') ?? 0,
      profit: num.tryParse(json['profit']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'variantLabel': variantLabel,
        'units': units,
        'sellingPrice': sellingPrice,
      };
}

class OrderCustomerInfo {
  final String name;
  final String phone;
  final String address;

  OrderCustomerInfo({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory OrderCustomerInfo.fromJson(Map<String, dynamic> json) {
    return OrderCustomerInfo(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
      };
}

class OrderTotals {
  final num cost;
  final num selling;
  final num profit;
  final int units;

  OrderTotals({
    required this.cost,
    required this.selling,
    required this.profit,
    required this.units,
  });

  factory OrderTotals.fromJson(Map<String, dynamic> json) {
    return OrderTotals(
      cost: num.tryParse(json['cost']?.toString() ?? '0') ?? 0,
      selling: num.tryParse(json['selling']?.toString() ?? '0') ?? 0,
      profit: num.tryParse(json['profit']?.toString() ?? '0') ?? 0,
      units: int.tryParse(json['units']?.toString() ?? '0') ?? 0,
    );
  }
}

class StatusHistoryItem {
  final String status;
  final String? note;
  final dynamic date;

  StatusHistoryItem({
    required this.status,
    this.note,
    this.date,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      date: json['date'],
    );
  }
}

class SellerOrderModel {
  final String id;
  final String referenceCode;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String orderFor; // 'customer' | 'self'
  final OrderCustomerInfo? customer;
  final List<OrderItemModel> items;
  final OrderTotals totals;
  final String status;
  final String? supplierStatus;
  final Map<String, dynamic>? supplier;
  final String? note;
  final List<StatusHistoryItem> statusHistory;
  final dynamic createdAt;

  SellerOrderModel({
    required this.id,
    required this.referenceCode,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    required this.orderFor,
    this.customer,
    this.items = const [],
    required this.totals,
    required this.status,
    this.supplierStatus,
    this.supplier,
    this.note,
    this.statusHistory = const [],
    this.createdAt,
  });

  bool get isCustomerOrder => orderFor == 'customer';
  bool get isSelfOrder => orderFor == 'self';
  bool get canCancel => status == 'Pending Verification';

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      referenceCode: json['referenceCode']?.toString() ?? '',
      sellerId: json['sellerId']?.toString(),
      sellerName: json['sellerName']?.toString(),
      sellerPhone: json['sellerPhone']?.toString(),
      orderFor: json['orderFor']?.toString() ?? 'customer',
      customer: json['customer'] is Map<String, dynamic>
          ? OrderCustomerInfo.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: json['totals'] is Map<String, dynamic>
          ? OrderTotals.fromJson(json['totals'] as Map<String, dynamic>)
          : OrderTotals(cost: 0, selling: 0, profit: 0, units: 0),
      status: json['status']?.toString() ?? 'Pending Verification',
      supplierStatus: json['supplierStatus']?.toString(),
      supplier: json['supplier'] is Map<String, dynamic>
          ? json['supplier'] as Map<String, dynamic>
          : null,
      note: json['note']?.toString(),
      statusHistory: (json['statusHistory'] as List? ?? [])
          .map((e) => StatusHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'],
    );
  }
}
