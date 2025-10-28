import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create_attendance/create_attendance.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart';
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

        // Handle date field safely - it could be Timestamp or DateTime or null
        String formattedDate = 'No date';
        try {
          if (record['date'] != null) {
            if (record['date'] is Timestamp) {
              final timestamp = record['date'] as Timestamp;
              final dateTime = timestamp.toDate();
              formattedDate = DateFormat('MMMM d, y').format(dateTime);
            } else if (record['date'] is DateTime) {
              formattedDate =
                  DateFormat('MMMM d, y').format(record['date'] as DateTime);
            }
          }
        } catch (e) {
          formattedDate = 'Invalid date';
        }

        final formattedTime = record['time'] ?? '';

        return _buildAttendanceCard(
          record: record,
          formattedDate: formattedDate,
          formattedTime: formattedTime,
          onTap: () => _showAttendanceMethodDialog(
            record: record,
            formattedDate: formattedDate,
          ),
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with subject and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record['subject'] ?? 'Unknown Subject',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: blue,
                      ),
                    ),
                  ),
                  _buildAttendanceTypeChip(isAsynchronous),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Section: ${record['section'] ?? 'Unknown'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),

              // Date and time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),

              // Class schedule details
              if (classSchedule.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Teacher: ${classSchedule['teacher_name'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Room: ${classSchedule['building_room'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Attendance statistics
              if (totalStudents > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatChip('Total: $totalStudents', Colors.blue),
                    const SizedBox(width: 6),
                    _buildStatChip('Present: $presentCount', Colors.green),
                    const SizedBox(width: 6),
                    _buildStatChip('Absent: $absentCount', Colors.red),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // Status and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(status, isSubmitted),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color[200]!, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isSubmitted) {
    MaterialColor color;
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color[700], size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTypeChip(bool isAsynchronous) {
    final color = isAsynchronous ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAsynchronous ? Icons.access_time : Icons.person,
            color: color[700],
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isAsynchronous ? 'Asynchronous' : 'Face to Face',
            style: TextStyle(
              color: color[700],
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceMethodDialog({
    required Map<String, dynamic> record,
    required String formattedDate,
  }) {
    final isAsynchronous = record['is_asynchronous'] ?? false;
    final isSubmitted = record['is_submitted'] ?? false;

    // If the attendance is submitted, go directly to view the student list
    if (isSubmitted) {
      Get.to(() => ListOfStudents(
            subject: record['subject'],
            section: record['section'],
            date: formattedDate,
            attendanceId: record['id'],
            isSubmitted: isSubmitted,
            isAsynchronous: isAsynchronous,
            subjectId: record['class_schedule']?['subject_id'] ?? '',
          ))?.then((_) {
        // Refresh attendance list when returning
        _controller.refreshAttendance();
      });
      return;
    }

    // If the attendance is asynchronous, go directly to student list
    if (isAsynchronous) {
      Get.to(() => ListOfStudents(
            subject: record['subject'],
            section: record['section'],
            date: formattedDate,
            attendanceId: record['id'],
            isSubmitted: isSubmitted,
            isAsynchronous: isAsynchronous,
            subjectId: record['class_schedule']?['subject_id'] ?? '',
          ))?.then((_) {
        // Refresh attendance list when returning
        _controller.refreshAttendance();
      });
      return;
    }

    // For face-to-face attendance, show the method selection dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.how_to_reg,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Attendance Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you like to mark attendance?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceMethodButton(
                    icon: Icons.edit_note,
                    label: 'Manual',
                    color: Colors.blue,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Get.to(() => ListOfStudents(
                            subject: record['subject'],
                            section: record['section'],
                            date: formattedDate,
                            attendanceId: record['id'],
                            isSubmitted: record['is_submitted'],
                            isAsynchronous: isAsynchronous,
                            subjectId:
                                record['class_schedule']?['subject_id'] ?? '',
                          ))?.then((_) {
                        // Refresh attendance list when returning
                        _controller.refreshAttendance();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAttendanceMethodButton(
                    icon: Icons.camera_alt,
                    label: 'Face Recognition',
                    color: Colors.green,
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Navigate to face recognition with attendance ID
                      Get.to(() =>
                              FaceRecognitionPage(attendanceId: record['id']))
                          ?.then((_) {
                        // Refresh attendance list when returning
                        _controller.refreshAttendance();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceMethodButton({
    required IconData icon,
    required String label,
    required Color color,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String attendanceId, bool isSubmitted) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Attendance?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this attendance record?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back(); // Close dialog first
                    await _controller.deleteAttendanceRecord(
                        attendanceId, isSubmitted);
                    await _controller.refreshAttendance(); // Refresh the list
                    showSuccess(message: 'Attendance deleted successfully.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
