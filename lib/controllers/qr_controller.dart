import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/qrcode_model.dart';

class QRController {
  // Generate QR code data
  QRCodeModel generateQRCode({
    required String teacherId,
    required String teacherName,
    required String subject,
    required String day,
    required String startTime,
    required String endTime,
    required int qrExpiryMinutes,
  }) {
    final sessionId = const Uuid().v4();
    final now = DateTime.now();
    final qrExpiryTime = now.add(Duration(minutes: qrExpiryMinutes));

    return QRCodeModel(
      sessionId: sessionId,
      teacherId: teacherId,
      teacherName: teacherName,
      subject: subject,
      day: day,
      startTime: startTime,
      endTime: endTime,
      qrExpiryTime: qrExpiryTime.toIso8601String(),
      date:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }

  // Convert QR model to JSON string
  String qrModelToJsonString(QRCodeModel model) {
    return jsonEncode(model.toJson());
  }

  // Parse QR code JSON string to model
  QRCodeModel? parseQRCode(String qrData) {
    try {
      final Map<String, dynamic> json = jsonDecode(qrData);
      return QRCodeModel.fromJson(json);
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  // Validate QR code
  Map<String, dynamic> validateQRCode(QRCodeModel qrData) {
    final now = DateTime.now();

    // Check QR expiry time
    final qrExpiryDateTime = DateTime.parse(qrData.qrExpiryTime);
    if (now.isAfter(qrExpiryDateTime)) {
      return {'isValid': false, 'message': 'QR Code has expired'};
    }

    // Check date
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (qrData.date != today) {
      return {'isValid': false, 'message': 'QR Code is not valid for today'};
    }

    // QR is valid if not expired and date matches
    // startTime and endTime are for record-keeping only (shown in PDF/Excel)
    return {'isValid': true, 'message': 'QR Code is valid'};
  }
}
