class WarehouseModel {
  final int id;
  final String name;
  final String code;
  final bool isPrimary;
  final bool isActive;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isPrimary,
    required this.isActive,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }
}
