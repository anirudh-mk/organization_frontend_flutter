class CountryModel {
  final int id;
  final String name;
  final String code;

  CountryModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class StateModel {
  final int id;
  final String name;
  final String code;
  final int countryId;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      // Sometimes it might come back as a nested object, so handle both ID or nested object
      countryId: (json['country'] is Map) 
          ? (json['country']['id'] ?? 0) 
          : (json['country'] ?? 0),
    );
  }
}

class DistrictModel {
  final int id;
  final String name;
  final String code;
  final int stateId;

  DistrictModel({
    required this.id,
    required this.name,
    required this.code,
    required this.stateId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      stateId: (json['state'] is Map) 
          ? (json['state']['id'] ?? 0) 
          : (json['state'] ?? 0),
    );
  }
}

class AddressTypeModel {
  final int id;
  final String name;

  AddressTypeModel({
    required this.id,
    required this.name,
  });

  factory AddressTypeModel.fromJson(Map<String, dynamic> json) {
    return AddressTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
