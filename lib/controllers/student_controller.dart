import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../core/services/session_service.dart';

class StudentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new student
  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? selfieUrl,
  }) async {
    try {
      // Check if student already exists
      final querySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Student with this email already exists',
        };
      }

      // Create student model
      final student = StudentModel(
        id: '', // Will be set by Firestore
        name: name,
        email: email,
        phone: phone,
        password: password,
        selfieUrl: selfieUrl,
      );

      // Add to Firestore
      await _firestore.collection('students').add(student.toMap());

      return {'success': true, 'message': 'Registration successful!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Login student
  Future<Map<String, dynamic>> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final doc = querySnapshot.docs.first;
      final student = StudentModel.fromMap(doc.data(), doc.id);

      // Save session
      await SessionService.saveSession(
        userId: doc.id,
        userName: student.name,
        role: 'student',
      );

      return {
        'success': true,
        'message': 'Login successful!',
        'student': student,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final doc = await _firestore.collection('students').doc(studentId).get();
      if (doc.exists) {
        return StudentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  // Get current logged-in student
  Future<StudentModel?> getCurrentStudent() async {
    final studentId = await SessionService.getUserId();
    if (studentId != null) {
      return await getStudentById(studentId);
    }
    return null;
  }

  // Login student by ID (for face recognition flow)
  Future<void> loginStudentById(String studentId, String studentName) async {
    await SessionService.saveSession(
      userId: studentId,
      userName: studentName,
      role: 'student',
    );
  }

  // Register student with ID (for face recognition flow)
  Future<Map<String, dynamic>> registerStudentById({
    required String studentId,
    required String name,
    String? selfieUrl,
  }) async {
    try {
      // Check if student ID already exists
      final doc = await _firestore.collection('students').doc(studentId).get();

      if (doc.exists) {
        return {'success': false, 'message': 'Student ID already exists'};
      }

      // Create student with specific ID
      await _firestore.collection('students').doc(studentId).set({
        'name': name,
        'email': '',
        'phone': '',
        'password': '',
        'selfieUrl': selfieUrl ?? 'placeholder',
      });

      return {'success': true, 'message': 'Registration successful!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
