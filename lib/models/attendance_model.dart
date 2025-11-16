class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String teacherName;
  final String subject;
  final String day;
  final String startTime;
  final String endTime;
  final DateTime timestamp;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.timestamp,
  });

  // From Firestore
  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      sessionId: map['sessionId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subject: map['subject'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      timestamp: (map['timestamp'] as dynamic).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'timestamp': timestamp,
    };
  }
}
