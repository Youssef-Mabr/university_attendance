import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/student_controller.dart';
import '../../../controllers/teacher_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/session_service.dart';
import '../../../presentation/widgets/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController idController = TextEditingController();
  final StudentController _studentController = StudentController();
  final TeacherController _teacherController = TeacherController();
  bool isLoading = false;

  Future<void> _handleLogin() async {
    final id = idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your ID')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check ID length to determine user type
      if (id.length == 12) {
        // Student ID (12 digits)
        await _loginStudent(id);
      } else if (id.length == 4) {
        // Teacher ID (4 digits)
        await _loginTeacher(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid ID format. Student: 12 digits, Teacher: 4 digits',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginStudent(String studentId) async {
    final student = await _studentController.getStudentById(studentId);

    if (student == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student not registered. Please register first.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Save session
    await SessionService.saveSession(
      userId: studentId,
      userName: student.name,
      role: 'student',
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Welcome ${student.name}! 👋')));
      Navigator.pushReplacementNamed(context, '/studentHome');
    }
  }

  Future<void> _loginTeacher(String staffId) async {
    final teacher = await _teacherController.getTeacherByStaffId(staffId);

    if (teacher == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Staff ID ❌'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Save session
    await SessionService.saveSession(
      userId: staffId,
      userName: teacher.name,
      role: 'teacher',
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Welcome ${teacher.name}! 👋')));
      Navigator.pushReplacementNamed(context, '/teacherHome');
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/studentRegister');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'University Attendance System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your ID to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // ID Input Field
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Enter your ID',
                  hintText: 'Student (12 digits) or Teacher (4 digits)',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              CustomButton(
                text: isLoading ? 'Logging in...' : 'Login',
                onPressed: isLoading ? () {} : _handleLogin,
              ),
              const SizedBox(height: 20),

              // Register Button (for students)
              OutlinedButton(
                onPressed: _navigateToRegister,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Register (Students Only)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'ID Format',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Students: 12-digit ID',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                    Text(
                      '• Teachers: 4-digit Staff ID',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }
}
