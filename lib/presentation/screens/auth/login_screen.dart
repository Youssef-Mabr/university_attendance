import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../presentation/widgets/custom_textfield.dart';
import '../../screens/student/student_home_screen.dart';
import '../../screens/teacher/teacher_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'student' or 'teacher'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  bool isLoading = false;

  void _loginUser() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Simulate a short login process
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isLoading = false);

        // For now, we navigate based on role
        if (widget.role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
          );
        } else if (widget.role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == 'student';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isStudent ? 'Student Login' : 'Teacher Login'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStudent
                    ? 'Login using your Student ID'
                    : 'Login using your Staff ID',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // ID Input
              CustomTextField(
                controller: idController,
                label: isStudent ? 'Student ID' : 'Staff ID',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID';
                  } else if (value.length != 12) {
                    return 'ID must be 12 digits';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'ID must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: 'Login', onPressed: _loginUser),
            ],
          ),
        ),
      ),
    );
  }
}
