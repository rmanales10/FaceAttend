import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create_attendance/create_attendance.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/subject_attendance_details.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();
    _controller.getAllAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Records',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: blue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final filteredAttendance = _getFilteredAttendance();
                    final groupedBySubject =
                        _groupBySubject(filteredAttendance);
                    final subjectCount = groupedBySubject.keys.length;
                    return _buildInfoCard(
                      icon: Icons.list_alt,
                      title: 'Total Subjects',
                      value: '$subjectCount',
                    );
                  }),
                  _buildCreateNewButton(),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  final filteredAttendance = _getFilteredAttendance();
                  if (filteredAttendance.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await _controller.refreshAttendance();
                    },
                    child: _buildAttendanceList(filteredAttendance),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: blue, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      color: blue, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await _showAttendanceTypeDialog();
        // Refresh the list when returning from create screen
        _controller.refreshAttendance();
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Create New', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 2,
      ),
    );
  }

  Future<void> _showAttendanceTypeDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Attendance Type',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose the type of attendance you want to create:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceTypeButton(
                  icon: Icons.access_time,
                  label: 'Asynchronous',
                  color: Colors.blue,
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    await Get.to(
                        () => const CreateAttendance(isAsynchronous: true));
                    _controller.refreshAttendance(); // Refresh after returning
                  },
                ),
                _buildAttendanceTypeButton(
                  icon: Icons.person,
                  label: 'Face to Face',
                  color: Colors.green,
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    await Get.to(
                        () => const CreateAttendance(isAsynchronous: false));
                    _controller.refreshAttendance(); // Refresh after returning
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTypeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance records found.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredAttendance() {
    // Return all attendance records without filtering
    return _controller.allAttendance;
  }

  Map<String, List<Map<String, dynamic>>> _groupBySubject(
      List<Map<String, dynamic>> attendanceList) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var record in attendanceList) {
      final subject = record['subject'] ?? 'Unknown Subject';
      if (!grouped.containsKey(subject)) {
        grouped[subject] = [];
      }
      grouped[subject]!.add(record);
    }
    return grouped;
  }

  Widget _buildAttendanceList(List<Map<String, dynamic>> attendanceList) {
    final groupedBySubject = _groupBySubject(attendanceList);
    final subjects = groupedBySubject.keys.toList();

    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final records = groupedBySubject[subject]!;

        return _buildSubjectCard(
          subject: subject,
          recordCount: records.length,
          onTap: () {
            Get.to(() => SubjectAttendanceDetails(
                  subject: subject,
                  attendanceRecords: records,
                ))?.then((_) {
              // Refresh attendance list when returning
              _controller.refreshAttendance();
            });
          },
        );
      },
    );
  }

  Widget _buildSubjectCard({
    required String subject,
    required int recordCount,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.book,
                        color: blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$recordCount ${recordCount == 1 ? 'record' : 'records'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
