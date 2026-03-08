class EmployeeModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final double expectedSalary;
  final String displayName;

  EmployeeModel({
    required this.id,
    required this.firstName,
    this.lastName = '',
    this.phoneNumber = '',
    this.expectedSalary = 0.0,
    required this.displayName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      expectedSalary: json['expected_salary'] != null 
          ? double.tryParse(json['expected_salary'].toString()) ?? 0.0 
          : 0.0,
      displayName: json['display_name'] ?? json['first_name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'expected_salary': expectedSalary,
    };
  }
}
