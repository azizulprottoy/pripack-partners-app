class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? atype; // 'seller', 'supplier', 'customer'
  final String? role;  // for admin/staff
  final String? shopName;
  final String? status; // 'pending', 'approved', 'rejected', 'suspended'
  final List<String> categories;
  final List<String> tabs; // for admin permissions

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.atype,
    this.role,
    this.shopName,
    this.status,
    this.categories = const [],
    this.tabs = const [],
  });

  bool get isSeller => atype == 'seller';
  bool get isSupplier => atype == 'supplier';
  bool get isAdmin => role != null || (atype != 'seller' && atype != 'supplier');
  bool get isApproved => status?.toLowerCase() == 'approved';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ??
          json['userId']?.toString() ??
          json['_id']?.toString() ??
          '',
      name: json['name']?.toString() ?? json['remail']?.toString() ?? '',
      email: json['email']?.toString() ?? json['remail']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      atype: json['atype']?.toString(),
      role: json['role']?.toString(),
      shopName: json['shopName']?.toString(),
      status: json['status']?.toString(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      tabs: (json['tabs'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'atype': atype,
        'role': role,
        'shopName': shopName,
        'status': status,
        'categories': categories,
        'tabs': tabs,
      };
}
