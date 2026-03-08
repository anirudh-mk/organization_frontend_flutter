class MaterialCategoryModel {
  final int id;
  final String name;
  final String description;

  MaterialCategoryModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory MaterialCategoryModel.fromJson(Map<String, dynamic> json) {
    return MaterialCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class MaterialModel {
  final int id;
  final String name;
  final String code;
  final int? category;
  final String unit;
  final String description;
  final double basePrice;
  final bool isActive;

  MaterialModel({
    required this.id,
    required this.name,
    this.code = '',
    this.category,
    required this.unit,
    this.description = '',
    this.basePrice = 0.0,
    this.isActive = true,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'],
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['base_price'] != null ? double.tryParse(json['base_price'].toString()) ?? 0.0 : 0.0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'unit': unit,
      'description': description,
      'base_price': basePrice,
      'is_active': isActive,
    };
  }
}
