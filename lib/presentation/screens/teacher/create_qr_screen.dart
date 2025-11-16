import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/session_service.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../controllers/qr_controller.dart';
import '../../../controllers/teacher_controller.dart';

class CreateQrScreen extends StatefulWidget {
  const CreateQrScreen({super.key});

  @override
  State<CreateQrScreen> createState() => _CreateQrScreenState();
}

class _CreateQrScreenState extends State<CreateQrScreen> {
  String? selectedSubject;
  String? selectedDay;
  String? currentTimeStr;
  int qrExpiryMinutes = 15; // QR code expiry time
  String? generatedQRData;
  String teacherId = '';
  String teacherName = '';
  List<String> teacherSubjects = [];
  bool isLoadingSubjects = true;

  final QRController _qrController = QRController();
  final TeacherController _teacherController = TeacherController();

  final days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
  }

  Future<void> _loadTeacherInfo() async {
    final id = await SessionService.getUserId();
    final name = await SessionService.getUserName();

    setState(() {
      teacherId = id ?? '';
      teacherName = name ?? '';
    });

    // Load teacher's subjects using Controller
    if (id != null) {
      try {
        final subjects = await _teacherController.getTeacherSubjects(id);
        setState(() {
          teacherSubjects = subjects;
          isLoadingSubjects = false;
        });
      } catch (e) {
        print('Error loading subjects: $e');
        setState(() {
          isLoadingSubjects = false;
        });
      }
    }
  }

  void generateQR() {
    if (selectedSubject == null || selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select subject and day")),
      );
      return;
    }

    if (currentTimeStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select subject first")),
      );
      return;
    }

    // Generate QR code using Controller with the time captured when subject was selected
    final qrModel = _qrController.generateQRCode(
      teacherId: teacherId,
      teacherName: teacherName,
      subject: selectedSubject!,
      day: selectedDay!,
      startTime: currentTimeStr!,
      endTime: currentTimeStr!,
      qrExpiryMinutes: qrExpiryMinutes,
    );

    // Convert to JSON string
    final qrJsonString = _qrController.qrModelToJsonString(qrModel);

    setState(() {
      generatedQRData = qrJsonString;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingSubjects) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (teacherSubjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Create QR Code"),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text(
            'No subjects assigned to you.\nContact administrator.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create QR Code"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Subject",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedSubject,
              isExpanded: true,
              hint: const Text("Choose a subject you teach"),
              items: teacherSubjects.map((subject) {
                return DropdownMenuItem(value: subject, child: Text(subject));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                  // Auto-fill day and time based on current datetime
                  if (value != null) {
                    final now = DateTime.now();
                    // Set day to current day name
                    final dayNames = [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                    ];
                    selectedDay =
                        dayNames[now.weekday -
                            1]; // weekday: 1=Monday, 7=Sunday

                    // Capture current time
                    final hour = now.hour.toString().padLeft(2, '0');
                    final minute = now.minute.toString().padLeft(2, '0');
                    currentTimeStr = '$hour:$minute';
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Day",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDay,
              isExpanded: true,
              hint: const Text("Choose a day"),
              items: days.map((day) {
                return DropdownMenuItem(value: day, child: Text(day));
              }).toList(),
              onChanged: (value) => setState(() => selectedDay = value),
            ),
            const SizedBox(height: 20),
            if (currentTimeStr != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Current Time: $currentTimeStr',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (currentTimeStr != null) const SizedBox(height: 20),
            const Text(
              "QR Code Expiry Time",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value: qrExpiryMinutes.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    label: "$qrExpiryMinutes minutes",
                    onChanged: (val) {
                      setState(() {
                        qrExpiryMinutes = val.toInt();
                      });
                    },
                  ),
                ),
                Text(
                  "$qrExpiryMinutes min",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Text(
              'QR code will expire after this time from creation',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: CustomButton(text: "Generate QR", onPressed: generateQR),
            ),
            const SizedBox(height: 25),
            if (generatedQRData != null)
              Center(
                child: QrImageView(
                  data: generatedQRData!,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
