class DistrictModel {
  final String id;
  final String name;
  final String? nameBn;
  final String? divisionId;

  DistrictModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.divisionId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameBn: json['nameBn']?.toString(),
      divisionId: json['divisionId']?.toString(),
    );
  }
}
