class UserModel {

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
    };
  }
}