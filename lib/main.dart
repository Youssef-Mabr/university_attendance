import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/auth/role_selection_screen.dart';
import 'presentation/screens/auth/teacher_login_screen.dart';
import 'presentation/screens/auth/student_login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/teacher/teacher_home_screen.dart';
import 'presentation/screens/student/student_home_screen.dart';
import 'presentation/screens/student/scan_qr_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        useMaterial3: false,
      ),
      home: const SessionCheckWrapper(),
      routes: {
        '/roleSelection': (context) => const RoleSelectionScreen(),
        '/teacherLogin': (context) => const TeacherLoginScreen(),
        '/teacherHome': (context) => const TeacherHomeScreen(),
        '/studentRegister': (context) => const StudentRegisterScreen(),
        '/studentLogin': (context) => const StudentLoginScreen(),
        '/studentHome': (context) => const StudentHomeScreen(),
        '/scanQr': (context) => const ScanQrScreen(),
      },
    );
  }
}

class SessionCheckWrapper extends StatefulWidget {
  const SessionCheckWrapper({super.key});

  @override
  State<SessionCheckWrapper> createState() => _SessionCheckWrapperState();
}

class _SessionCheckWrapperState extends State<SessionCheckWrapper> {
  bool _isChecking = true;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Check if session expired (after midnight)
      final isExpired = await SessionService.isSessionExpired();

      if (isExpired) {
        // Clear session and go to role selection
        await SessionService.clearSession();
        setState(() {
          _initialRoute = '/roleSelection';
          _isChecking = false;
        });
        return;
      }

      // Check if user is already logged in
      final role = await SessionService.getUserRole();

      if (role == 'teacher') {
        setState(() {
          _initialRoute = '/teacherHome';
          _isChecking = false;
        });
      } else if (role == 'student') {
        setState(() {
          _initialRoute = '/studentHome';
          _isChecking = false;
        });
      } else {
        setState(() {
          _initialRoute = '/roleSelection';
          _isChecking = false;
        });
      }
    } catch (e) {
      // On error, go to role selection
      setState(() {
        _initialRoute = '/roleSelection';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to the appropriate screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialRoute != null) {
        Navigator.pushReplacementNamed(context, _initialRoute!);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
