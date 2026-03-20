class EmployeeModel {
  final int id;
  final String firstName;
  final String lastName;
  final List<EmployeeMobileModel> mobiles;
  final List<EmployeeEmailModel> emails;
  final double expectedSalary;
  final String displayName;
  final List<EmployeePhotoModel> photos;
  final List<dynamic> attachments; // Using dynamic for now or create AttachmentModel if needed

  EmployeeModel({
    required this.id,
    required this.firstName,
    this.lastName = '',
    this.mobiles = const [],
    this.emails = const [],
    this.expectedSalary = 0.0,
    required this.displayName,
    this.photos = const [],
    this.attachments = const [],
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobiles: json['mobiles'] != null 
          ? (json['mobiles'] as List).map((m) => EmployeeMobileModel.fromJson(m)).toList()
          : [],
      emails: json['emails'] != null 
          ? (json['emails'] as List).map((e) => EmployeeEmailModel.fromJson(e)).toList()
          : [],
      expectedSalary: json['expected_salary'] != null 
          ? double.tryParse(json['expected_salary'].toString()) ?? 0.0 
          : 0.0,
      displayName: json['display_name'] ?? json['first_name'] ?? 'Unknown',
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((p) => EmployeePhotoModel.fromJson(p)).toList()
          : [],
      attachments: json['attachments'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'expected_salary': expectedSalary,
    };
  }
}

class EmployeeEmailModel {
  final int id;
  final String email;
  final String? contactType;

  EmployeeEmailModel({required this.id, required this.email, this.contactType});

  factory EmployeeEmailModel.fromJson(Map<String, dynamic> json) {
    return EmployeeEmailModel(
      id: json['id'] ?? 0,
      email: json['email_str'] ?? json['email_details']?['email'] ?? '',
      contactType: json['contact_type_name'],
    );
  }
}

class EmployeeMobileModel {
  final int id;
  final String number;
  final String? contactType;

  EmployeeMobileModel({required this.id, required this.number, this.contactType});

  factory EmployeeMobileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeMobileModel(
      id: json['id'] ?? 0,
      number: json['number'] ?? json['mobile_details']?['number'] ?? '',
      contactType: json['contact_type_name'],
    );
  }
}

class EmployeePhotoModel {
  final int id;
  final String imageUrl;
  final bool isPrimary;
  final String? description;

  EmployeePhotoModel({
    required this.id,
    required this.imageUrl,
    this.isPrimary = false,
    this.description,
  });

  factory EmployeePhotoModel.fromJson(Map<String, dynamic> json) {
    return EmployeePhotoModel(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      description: json['description'],
    );
  }
}
