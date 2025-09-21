import 'package:app_attend/firebase_options.dart';
import 'package:app_attend/src/admin/dashboard/sidebar.dart';
import 'package:app_attend/src/admin/dashboard/screens/activity_log/activity_log.dart';
import 'package:app_attend/src/admin/dashboard/screens/dashboard/dashboard.dart';
import 'package:app_attend/src/admin/dashboard/screens/students/student_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/subjects/subject_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/teachers/teacher_page.dart';
import 'package:app_attend/src/admin/main_screen/admin.dart';
import 'package:app_attend/src/user/dashboard/dashboard.dart';
import 'package:app_attend/src/user/main_screen/forgot_password.dart';
import 'package:app_attend/src/user/main_screen/login.dart';
import 'package:app_attend/src/user/main_screen/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/user/main_screen/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    runApp(Admin());
  } else {
    // For non-web platforms
    runApp(UserApp());
  }
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap Attend',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => InitialScreen()),
        GetPage(name: '/welcome', page: () => WelcomeScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/dashboard', page: () => Dashboard()),
        GetPage(name: '/forgot', page: () => ForgotPassword()),
      ],
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, redirect to dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed('/dashboard');
            });
            return Container(); // Placeholder widget while redirecting
          } else {
            // User is not logged in, show welcome screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed('/welcome');
            });
            return Container(); // Placeholder widget while redirecting
          }
        }
      },
    );
  }
}

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap Attend',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreenForAdmin()),
        GetPage(name: '/activity-log', page: () => ActivityLogPage()),
        GetPage(name: '/subject', page: () => SubjectPage()),
        GetPage(name: '/student', page: () => StudentPage()),
        GetPage(name: '/teacher', page: () => TeacherPage()),
        GetPage(name: '/home', page: () => DashboardPage()),
        GetPage(name: '/dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}
