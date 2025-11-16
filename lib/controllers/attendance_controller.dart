import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../models/qrcode_model.dart';

class AttendanceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance from QR scan
  Future<Map<String, dynamic>> markAttendance({
    required QRCodeModel qrData,
    required String studentId,
    required String studentName,
  }) async {
    try {
      // Check if already marked attendance for this session
      final existingAttendance = await _firestore
          .collection('attendance')
          .where('sessionId', isEqualTo: qrData.sessionId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'You have already marked attendance for this session',
        };
      }

      // Create attendance record
      final attendance = AttendanceModel(
        id: '',
        sessionId: qrData.sessionId,
        studentId: studentId,
        studentName: studentName,
        teacherId: qrData.teacherId,
        teacherName: qrData.teacherName,
        subject: qrData.subject,
        day: qrData.day,
        startTime: qrData.startTime,
        endTime: qrData.endTime,
        timestamp: DateTime.now(),
      );

      // Save to Firestore
      await _firestore.collection('attendance').add(attendance.toMap());

      return {'success': true, 'message': 'Attendance marked successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get attendance records for a teacher
  Future<List<AttendanceModel>> getTeacherAttendance(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting attendance: $e');
      return [];
    }
  }

  // Get attendance records for a student
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting attendance: $e');
      return [];
    }
  }

  // Check if attendance already marked for session
  Future<bool> isAttendanceMarked({
    required String sessionId,
    required String studentId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('sessionId', isEqualTo: sessionId)
          .where('studentId', isEqualTo: studentId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking attendance: $e');
      return false;
    }
  }
}
