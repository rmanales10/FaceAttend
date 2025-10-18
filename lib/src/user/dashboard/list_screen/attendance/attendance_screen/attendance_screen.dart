import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create_attendance/create_attendance.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                  Obx(() => _buildInfoCard(
                        icon: Icons.list_alt,
                        title: 'Total Records',
                        value: '${_controller.allAttendance.length}',
                      )),
                  _buildCreateNewButton(),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (_controller.allAttendance.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await _controller.refreshAttendance();
                    },
                    child: _buildAttendanceList(),
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
      onPressed: () => _showAttendanceTypeDialog(),
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

  void _showAttendanceTypeDialog() {
    Get.dialog(
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
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Get.to(() => const CreateAttendance(isAsynchronous: true));
                  },
                ),
                _buildAttendanceTypeButton(
                  icon: Icons.person,
                  label: 'Face to Face',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Get.to(() => const CreateAttendance(isAsynchronous: false));
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
    return const Center(
      child: Text(
        'No attendance records found.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      itemCount: _controller.allAttendance.length,
      itemBuilder: (context, index) {
        final record = _controller.allAttendance[index];
        final timestamp = record['date'] as Timestamp;
        final dateTime = timestamp.toDate();
        final formattedDate = DateFormat('MMMM d, y').format(dateTime);
        final formattedTime = record['time'] ?? '';

        return _buildAttendanceCard(
          record: record,
          formattedDate: formattedDate,
          formattedTime: formattedTime,
          onTap: () => Get.to(() => ListOfStudents(
                subject: record['subject'],
                section: record['section'],
                date: formattedDate,
                attendanceId: record['id'],
                isSubmitted: record['is_submitted'],
                isAsynchronous: record['is_asynchronous'] ?? false,
                subjectId: record['class_schedule']?['subject_id'] ?? '',
              )),
          onDelete: () => _confirmDelete(record['id'], record['is_submitted']),
        );
      },
    );
  }

  Widget _buildAttendanceCard({
    required Map<String, dynamic> record,
    required String formattedDate,
    required String formattedTime,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final isSubmitted = record['is_submitted'] ?? false;
    final isAsynchronous = record['is_asynchronous'] ?? false;
    final status = record['status'] ?? 'pending';
    final classSchedule = record['class_schedule'] ?? {};
    final totalStudents = record['total_students'] ?? 0;
    final presentCount = record['present_count'] ?? 0;
    final absentCount = record['absent_count'] ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with subject and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['subject'] ?? 'Unknown Subject',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Section: ${record['section'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAttendanceTypeChip(isAsynchronous),
                ],
              ),
              const SizedBox(height: 12),

              // Date and time info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),

              // Class schedule details if available
              if (classSchedule.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Teacher: ${classSchedule['teacher_name'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Room: ${classSchedule['building_room'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Attendance statistics
              if (totalStudents > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('Total: $totalStudents', Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('Present: $presentCount', Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Absent: $absentCount', Colors.red),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Status and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(status, isSubmitted),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isSubmitted) {
    Color color;
    String label;
    IconData icon;

    if (isSubmitted) {
      color = Colors.green;
      label = 'Submitted';
      icon = Icons.check_circle;
    } else if (status == 'active') {
      color = Colors.blue;
      label = 'Active';
      icon = Icons.play_circle;
    } else {
      color = Colors.orange;
      label = 'Pending';
      icon = Icons.pending;
    }

    return Chip(
      label: Text(label),
      avatar: Icon(icon, color: color, size: 18),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildAttendanceTypeChip(bool isAsynchronous) {
    return Chip(
      label: Text(
        isAsynchronous ? 'Asynchronous' : 'Face to Face',
        style: TextStyle(
          color: isAsynchronous ? Colors.blue : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isAsynchronous
          ? Colors.blue.withOpacity(0.1)
          : Colors.green.withOpacity(0.1),
      avatar: Icon(
        isAsynchronous ? Icons.access_time : Icons.person,
        color: isAsynchronous ? Colors.blue : Colors.green,
        size: 18,
      ),
    );
  }

  void _confirmDelete(String attendanceId, bool isSubmitted) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to delete this attendance?'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _controller.deleteAttendanceRecord(
                  attendanceId, isSubmitted);
              Get.back(closeOverlays: true);
              showSuccess(message: 'Attendance deleted successfully.');
            },
            child: const Text('Yes'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }
}
