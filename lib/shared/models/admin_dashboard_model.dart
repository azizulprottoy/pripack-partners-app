class TopProductModel {
  final String id;
  final String productName;
  final String category;
  final int viewCount;
  final String? mainPic;

  TopProductModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.viewCount,
    this.mainPic,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      id: json['_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      viewCount: int.tryParse(json['viewCount']?.toString() ?? '0') ?? 0,
      mainPic: json['mainPic']?.toString(),
    );
  }
}

class AdminDashboardModel {
  final int totalProducts;
  final int totalOrders;
  final int totalCustomers;
  final int totalReviews;
  final num totalIncome;
  final num totalExpense;
  final num netProfit;
  final Map<String, int> orderStatusMap;
  final List<TopProductModel> topViewedProducts;
  final List<dynamic> recentOrders;

  AdminDashboardModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalReviews,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.orderStatusMap,
    this.topViewedProducts = const [],
    this.recentOrders = const [],
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, int>{};
    if (json['orderStatusMap'] is Map) {
      (json['orderStatusMap'] as Map).forEach((key, val) {
        statusMap[key.toString()] = int.tryParse(val.toString()) ?? 0;
      });
    }

    return AdminDashboardModel(
      totalProducts: int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0,
      totalOrders: int.tryParse(json['totalOrders']?.toString() ?? '0') ?? 0,
      totalCustomers: int.tryParse(json['totalCustomers']?.toString() ?? '0') ?? 0,
      totalReviews: int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      totalIncome: num.tryParse(json['totalIncome']?.toString() ?? '0') ?? 0,
      totalExpense: num.tryParse(json['totalExpense']?.toString() ?? '0') ?? 0,
      netProfit: num.tryParse(json['netProfit']?.toString() ?? '0') ?? 0,
      orderStatusMap: statusMap,
      topViewedProducts: (json['topViewedProducts'] as List? ?? [])
          .map((e) => TopProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentOrders: json['recentOrders'] as List? ?? [],
    );
  }
}
