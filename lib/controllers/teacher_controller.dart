import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';
import '../core/services/session_service.dart';

class TeacherController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new teacher
  Future<Map<String, dynamic>> registerTeacher({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<String> subjects,
  }) async {
    try {
      // Check if teacher already exists
      final querySnapshot = await _firestore
          .collection('teachers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Teacher with this email already exists',
        };
      }

      // Create teacher model
      final teacher = TeacherModel(
        id: '',
        name: name,
        email: email,
        phone: phone,
        password: password,
        subjects: subjects,
      );

      // Add to Firestore
      await _firestore.collection('teachers').add(teacher.toMap());

      return {'success': true, 'message': 'Registration successful!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Login teacher
  Future<Map<String, dynamic>> loginTeacher({
    required String email,
    required String password,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('teachers')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final doc = querySnapshot.docs.first;
      final teacher = TeacherModel.fromMap(doc.data(), doc.id);

      // Save session
      await SessionService.saveSession(
        userId: doc.id,
        userName: teacher.name,
        role: 'teacher',
      );

      return {
        'success': true,
        'message': 'Login successful!',
        'teacher': teacher,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get teacher by ID
  Future<TeacherModel?> getTeacherById(String teacherId) async {
    try {
      final doc = await _firestore.collection('teachers').doc(teacherId).get();
      if (doc.exists) {
        return TeacherModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting teacher: $e');
      return null;
    }
  }

  // Get current logged-in teacher
  Future<TeacherModel?> getCurrentTeacher() async {
    final teacherId = await SessionService.getUserId();
    if (teacherId != null) {
      return await getTeacherById(teacherId);
    }
    return null;
  }

  // Get teacher subjects by staffId
  Future<List<String>> getTeacherSubjects(String staffId) async {
    try {
      final query = await _firestore
          .collection('teachers')
          .where('staffId', isEqualTo: staffId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final teacher = query.docs.first.data();
        final subjects = teacher['subjects'];
        if (subjects is List) {
          return List<String>.from(subjects);
        }
      }
      return [];
    } catch (e) {
      print('Error getting teacher subjects: $e');
      return [];
    }
  }

  // Get teacher by staffId
  Future<TeacherModel?> getTeacherByStaffId(String staffId) async {
    try {
      final query = await _firestore
          .collection('teachers')
          .where('staffId', isEqualTo: staffId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return TeacherModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting teacher by staffId: $e');
      return null;
    }
  }
}
