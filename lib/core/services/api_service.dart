import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = const Uuid();

  /// Create a student document and upload selfie image
  Future<void> createStudent({
    required String studentId,
    required String fullName,
    required File selfieFile,
  }) async {
    final storagePath = 'students/$studentId/selfie_${_uuid.v4()}.jpg';
    final uploadTask = await _storage.ref(storagePath).putFile(selfieFile);
    final selfieUrl = await uploadTask.ref.getDownloadURL();

    await _db.collection('students').doc(studentId).set({
      'studentId': studentId,
      'name': fullName,
      'selfieUrl': selfieUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get student document by studentId
  Future<DocumentSnapshot<Map<String, dynamic>>> getStudent(String studentId) {
    return _db.collection('students').doc(studentId).get();
  }

  /// Create teacher doc manually from app (optional)
  Future<void> createTeacher({
    required String staffId,
    required String name,
    required List<String> subjects,
  }) async {
    await _db.collection('teachers').doc(staffId).set({
      'staffId': staffId,
      'name': name,
      'subjects': subjects,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get teacher doc by staffId
  Future<DocumentSnapshot<Map<String, dynamic>>> getTeacher(String staffId) {
    return _db.collection('teachers').doc(staffId).get();
  }

  /// Create session when teacher generates QR (returns sessionId)
  Future<String> createSession({
    required String teacherId,
    required String subject,
    required DateTime startTime,
    required int validityMinutes,
  }) async {
    final sessionId = _uuid.v4();
    final expiry = startTime.add(Duration(minutes: validityMinutes));
    await _db.collection('sessions').doc(sessionId).set({
      'sessionId': sessionId,
      'teacherId': teacherId,
      'subject': subject,
      'startTime': Timestamp.fromDate(startTime),
      'expiry': Timestamp.fromDate(expiry),
      'validityMinutes': validityMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return sessionId;
  }

  /// Record attendance when student scans (session must be valid)
  Future<void> recordAttendance({
    required String sessionId,
    required String studentId,
    required String studentName,
    required DateTime scannedAt,
    double? faceMatchScore,
    String? wifiSSID,
  }) async {
    final doc = _db.collection('attendance').doc();
    await doc.set({
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'timestamp': Timestamp.fromDate(scannedAt),
      'faceMatchScore': faceMatchScore,
      'wifiSSID': wifiSSID,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
