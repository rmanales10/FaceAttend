import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/home/home_final.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/report/report_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/student_data/student.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final int initialIndex;
  const Dashboard({super.key, this.initialIndex = 0});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  List<Widget> body = [
    HomeFinal(),
    AttendanceScreen(),
    ReportScreen(),
    ProfileScreen(),
    Student()
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(child: body[_currentIndex]),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = body.length - 1;
            });
          },
          backgroundColor: blue,
          shape: CircleBorder(),
          child: Icon(Icons.note_add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled),
            _buildNavItem(1, Icons.people),
            SizedBox(width: 48), // Space for FAB
            _buildNavItem(2, Icons.report),
            _buildNavItem(3, Icons.person_2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: _currentIndex == index
            ? BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Color.fromARGB(255, 3, 30, 53).withOpacity(0.1),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _currentIndex == index ? blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
