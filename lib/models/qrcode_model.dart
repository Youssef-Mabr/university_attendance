class QRCodeModel {
  final String sessionId;
  final String teacherId;
  final String teacherName;
  final String subject;
  final String day;
  final String startTime;
  final String endTime;
  final String qrExpiryTime;
  final String date;

  QRCodeModel({
    required this.sessionId,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.qrExpiryTime,
    required this.date,
  });

  // From JSON (when scanning QR)
  factory QRCodeModel.fromJson(Map<String, dynamic> json) {
    return QRCodeModel(
      sessionId: json['sessionId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      subject: json['subject'] ?? '',
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      qrExpiryTime: json['qrExpiryTime'] ?? '',
      date: json['date'] ?? '',
    );
  }

  // To JSON (when generating QR)
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'qrExpiryTime': qrExpiryTime,
      'date': date,
    };
  }
}
