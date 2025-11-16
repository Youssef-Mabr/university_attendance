import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 40),
              const Text(
                'Welcome to Attendance App',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Student Button
              CustomButton(
                text: 'I am a Student',
                onPressed: () => Navigator.pushNamed(context, '/studentLogin'),
              ),
              const SizedBox(height: 20),

              // Teacher Button
              CustomButton(
                text: 'I am a Teacher',
                onPressed: () => Navigator.pushNamed(context, '/teacherLogin'),
              ),

              const SizedBox(height: 40),
              const Text("Don't have an account?"),
              const SizedBox(height: 10),

              // Register Button (for students only)
              CustomButton(
                text: 'Create Student Account',
                onPressed: () =>
                    Navigator.pushNamed(context, '/studentRegister'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
