class CountryModel {
  final String id;
  final String name;
  final String code;

  CountryModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CountryModel && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class StateModel {
  final String id;
  final String name;
  final String code;
  final String countryId;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      // Sometimes it might come back as a nested object, so handle both ID or nested object
      countryId: (json['country'] is Map) 
          ? json['country']['id'].toString()
          : json['country'].toString(),
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is StateModel && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class DistrictModel {
  final String id;
  final String name;
  final String code;
  final String stateId;

  DistrictModel({
    required this.id,
    required this.name,
    required this.code,
    required this.stateId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      stateId: (json['state'] is Map) 
          ? json['state']['id'].toString()
          : json['state'].toString(),
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is DistrictModel && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class AddressTypeModel {
  final String id;
  final String name;

  AddressTypeModel({
    required this.id,
    required this.name,
  });

  factory AddressTypeModel.fromJson(Map<String, dynamic> json) {
    return AddressTypeModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }
}

class AddressModel {
  final String id;
  final String line1;
  final String line2;
  final String districtId;
  final String city;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final String? addressTypeId;
  final String? stateId;
  final String? countryId;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.line1,
    required this.line2,
    required this.districtId,
    required this.city,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.addressTypeId,
    this.stateId,
    this.countryId,
    this.isPrimary = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      line1: json['line_1'] ?? '',
      line2: json['line_2'] ?? '',
      districtId: (json['district'] is Map) 
          ? json['district']['id'].toString() 
          : json['district'].toString(),
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      addressTypeId: json['address_type']?.toString(),
      stateId: json['state_id']?.toString(),
      countryId: json['country_id']?.toString(),
      isPrimary: json['is_primary'] ?? false,
    );
  }
}
