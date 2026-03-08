class OrganizationTypeModel {
  final String id;
  final String name;

  OrganizationTypeModel({
    required this.id,
    required this.name,
  });

  factory OrganizationTypeModel.fromJson(Map<String, dynamic> json) {
    return OrganizationTypeModel(
      id: json['id'].toString(),
      name: json['name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CountryModel {
  final String id;
  final String name;
  final String code;

  CountryModel({required this.id, required this.name, required this.code});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'] ?? '',
    );
  }
}

class StateModel {
  final String id;
  final String name;
  final String countryId;

  StateModel({required this.id, required this.name, required this.countryId});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'].toString(),
      name: json['name'],
      countryId: json['country'].toString(),
    );
  }
}

class DistrictModel {
  final String id;
  final String name;
  final String stateId;

  DistrictModel({required this.id, required this.name, required this.stateId});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'].toString(),
      name: json['name'],
      stateId: json['state'].toString(),
    );
  }
}

class AddressTypeModel {
  final String id;
  final String name;
  final String code;

  AddressTypeModel({required this.id, required this.name, required this.code});

  factory AddressTypeModel.fromJson(Map<String, dynamic> json) {
    return AddressTypeModel(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'] ?? '',
    );
  }
}

class OrganizationModel {
  final String id;
  final String name;
  final OrganizationTypeModel? type;
  final String? logo;
  final bool isActive;

  OrganizationModel({
    required this.id,
    required this.name,
    this.type,
    this.logo,
    this.isActive = true,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'] != null ? OrganizationTypeModel.fromJson(json['type']) : null,
      logo: json['logo'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type?.id,
      'logo': logo,
      'is_active': isActive,
    };
  }
}
