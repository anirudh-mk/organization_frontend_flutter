class SubcontractorModel {
  final int id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String specialization;
  final String address;
  
  // Payment Details
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  
  final bool isActive;
  final int organization;

  SubcontractorModel({
    required this.id,
    required this.name,
    this.contactPerson = '',
    this.email = '',
    this.phone = '',
    this.specialization = '',
    this.address = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.accountHolderName = '',
    this.isActive = true,
    required this.organization,
  });

  factory SubcontractorModel.fromJson(Map<String, dynamic> json) {
    return SubcontractorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialization: json['specialization'] ?? '',
      address: json['address'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      isActive: json['is_active'] ?? true,
      organization: json['organization'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'address': address,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_holder_name': accountHolderName,
      'is_active': isActive,
      'organization': organization,
    };
  }
}
