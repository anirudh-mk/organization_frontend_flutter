import '../../shared/models/location_models.dart';
import '../../employee/models/employee_model.dart';
import '../../equipment/models/equipment_model.dart';
import '../../client/models/client_model.dart';

class SiteStatusModel {
  final String id;
  final String name;
  final String code;
  final String description;

  SiteStatusModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory SiteStatusModel.fromJson(Map<String, dynamic> json) {
    return SiteStatusModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SiteMediaModel {
  final String id;
  final String image;
  final String caption;
  final DateTime createdAt;

  SiteMediaModel({
    required this.id,
    required this.image,
    required this.caption,
    required this.createdAt,
  });

  factory SiteMediaModel.fromJson(Map<String, dynamic> json) {
    return SiteMediaModel(
      id: json['id']?.toString() ?? '',
      image: json['image'] ?? json['file'] ?? '',
      caption: json['caption'] ?? json['description'] ?? '',
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
  final List<SiteMediaModel> photos;
  final List<SiteMediaModel> attachments;
  final List<QuotationModel> quotations;
  final List<SiteEmployeeModel> employees;
  final List<SiteEquipmentModel> equipments;
  final List<SiteProgressEntryModel> progressEntries;
  final List<SiteNoteModel> siteNotes;
  final List<AddressModel> addresses;
  final double? estimatedBudget;
  final String? notes;
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
    this.photos = const [],
    this.attachments = const [],
    this.quotations = const [],
    this.employees = const [],
    this.equipments = const [],
    this.progressEntries = const [],
    this.siteNotes = const [],
    this.addresses = const [],
    this.estimatedBudget,
    this.notes,
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
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((i) => SiteMediaModel.fromJson(i)).toList()
          : [],
      attachments: json['attachments'] != null 
          ? (json['attachments'] as List).map((i) => SiteMediaModel.fromJson(i)).toList()
          : [],
      quotations: json['quotations'] != null
          ? (json['quotations'] as List).map((i) => QuotationModel.fromJson(i)).toList()
          : [],
      employees: (json['employees'] as List?)?.map((e) => SiteEmployeeModel.fromJson(e)).toList() ?? [],
      equipments: (json['equipments'] as List?)?.map((e) => SiteEquipmentModel.fromJson(e)).toList() ?? [],
      progressEntries: (json['progress_entries'] as List?)?.map((p) => SiteProgressEntryModel.fromJson(p)).toList() ?? [],
      siteNotes: (json['site_notes'] as List?)?.map((n) => SiteNoteModel.fromJson(n)).toList() ?? [],
      addresses: (json['addresses'] as List?)?.map((a) => AddressModel.fromJson(a)).toList() ?? [],
      estimatedBudget: json['estimated_budget'] != null ? double.tryParse(json['estimated_budget'].toString()) : null,
      notes: json['notes'],
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
      'notes': notes,
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
  final ClientModel? client;

  ClientLinkModel({
    required this.id,
    required this.clientId,
    this.clientName,
    this.client,
  });

  factory ClientLinkModel.fromJson(Map<String, dynamic> json) {
    String cId = '';
    if (json['client'] != null) {
      if (json['client'] is Map) {
        cId = json['client']['id']?.toString() ?? '';
      } else {
        cId = json['client'].toString();
      }
    }

    return ClientLinkModel(
      id: json['id']?.toString() ?? '',
      clientId: cId,
      clientName: json['client_name']?.toString() ?? (json['client'] is Map ? json['client']['name'] : null),
      client: json['client'] != null && json['client'] is Map 
          ? ClientModel.fromJson(json['client'] as Map<String, dynamic>) 
          : null,
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
class SiteEmployeeModel {
  final String id;
  final EmployeeModel? employee;
  final String? phaseId;

  SiteEmployeeModel({required this.id, this.employee, this.phaseId});

  factory SiteEmployeeModel.fromJson(Map<String, dynamic> json) {
    return SiteEmployeeModel(
      id: json['id']?.toString() ?? '',
      employee: json['employee'] != null ? EmployeeModel.fromJson(json['employee']) : null,
      phaseId: json['phase_id']?.toString(),
    );
  }
}

class SiteEquipmentModel {
  final String id;
  final EquipmentModel? equipment;
  final String? phaseId;

  SiteEquipmentModel({required this.id, this.equipment, this.phaseId});

  factory SiteEquipmentModel.fromJson(Map<String, dynamic> json) {
    return SiteEquipmentModel(
      id: json['id']?.toString() ?? '',
      equipment: json['equipment'] != null ? EquipmentModel.fromJson(json['equipment']) : null,
      phaseId: json['phase_id']?.toString(),
    );
  }
}

class SiteProgressTemplateModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final List<SiteProgressChecklistItemModel> items;

  SiteProgressTemplateModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.items = const [],
  });

  factory SiteProgressTemplateModel.fromJson(Map<String, dynamic> json) {
    return SiteProgressTemplateModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      items: (json['items'] as List?)
              ?.map((i) => SiteProgressChecklistItemModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class SiteProgressChecklistItemModel {
  final String id;
  final String templateId;
  final String title;
  final int order;
  final bool isMandatory;

  SiteProgressChecklistItemModel({
    required this.id,
    required this.templateId,
    required this.title,
    this.order = 0,
    this.isMandatory = true,
  });

  factory SiteProgressChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return SiteProgressChecklistItemModel(
      id: json['id']?.toString() ?? '',
      templateId: json['template']?.toString() ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      isMandatory: json['is_mandatory'] ?? true,
    );
  }
}

class SiteProgressItemStatusModel {
  final String id;
  final String progressEntryId;
  final String checklistItemId;
  final SiteProgressChecklistItemModel? checklistItemDetails;
  final bool isCompleted;
  final double completionPercentage;
  final String? notes;

  SiteProgressItemStatusModel({
    required this.id,
    required this.progressEntryId,
    required this.checklistItemId,
    this.checklistItemDetails,
    this.isCompleted = false,
    this.completionPercentage = 0,
    this.notes,
  });

  factory SiteProgressItemStatusModel.fromJson(Map<String, dynamic> json) {
    return SiteProgressItemStatusModel(
      id: json['id']?.toString() ?? '',
      progressEntryId: json['progress_entry']?.toString() ?? '',
      checklistItemId: json['checklist_item']?.toString() ?? '',
      checklistItemDetails: json['checklist_item_details'] != null
          ? SiteProgressChecklistItemModel.fromJson(json['checklist_item_details'])
          : null,
      isCompleted: json['is_completed'] ?? false,
      completionPercentage: double.tryParse(json['completion_percentage']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
    );
  }
}

class SiteProgressEntryModel {
  final String id;
  final String? siteId;
  final String? templateId;
  final SiteProgressTemplateModel? templateDetails;
  final double overallCompletionPercentage;
  final String? remarks;
  final DateTime date;
  final List<SiteProgressItemStatusModel> itemStatuses;

  SiteProgressEntryModel({
    required this.id,
    this.siteId,
    this.templateId,
    this.templateDetails,
    required this.overallCompletionPercentage,
    this.remarks,
    required this.date,
    this.itemStatuses = const [],
  });

  factory SiteProgressEntryModel.fromJson(Map<String, dynamic> json) {
    return SiteProgressEntryModel(
      id: json['id']?.toString() ?? '',
      siteId: json['site']?.toString(),
      templateId: json['template']?.toString(),
      templateDetails: json['template_details'] != null
          ? SiteProgressTemplateModel.fromJson(json['template_details'])
          : null,
      overallCompletionPercentage: double.tryParse(json['overall_completion_percentage']?.toString() ?? '0') ?? 0.0,
      remarks: json['remarks'] ?? json['description'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      itemStatuses: (json['item_statuses'] as List?)
              ?.map((i) => SiteProgressItemStatusModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class SiteNoteModel {
  final String id;
  final String? siteId;
  final String note;
  final DateTime createdAt;

  SiteNoteModel({
    required this.id,
    this.siteId,
    required this.note,
    required this.createdAt,
  });

  factory SiteNoteModel.fromJson(Map<String, dynamic> json) {
    return SiteNoteModel(
      id: json['id']?.toString() ?? '',
      siteId: json['site']?.toString(),
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
