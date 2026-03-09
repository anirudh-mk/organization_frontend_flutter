class SiteStatusModel {
  final String id;
  final String name;
  final String description;

  SiteStatusModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SiteStatusModel.fromJson(Map<String, dynamic> json) {
    return SiteStatusModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SiteImageModel {
  final String id;
  final String image;
  final String caption;
  final DateTime createdAt;

  SiteImageModel({
    required this.id,
    required this.image,
    required this.caption,
    required this.createdAt,
  });

  factory SiteImageModel.fromJson(Map<String, dynamic> json) {
    return SiteImageModel(
      id: json['id']?.toString() ?? '',
      image: json['image'] ?? '',
      caption: json['caption'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SiteModel {
  final String id;
  final String name;
  final String code;
  final String status;
  final SiteStatusModel? statusDetails;
  final String? organizationId;
  final ClientLinkModel? clientLink;
  final List<SiteImageModel> images;
  final List<QuotationModel> quotations;
  final double? estimatedBudget;
  final DateTime? expectedStartDate;
  final DateTime? expectedEndDate;
  final DateTime createdAt;

  SiteModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    this.statusDetails,
    this.organizationId,
    this.clientLink,
    this.images = const [],
    this.quotations = const [],
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
      status: json['status']?.toString() ?? '',
      statusDetails: json['status_details'] != null 
          ? SiteStatusModel.fromJson(json['status_details']) 
          : null,
      organizationId: json['organization']?.toString(),
      clientLink: json['client_link'] != null
          ? ClientLinkModel.fromJson(json['client_link'])
          : null,
      images: json['images'] != null 
          ? (json['images'] as List).map((i) => SiteImageModel.fromJson(i)).toList()
          : [],
      quotations: json['quotations'] != null
          ? (json['quotations'] as List).map((i) => QuotationModel.fromJson(i)).toList()
          : [],
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
      'organization': organizationId,
      'estimated_budget': estimatedBudget,
      'expected_start_date': expectedStartDate?.toIso8601String().split('T')[0],
      'expected_end_date': expectedEndDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ClientLinkModel {
  final String id;
  final String clientId;
  final String? clientName;
  final double contractValue;

  ClientLinkModel({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.contractValue,
  });

  factory ClientLinkModel.fromJson(Map<String, dynamic> json) {
    return ClientLinkModel(
      id: json['id']?.toString() ?? '',
      clientId: json['client']?.toString() ?? '',
      clientName: json['client_name']?.toString(),
      contractValue: double.tryParse(json['contract_value'].toString()) ?? 0.0,
    );
  }
}

class QuotationModel {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime? sentAt;

  QuotationModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.sentAt,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at']) : null,
    );
  }
}
