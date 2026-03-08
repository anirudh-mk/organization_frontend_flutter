class OrganizationTypeModel {
  final String id;
  final String name;
  final String code;

  OrganizationTypeModel({
    required this.id,
    required this.name,
    required this.code,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory OrganizationTypeModel.fromJson(Map<String, dynamic> json) {
    return OrganizationTypeModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class OrganizationModel {
  final String id;
  final String name;
  final String type;
  final bool isActive;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type']?.toString() ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_active': isActive,
    };
  }
}
