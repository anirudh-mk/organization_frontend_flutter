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
