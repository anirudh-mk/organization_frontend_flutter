class VehicleModel {
  final int id;
  final String make;
  final String model;
  final int? year;
  final String licensePlate;
  final String? vin;
  final String vehicleType;
  final bool isActive;
  final int organization;
  final int? assignedTo;
  final VehicleContactModel? contactInfo;
  final VehiclePaymentOptionModel? paymentOption;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    this.year,
    required this.licensePlate,
    this.vin,
    required this.vehicleType,
    required this.isActive,
    required this.organization,
    this.assignedTo,
    this.contactInfo,
    this.paymentOption,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'],
      licensePlate: json['license_plate'] ?? '',
      vin: json['vin'],
      vehicleType: json['vehicle_type'] ?? '',
      isActive: json['is_active'] ?? true,
      organization: json['organization'] ?? 1,
      assignedTo: json['assigned_to'],
      contactInfo: json['contact_info'] != null 
          ? VehicleContactModel.fromJson(json['contact_info']) 
          : null,
      paymentOption: json['payment_option'] != null 
          ? VehiclePaymentOptionModel.fromJson(json['payment_option']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'vin': vin,
      'vehicle_type': vehicleType,
      'is_active': isActive,
      'organization': organization,
      'assigned_to': assignedTo,
      'contact_info': contactInfo?.toJson(),
      'payment_option': paymentOption?.toJson(),
    };
  }
}

class VehicleContactModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String address;
  final int contactType;

  VehicleContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.contactType,
  });

  factory VehicleContactModel.fromJson(Map<String, dynamic> json) {
    return VehicleContactModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      address: json['address'] ?? '',
      contactType: json['contact_type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'contact_type': contactType,
    };
  }
}

class VehiclePaymentOptionModel {
  final int id;
  final double rate;
  final String currency;
  final String terms;
  final int paymentType;

  VehiclePaymentOptionModel({
    required this.id,
    required this.rate,
    required this.currency,
    required this.terms,
    required this.paymentType,
  });

  factory VehiclePaymentOptionModel.fromJson(Map<String, dynamic> json) {
    return VehiclePaymentOptionModel(
      id: json['id'] ?? 0,
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'INR',
      terms: json['terms'] ?? '',
      paymentType: json['payment_type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rate': rate,
      'currency': currency,
      'terms': terms,
      'payment_type': paymentType,
    };
  }
}
