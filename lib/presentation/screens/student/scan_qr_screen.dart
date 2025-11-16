import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/wifi_service.dart';
import '../../../controllers/qr_controller.dart';
import '../../../controllers/attendance_controller.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool isConnectedToCampusWifi = false;
  bool isCheckingConnection = true;
  String? scannedResult;
  bool isProcessing = false;

  final QRController _qrController = QRController();
  final AttendanceController _attendanceController = AttendanceController();

  @override
  void initState() {
    super.initState();
    _checkWifiConnection();
  }

  Future<void> _checkWifiConnection() async {
    final result = await WifiService.checkWifiConnection();
    setState(() {
      isConnectedToCampusWifi = result;
      isCheckingConnection = false;
    });
  }

  Future<void> _onDetect(BarcodeCapture barcode) async {
    if (isProcessing) return;

    final String? code = barcode.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      isProcessing = true;
      scannedResult = code;
    });

    try {
      // Parse QR code using Controller
      final qrData = _qrController.parseQRCode(code);

      if (qrData == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid QR Code')));
        setState(() => isProcessing = false);
        return;
      }

      // Validate QR code using Controller
      final validation = _qrController.validateQRCode(qrData);

      if (!validation['isValid']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(validation['message'])));
        setState(() => isProcessing = false);
        return;
      }

      // Get student info from session
      final studentId = await SessionService.getUserId();
      final studentName = await SessionService.getUserName();

      if (studentId == null || studentName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student session not found')),
        );
        setState(() => isProcessing = false);
        return;
      }

      // Check if already marked attendance using Controller
      final alreadyMarked = await _attendanceController.isAttendanceMarked(
        sessionId: qrData.sessionId,
        studentId: studentId,
      );

      if (alreadyMarked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already marked present for this class ✅'),
          ),
        );
        setState(() => isProcessing = false);
        Navigator.pop(context);
        return;
      }

      // Mark attendance using Controller
      final result = await _attendanceController.markAttendance(
        qrData: qrData,
        studentId: studentId,
        studentName: studentName,
      );

      if (result['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        setState(() => isProcessing = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Invalid QR Code')));
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingConnection) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isConnectedToCampusWifi) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Scan QR"),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "Cannot detect campus Wi-Fi",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Please ensure:\n\n"
                  "1. You are connected to 'Student WiFi' Wi-Fi\n"
                  "2. Location services (GPS) are enabled on your device\n"
                  "3. Location permission is granted to this app\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkWifiConnection,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If connected to the correct Wi-Fi
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: MobileScanner(onDetect: _onDetect)),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedResult != null
                  ? Text(
                      "Scanned Data:\n$scannedResult",
                      textAlign: TextAlign.center,
                    )
                  : const Text(
                      "Align the QR within the frame to scan",
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
