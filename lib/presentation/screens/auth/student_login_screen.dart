import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../controllers/student_controller.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../presentation/widgets/custom_textfield.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController studentIdController = TextEditingController();
  final StudentController _studentController = StudentController();
  bool isLoading = false;

  Future<void> _loginStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final studentId = studentIdController.text.trim();

    setState(() => isLoading = true);

    try {
      // Get student using Controller
      final student = await _studentController.getStudentById(studentId);

      if (student == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student ID not found. Please register first.'),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // Save session using Controller
      await _studentController.loginStudentById(studentId, student.name);

      // Navigate to student home
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Welcome ${student.name}!')));

      Navigator.pushReplacementNamed(context, '/studentHome');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Login'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Login',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: studentIdController,
                label: 'Student ID',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Student ID';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Student ID must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: 'Login', onPressed: _loginStudent),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/studentRegister');
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
