class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? selfieUrl;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.selfieUrl,
  });

  // From Firestore
  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      selfieUrl: map['selfieUrl'],
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'selfieUrl': selfieUrl ?? 'placeholder_url',
    };
  }
}
