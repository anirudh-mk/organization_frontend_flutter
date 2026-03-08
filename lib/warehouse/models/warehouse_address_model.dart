class WarehouseAddressModel {
  final int id;
  final int warehouseId;
  final String addressLine1;
  final String addressLine2;
  final int districtId;
  final String city;
  final String postalCode;
  final bool isPrimary;

  WarehouseAddressModel({
    required this.id,
    required this.warehouseId,
    required this.addressLine1,
    required this.addressLine2,
    required this.districtId,
    required this.city,
    required this.postalCode,
    required this.isPrimary,
  });

  factory WarehouseAddressModel.fromJson(Map<String, dynamic> json) {
    return WarehouseAddressModel(
      id: json['id'] ?? 0,
      warehouseId: json['warehouse'] ?? 0,
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      districtId: json['district'] ?? 0,
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse': warehouseId,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'district': districtId,
      'city': city,
      'postal_code': postalCode,
      'is_primary': isPrimary,
    };
  }
}
