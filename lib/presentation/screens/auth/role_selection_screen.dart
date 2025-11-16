import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/widgets/custom_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - full width with suitable height
              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: 150,
                fit: BoxFit.contain,
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
                'Select your role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),

              // Teacher Login Button
              CustomButton(
                text: 'Teacher Login',
                onPressed: () {
                  Navigator.pushNamed(context, '/teacherLogin');
                },
              ),
              const SizedBox(height: 20),

              // Student Login/Register Button
              CustomButton(
                text: 'Student Login / Register',
                onPressed: () {
                  Navigator.pushNamed(context, '/studentLogin');
                },
              ),

              const SizedBox(height: 40),

              // Icons for roles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/teacher_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 8),
                      const Text('Teacher'),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/student_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 8),
                      const Text('Student'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
