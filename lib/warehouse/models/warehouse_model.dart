import 'warehouse_address_model.dart';

class WarehouseModel {
  final String id;
  final String name;
  final String code;
  final String organizationId;
  final bool isPrimary;
  final bool isActive;
  final List<WarehouseAddressModel> addressList;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.organizationId,
    required this.isPrimary,
    required this.isActive,
    this.addressList = const [],
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    var addressList = <WarehouseAddressModel>[];
    if (json['address_list'] != null) {
      addressList = (json['address_list'] as List)
          .map((i) => WarehouseAddressModel.fromJson(i))
          .toList();
    }

    return WarehouseModel(
      id: json['id'].toString(),
      name: json['name'],
      code: json['code'],
      organizationId: json['organization'].toString(),
      isPrimary: json['is_primary'] ?? false,
      isActive: json['is_active'] ?? true,
      addressList: addressList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }
}
