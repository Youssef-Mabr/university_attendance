import 'package:flutter/material.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/auth/student_login_screen.dart';
import '../presentation/screens/auth/teacher_login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/student/student_home_screen.dart';
import '../presentation/screens/student/scan_qr_screen.dart';
import '../presentation/screens/teacher/teacher_home_screen.dart';

class AppRoutes {
  static const String roleSelection = '/roleSelection';
  static const String teacherLogin = '/teacherLogin';
  static const String studentLogin = '/studentLogin';
  static const String studentRegister = '/studentRegister';
  static const String studentHome = '/studentHome';
  static const String teacherHome = '/teacherHome';
  static const String scanQr = '/scanQr';

  static Map<String, WidgetBuilder> routes = {
    roleSelection: (context) => const RoleSelectionScreen(),
    teacherLogin: (context) => const TeacherLoginScreen(),
    studentLogin: (context) => const StudentLoginScreen(),
    studentRegister: (context) => const StudentRegisterScreen(),
    studentHome: (context) => const StudentHomeScreen(),
    teacherHome: (context) => const TeacherHomeScreen(),
    scanQr: (context) => const ScanQrScreen(),
  };
}
