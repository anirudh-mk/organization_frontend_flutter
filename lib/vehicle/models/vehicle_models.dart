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
  
  // Optional nested related models, could be added later if needed directly
  // final Map<String, dynamic>? contactInfo;
  // final Map<String, dynamic>? paymentOption;

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
    };
  }
}
