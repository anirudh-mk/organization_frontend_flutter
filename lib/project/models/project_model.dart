class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? quotationId;
  final String? quotationDetails;
  final String organizationId;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.quotationId,
    this.quotationDetails,
    required this.organizationId,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      quotationId: json['quotation'],
      quotationDetails: json['quotation_details'],
      organizationId: json['organization'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quotation': quotationId,
      'quotation_details': quotationDetails,
      'organization': organizationId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
