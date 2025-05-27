import 'package:app_attend/src/admin/dashboard/screens/activity_log/activity_log.dart';
import 'package:app_attend/src/admin/dashboard/screens/homepage/home_page.dart';
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
        return HomePage();
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

    return Material(
      color: Color(0xFF1E1E2C),
      child: SizedBox(
        width: 250,
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 40),
                  Image(
                    image: AssetImage('assets/logo.png'),
                    width: 50,
                  ),
                  Text('Tap Attend',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 30),

              // Search Box

              SizedBox(height: 20),

              // Menu Items
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildMenuItem(
                    Icons.home,
                    'Dashboard',
                    isSelected: currentPage == 'Dashboard',
                    onTap: () => onPageSelected('Dashboard'),
                  ),
                  _buildMenuItem(
                    Icons.people,
                    'Teachers',
                    isSelected: currentPage == 'Teachers',
                    onTap: () => onPageSelected('Teachers'),
                  ),
                  _buildMenuItem(
                    Icons.star_border,
                    "Students",
                    isSelected: currentPage == 'Students',
                    onTap: () => onPageSelected('Students'),
                  ),
                  // _buildMenuItem(
                  //   Icons.book,
                  //   "Sections",
                  //   isSelected: currentPage == 'Sections',
                  //   onTap: () => onPageSelected('Sections'),
                  // ),
                  _buildMenuItem(
                    Icons.analytics,
                    'Subjects',
                    isSelected: currentPage == 'Subjects',
                    onTap: () => onPageSelected('Subjects'),
                  ),

                  _buildMenuItem(
                    Icons.event_note_outlined,
                    'Activity Logs',
                    isSelected: currentPage == 'Activity Logs',
                    onTap: () => onPageSelected('Activity Logs'),
                  ),
                ],
              ),

              // Bottom Section with Logout and Light Mode Toggle
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.grey),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () => Get.offAllNamed('/login'),
              ),

              SizedBox(height: 20),
            ],
          ),
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
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.grey[800] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }
}
