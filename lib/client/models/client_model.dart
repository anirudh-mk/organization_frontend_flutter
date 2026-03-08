import '../../shared/models/location_models.dart';

class ClientContactModel {
  final String id;
  final String name;
  final String designation;
  final String phone;
  final String email;
  final bool isPrimary;

  ClientContactModel({
    required this.id,
    required this.name,
    this.designation = '',
    this.phone = '',
    this.email = '',
    this.isPrimary = false,
  });

  factory ClientContactModel.fromJson(Map<String, dynamic> json) {
    return ClientContactModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'designation': designation,
    'phone': phone,
    'email': email,
    'is_primary': isPrimary,
  };
}

class ClientAddressModel {
  final String id;
  final String addressId;
  final AddressModel? addressDetails;

  ClientAddressModel({
    required this.id,
    required this.addressId,
    this.addressDetails,
  });

  factory ClientAddressModel.fromJson(Map<String, dynamic> json) {
    return ClientAddressModel(
      id: json['id']?.toString() ?? '',
      addressId: json['address']?.toString() ?? '',
      addressDetails: json['address_details'] != null 
          ? AddressModel.fromJson(json['address_details'])
          : null,
    );
  }
}

class ClientModel {
  final String id;
  final String name;
  final String code;
  final String email;
  final String phone;
  final bool isActive;
  final List<ClientContactModel> contacts;
  final List<ClientAddressModel> addresses;

  ClientModel({
    required this.id,
    required this.name,
    required this.code,
    this.email = '',
    this.phone = '',
    this.isActive = true,
    this.contacts = const [],
    this.addresses = const [],
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    List<ClientContactModel> contacts = [];
    if (json['contacts'] != null && json['contacts'] is List) {
      contacts = (json['contacts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => ClientContactModel.fromJson(c))
          .toList();
    }

    List<ClientAddressModel> addresses = [];
    if (json['addresses'] != null && json['addresses'] is List) {
      addresses = (json['addresses'] as List)
          .whereType<Map<String, dynamic>>()
          .map((a) => ClientAddressModel.fromJson(a))
          .toList();
    }

    return ClientModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      contacts: contacts,
      addresses: addresses,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'email': email,
    'phone': phone,
    'is_active': isActive,
  };

  ClientContactModel? get primaryContact =>
      contacts.where((c) => c.isPrimary).firstOrNull ?? contacts.firstOrNull;
}
