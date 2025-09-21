import 'package:app_attend/src/admin/dashboard/screens/activity_log/activity_log.dart';
import 'package:app_attend/src/admin/dashboard/screens/dashboard/dashboard.dart';
import 'package:app_attend/src/admin/dashboard/screens/students/student_page.dart';
import 'package:app_attend/src/admin/dashboard/screens/subjects/subject_page.dart';

import 'package:app_attend/src/admin/dashboard/screens/teachers/teacher_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Track the current page
  String currentPage = 'Dashboard';

  void setPage(String page) {
    setState(() {
      currentPage = page;
    });
  }

  Widget getContent() {
    switch (currentPage) {
      case 'Dashboard':
        return DashboardPage();
      case 'Teachers':
        return TeacherPage();
      case 'Students':
        return StudentPage();
      // case 'Sections':
      //   return SectionPage();
      case 'Subjects':
        return SubjectPage();
      case 'Activity Logs':
        return ActivityLogPage();
      default:
        return Center(child: Text('Main Content Area'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentPage: currentPage,
            onPageSelected: setPage,
          ),
          Expanded(
            child: getContent(),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageSelected;

  const Sidebar({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: 280,
      height: screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A), // Deep blue
            Color(0xFF1E40AF), // Medium blue
            Color(0xFF2563EB), // Lighter blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo and Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image(
                          image: AssetImage('assets/logo.png'),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tap Attend',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.dashboard_rounded,
                    'Dashboard',
                    isSelected: currentPage == 'Dashboard',
                    onTap: () => onPageSelected('Dashboard'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.people_rounded,
                    'Teachers',
                    isSelected: currentPage == 'Teachers',
                    onTap: () => onPageSelected('Teachers'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.school_rounded,
                    "Students",
                    isSelected: currentPage == 'Students',
                    onTap: () => onPageSelected('Students'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.subject_rounded,
                    'Subjects',
                    isSelected: currentPage == 'Subjects',
                    onTap: () => onPageSelected('Subjects'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    Icons.history_rounded,
                    'Activity Logs',
                    isSelected: currentPage == 'Activity Logs',
                    onTap: () => onPageSelected('Activity Logs'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: Colors.red[300],
                        size: 20,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => Get.offAllNamed('/login'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper function to build menu items with an optional selected state
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isSelected = false,
    required Function() onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
