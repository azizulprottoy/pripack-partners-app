class PartnerModel {
  final String id;
  final String name;
  final String shopName;
  final String email;
  final String phone;
  final String address;
  final String? district;
  final List<String> categories;
  final String status;
  final String? statusNote;
  final String? shopPic;
  final String? nidFront;
  final String? nidBack;
  final dynamic createdAt;

  PartnerModel({
    required this.id,
    required this.name,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.address,
    this.district,
    this.categories = const [],
    required this.status,
    this.statusNote,
    this.shopPic,
    this.nidFront,
    this.nidBack,
    this.createdAt,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isSuspended => status == 'suspended';

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      district: json['district']?.toString(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      status: json['status']?.toString() ?? 'pending',
      statusNote: json['statusNote']?.toString(),
      shopPic: json['shopPic']?.toString(),
      nidFront: json['nidFront']?.toString(),
      nidBack: json['nidBack']?.toString(),
      createdAt: json['createdAt'],
    );
  }
}
