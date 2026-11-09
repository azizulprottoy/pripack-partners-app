class ProductVariant {
  final String label;
  final num retailPrice;
  final num? sellerPrice;
  final Map<String, dynamic> combination;

  ProductVariant({
    required this.label,
    required this.retailPrice,
    this.sellerPrice,
    this.combination = const {},
  });

  bool get hasSellerPrice => sellerPrice != null && sellerPrice! > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      label: json['label']?.toString() ?? 'Standard',
      retailPrice: num.tryParse(json['retailPrice']?.toString() ?? '') ??
          num.tryParse(json['price']?.toString() ?? '') ??
          0,
      sellerPrice: num.tryParse(json['sellerPrice']?.toString() ?? ''),
      combination: json['combination'] is Map<String, dynamic>
          ? json['combination'] as Map<String, dynamic>
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'retailPrice': retailPrice,
        'sellerPrice': sellerPrice,
        'combination': combination,
      };
}

class CatalogProductModel {
  final String id;
  final String productName;
  final String? productNameBn;
  final String category;
  final String? subCategory;
  final String? deliveryTime;
  final String? image;
  final List<ProductVariant> variants;

  CatalogProductModel({
    required this.id,
    required this.productName,
    this.productNameBn,
    required this.category,
    this.subCategory,
    this.deliveryTime,
    this.image,
    this.variants = const [],
  });

  List<ProductVariant> get orderableVariants =>
      variants.where((v) => v.hasSellerPrice).toList();

  factory CatalogProductModel.fromJson(Map<String, dynamic> json) {
    return CatalogProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productNameBn: json['productNameBn']?.toString(),
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString(),
      deliveryTime: json['deliveryTime']?.toString(),
      image: json['image']?.toString() ??
          (json['mainPics'] is List && (json['mainPics'] as List).isNotEmpty
              ? json['mainPics'][0]?.toString()
              : null),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
