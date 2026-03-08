class SiteModel {
  final String id;
  final String name;
  final String code;
  final String status;
  final String? projectId;
  final double? estimatedBudget;
  final DateTime? expectedStartDate;
  final DateTime? expectedEndDate;
  final DateTime createdAt;

  SiteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    this.projectId,
    this.estimatedBudget,
    this.expectedStartDate,
    this.expectedEndDate,
    required this.createdAt,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 'Draft',
      projectId: json['project'],
      estimatedBudget: json['estimated_budget'] != null ? double.tryParse(json['estimated_budget'].toString()) : null,
      expectedStartDate: json['expected_start_date'] != null ? DateTime.tryParse(json['expected_start_date']) : null,
      expectedEndDate: json['expected_end_date'] != null ? DateTime.tryParse(json['expected_end_date']) : null,
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
      'project': projectId,
      'estimated_budget': estimatedBudget,
      'expected_start_date': expectedStartDate?.toIso8601String().split('T')[0],
      'expected_end_date': expectedEndDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }
}
