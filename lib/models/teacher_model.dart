class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final List<String> subjects;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.subjects,
  });

  // From Firestore
  factory TeacherModel.fromMap(Map<String, dynamic> map, String id) {
    return TeacherModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'subjects': subjects,
    };
  }
}
