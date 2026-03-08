class SiteModel {
  final int id;
  final String name;
  final String code;
  final String status;
  final DateTime createdAt;

  SiteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.createdAt,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 'Draft',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
