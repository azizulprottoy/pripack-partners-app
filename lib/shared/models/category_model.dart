class CategoryModel {
  final String id;
  final String name;
  final String? nameBn;
  final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['catname']?.toString() ?? json['category']?.toString() ?? json['name']?.toString() ?? '',
      nameBn: json['catnameBn']?.toString() ?? json['nameBn']?.toString(),
      image: json['iconpic']?.toString() ?? json['catPic']?.toString() ?? json['image']?.toString(),
    );
  }
}
