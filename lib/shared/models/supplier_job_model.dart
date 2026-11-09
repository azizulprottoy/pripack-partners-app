class JobUnitDetail {
  final String description;
  final String? filePath;

  JobUnitDetail({required this.description, this.filePath});

  factory JobUnitDetail.fromJson(Map<String, dynamic> json) {
    return JobUnitDetail(
      description: json['description']?.toString() ?? '',
      filePath: json['filePath']?.toString(),
    );
  }
}

class JobItemModel {
  final String productName;
  final int units;
  final List<String> options;
  final String? image;
  final List<JobUnitDetail> unitDetails;

  JobItemModel({
    required this.productName,
    required this.units,
    this.options = const [],
    this.image,
    this.unitDetails = const [],
  });

  factory JobItemModel.fromJson(Map<String, dynamic> json) {
    return JobItemModel(
      productName: json['productName']?.toString() ?? 'Product',
      units: int.tryParse(json['units']?.toString() ?? '1') ?? 1,
      options: (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
      image: json['image']?.toString(),
      unitDetails: (json['unitDetails'] as List? ?? [])
          .map((e) => JobUnitDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SupplierJobModel {
  final String id;
  final String type; // 'customer' | 'seller'
  final String referenceCode;
  final dynamic date;
  final String? deliveryPeriod;
  final String supplierStatus;
  final String? supplierNote;
  final List<Map<String, dynamic>> supplierHistory;
  final List<JobItemModel> items;

  SupplierJobModel({
    required this.id,
    required this.type,
    required this.referenceCode,
    this.date,
    this.deliveryPeriod,
    required this.supplierStatus,
    this.supplierNote,
    this.supplierHistory = const [],
    this.items = const [],
  });

  bool get isAssigned => supplierStatus == 'Assigned';
  bool get isInProduction => supplierStatus == 'In Production';
  bool get isPickupRequested => supplierStatus == 'Pickup Requested';
  bool get isPickedUp => supplierStatus == 'Picked Up';

  bool get canStart => isAssigned;
  bool get canRequestPickup => isAssigned || isInProduction;

  factory SupplierJobModel.fromJson(Map<String, dynamic> json) {
    return SupplierJobModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'customer',
      referenceCode: json['referenceCode']?.toString() ?? '',
      date: json['date'],
      deliveryPeriod: json['deliveryPeriod']?.toString(),
      supplierStatus: json['supplierStatus']?.toString() ?? 'Assigned',
      supplierNote: json['supplierNote']?.toString(),
      supplierHistory: (json['supplierHistory'] as List? ?? [])
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList(),
      items: (json['items'] as List? ?? [])
          .map((e) => JobItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
