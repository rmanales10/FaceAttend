import 'dart:developer';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ListOfStudents extends StatefulWidget {
  final String subject;
  final String section;
  final String date;
  final String attendanceId;
  final bool isSubmitted;
  final bool isAsynchronous;
  final String subjectId;

  const ListOfStudents({
    super.key,
    required this.subject,
    required this.section,
    required this.date,
    required this.attendanceId,
    required this.isSubmitted,
    required this.isAsynchronous,
    required this.subjectId,
  });

  @override
  State<ListOfStudents> createState() => _ListOfStudentsState();
}

class _ListOfStudentsState extends State<ListOfStudents> {
  final _controller = Get.put(ListController());
  final _profileController = Get.put(ProfileController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> studentRecord =
      <Map<String, dynamic>>[].obs;

  final RxList<bool> isPresent = <bool>[].obs;

  Map<String, dynamic>? attendanceData;
  int lateMinutes = 30; // Default late minutes
  bool _isSubmitting = false; // Loading state for submit button

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadSettings();
    _loadAttendanceData();
  }

  Future<void> _loadSettings() async {
    try {
      final querySnapshot = await _firestore.collection('settings').get();
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          lateMinutes = data['late_minutes'] ?? 30;
        });
      }
    } catch (e) {
      log('Error loading settings: $e');
    }
  }

  Future<void> _loadAttendanceData() async {
    try {
      final doc = await _firestore
          .collection('classAttendance')
          .doc(widget.attendanceId)
          .get();
      if (doc.exists) {
        setState(() {
          attendanceData = doc.data();
        });
      }
    } catch (e) {
      log('Error loading attendance data: $e');
    }
  }

  DateTime? _parseScheduleTime(String? scheduleString) {
    if (scheduleString == null || scheduleString.isEmpty) return null;

    try {
      // Parse schedule like "Wed 1:31 AM - 1:30 AM" or "Mon 2:00 PM - 3:30 PM"
      // Extract the start time (first time in the string)
      final regex =
          RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
      final match = regex.firstMatch(scheduleString);

      if (match == null) return null;

      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!.toUpperCase();

      // Convert to 24-hour format
      int hour24 = hour;
      if (period == 'PM' && hour != 12) {
        hour24 = hour + 12;
      } else if (period == 'AM' && hour == 12) {
        hour24 = 0;
      }

      // Get today's date
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour24, minute);
    } catch (e) {
      log('Error parsing schedule time: $e');
      return null;
    }
  }

  bool _isLate(DateTime currentTime) {
    if (attendanceData == null) return false;

    // Get schedule from class_schedule
    final classSchedule = attendanceData!['class_schedule'];
    if (classSchedule == null) return false;

    final scheduleString = classSchedule['schedule'] as String?;
    if (scheduleString == null) return false;

    final scheduleStartTime = _parseScheduleTime(scheduleString);
    if (scheduleStartTime == null) return false;

    // Calculate late threshold
    final lateThreshold = scheduleStartTime.add(Duration(minutes: lateMinutes));

    return currentTime.isAfter(lateThreshold);
  }

  Future<void> _loadStudents() async {
    log('Loading students with:');
    log('Subject ID: ${widget.subjectId}');
    log('Section: ${widget.section}');
    log('Subject: ${widget.subject}');
    log('Attendance ID: ${widget.attendanceId}');

    if (widget.subjectId.isNotEmpty) {
      await _controller.getStudentsList(
        section: widget.section,
        subject: widget.subject,
        subjectId: widget.subjectId,
      );

      log('Controller student list length: ${_controller.studentList.length}');

      // Load existing attendance records
      final existingRecords = await _controller.getExistingAttendanceRecords(
        attendanceId: widget.attendanceId,
      );

      log('Existing attendance records: ${existingRecords.length}');

      // Create a map for quick lookup of existing attendance
      Map<String, dynamic> existingAttendanceMap = {};
      for (var record in existingRecords) {
        final studentId = record['student_id'] ?? record['id'];
        if (studentId != null) {
          existingAttendanceMap[studentId] = record;
        }
      }

      // Initialize attendance status for each student
      isPresent.value =
          List.generate(_controller.studentList.length, (_) => false);

      // Initialize student records and check existing attendance
      studentRecord.clear();
      for (int i = 0; i < _controller.studentList.length; i++) {
        var student = _controller.studentList[i];
        final studentId = student['id'];

        // Check if this student has existing attendance record
        bool isAlreadyPresent = false;
        String presentStatus = 'X';

        if (existingAttendanceMap.containsKey(studentId)) {
          var existingRecord = existingAttendanceMap[studentId];
          final status = existingRecord['status'] ?? existingRecord['present'];

          // Check if student is marked as present, late, or excuse
          if (status == 'present' || status == '✓') {
            isAlreadyPresent = true;
            presentStatus = '✓';
            isPresent[i] = true;
            log('Student ${student['full_name']} is already marked as present');
          } else if (status == 'late' || status == 'L') {
            isAlreadyPresent = true;
            presentStatus = 'L';
            isPresent[i] = true;
            log('Student ${student['full_name']} is already marked as late');
          } else if (status == 'excuse' || status == 'E') {
            isAlreadyPresent = true;
            presentStatus = 'E';
            isPresent[i] = true;
            log('Student ${student['full_name']} is already marked as excuse');
          }
        }

        // Get attendance type from existing record (face or manual)
        String attendanceType = 'manual';
        String timeIn = '';
        if (existingAttendanceMap.containsKey(studentId)) {
          var existingRecord = existingAttendanceMap[studentId];
          attendanceType = existingRecord['attendance_type'] ?? 'manual';
          // Get existing time_in if available
          if (existingRecord['time_in'] != null) {
            timeIn = existingRecord['time_in'];
          } else if (existingRecord['timestamp'] != null) {
            // Convert timestamp to readable time format
            var timestamp = existingRecord['timestamp'];
            if (timestamp is Timestamp) {
              timeIn = _formatTime(timestamp.toDate());
            }
          }
        }

        // Determine initial state (if already present, check if they were late or excuse)
        String initialState = 'Absent';
        if (existingAttendanceMap.containsKey(studentId)) {
          var existingRecord = existingAttendanceMap[studentId];
          // Check state field first, then fall back to status
          if (existingRecord['state'] != null) {
            initialState = existingRecord['state'].toString();
          } else if (existingRecord['status'] == 'late') {
            initialState = 'Late';
            presentStatus = 'L';
          } else if (existingRecord['status'] == 'excuse') {
            initialState = 'Excuse';
            presentStatus = 'E';
          } else if (existingRecord['status'] == 'present') {
            initialState = 'Present';
            presentStatus = '✓';
          } else {
            initialState = 'Absent';
            presentStatus = 'X';
          }
        }

        // Ensure presentStatus matches initialState
        if (initialState == 'Late') {
          presentStatus = 'L';
        } else if (initialState == 'Excuse') {
          presentStatus = 'E';
        } else if (initialState == 'Present') {
          presentStatus = '✓';
        } else {
          presentStatus = 'X';
        }

        studentRecord.add({
          'id': studentId,
          'student_id': studentId,
          'name': student['full_name'] ?? student['name'],
          'student_name': student['full_name'] ?? student['name'],
          'present': presentStatus,
          'status': isAlreadyPresent
              ? (initialState == 'Late'
                  ? 'late'
                  : initialState == 'Excuse'
                      ? 'excuse'
                      : initialState == 'Present'
                          ? 'present'
                          : 'absent')
              : 'absent',
          'state': initialState,
          'attendance_type': attendanceType,
          'time_in': timeIn,
        });
      }

      log('Student records initialized: ${studentRecord.length}');
      log('Students marked present: ${isPresent.where((p) => p).length}');
    } else {
      log('Subject ID is empty, cannot load students');
    }
  }

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info, color: blue, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Attendance Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Subject
            _buildDetailRow(
              icon: Icons.book,
              label: 'Subject',
              value: widget.subject,
            ),
            const SizedBox(height: 16),
            // Section
            _buildDetailRow(
              icon: Icons.group,
              label: 'Section',
              value: widget.section,
            ),
            const SizedBox(height: 16),
            // Date
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: widget.date,
            ),
            const SizedBox(height: 16),
            // Status
            _buildDetailRow(
              icon: Icons.check_circle,
              label: 'Status',
              value: widget.isSubmitted ? 'Submitted' : 'Draft',
              valueColor: widget.isSubmitted ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            // Attendance Mode
            _buildDetailRow(
              icon: Icons.settings,
              label: 'Mode',
              value: widget.isAsynchronous ? 'Asynchronous' : 'Synchronous',
            ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  String _formatDateForDisplay(String dateString) {
    try {
      // Try to parse the date string in various formats
      DateTime? date;

      // Try MM/dd/yyyy format first
      try {
        date = DateFormat('MM/dd/yyyy').parse(dateString);
      } catch (e) {
        // Try MMMM d, y format (e.g., "November 25, 2025")
        try {
          date = DateFormat('MMMM d, y').parse(dateString);
        } catch (e2) {
          // Try yyyy-MM-dd format
          try {
            date = DateFormat('yyyy-MM-dd').parse(dateString);
          } catch (e3) {
            // If all parsing fails, return original string
            return dateString;
          }
        }
      }

      // Format to MM/dd/yyyy
      return DateFormat('MM/dd/yyyy').format(date);
    } catch (e) {
      // If any error occurs, return the original string
      return dateString;
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
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
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: blue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'List of Students',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Compact info card with tap to expand
                GestureDetector(
                  onTap: () => _showDetailsModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.book, color: blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subject:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subject.split(' ')[0], // Show only code
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.section,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.green[700],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateForDisplay(widget.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          color: blue,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend for attendance type icons
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.blue, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Face Recognition',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.touch_app, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Manual',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    final studentList = _controller.studentList;

                    // Ensure isPresent list is synchronized with student list
                    if (isPresent.length != studentList.length) {
                      isPresent.value =
                          List.generate(studentList.length, (_) => false);
                    }

                    _controller.printAttendanceStudentRecord(
                        attendanceId: widget.attendanceId);
                    final Map<String, dynamic> printList =
                        _controller.attendaceStudentRecord;

                    if (printList.containsKey('student_record') &&
                        printList['student_record'] != null) {
                      final List<dynamic> rawStudentList =
                          printList['student_record'];
                      final List<Map<String, dynamic>> studentPrintList =
                          rawStudentList
                              .map((e) => Map<String, dynamic>.from(e as Map))
                              .toList();

                      if (widget.isSubmitted) {
                        return _buildScrollableTable(studentPrintList, size);
                      }
                    }
                    return _buildScrollableTable(_controller.studentList, size);
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    !widget.isSubmitted
                        ? 'Note! You can only submit once'
                        : 'Note! Save to view in Generated Reports',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() {
                              _isSubmitting = true;
                            });

                            try {
                              if (!widget.isSubmitted) {
                                await _profileController.fetchUserInfo();
                                await _controller.addAttendanceStudentRecord(
                                  attendanceId: widget.attendanceId,
                                  code: widget.subject.split(' ')[0],
                                  datenow: widget.date,
                                  room: '',
                                  schedule: widget.date,
                                  studentRecord: studentRecord,
                                  subject: widget.subject,
                                  teacher:
                                      _profileController.userInfo['fullname'],
                                  section: widget.section,
                                );

                                // Refresh attendance list after submission
                                try {
                                  if (Get.isRegistered<
                                      AttendanceController>()) {
                                    await Get.find<AttendanceController>()
                                        .refreshAttendance();
                                  }
                                } catch (e) {
                                  log('Error refreshing attendance: $e');
                                }

                                Get.back();
                                showSuccess(
                                    message:
                                        'Attendance submitted successfully!');
                              } else {
                                // Save report to Firebase
                                await _controller.saveReportToFirebase(
                                  attendanceId: widget.attendanceId,
                                  subject: widget.subject,
                                  section: widget.section,
                                  date: widget.date,
                                );

                                // Refresh attendance list after saving report
                                try {
                                  if (Get.isRegistered<
                                      AttendanceController>()) {
                                    await Get.find<AttendanceController>()
                                        .refreshAttendance();
                                  }
                                } catch (e) {
                                  log('Error refreshing attendance: $e');
                                }

                                Get.back();
                                showSuccess(
                                    message: 'Report saved successfully!');
                              }
                            } catch (e) {
                              showError(message: 'Error: ${e.toString()}');
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSubmitting = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSubmitting ? blue.withOpacity(0.6) : blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      disabledBackgroundColor: blue.withOpacity(0.6),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            !widget.isSubmitted ? 'Submit' : 'Save Report',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableTable(List<Map<String, dynamic>> data, Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: size.width,
            maxWidth:
                800, // Maximum width to allow horizontal scroll on smaller screens
          ),
          child: DataTable(
            columnSpacing: 12,
            columns: [
              DataColumn(
                label: SizedBox(
                  width: 40,
                  child: Text('No.', overflow: TextOverflow.ellipsis),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 120,
                  child: Text('Name', overflow: TextOverflow.ellipsis),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 60,
                  child: Text('Status', overflow: TextOverflow.ellipsis),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 80,
                  child: Text('Time In', overflow: TextOverflow.ellipsis),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 80,
                  child: Text('State', overflow: TextOverflow.ellipsis),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: 60,
                  child: Text('Type', overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            rows: data.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> student = entry.value;

              return DataRow(cells: [
                DataCell(
                  SizedBox(
                    width: 40,
                    child: Text('${index + 1}'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      student['full_name'] ?? student['name'] ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 60,
                    child: widget.isSubmitted
                        ? Builder(
                            builder: (context) {
                              if (index >= studentRecord.length) {
                                return Text('N/A');
                              }

                              String state =
                                  studentRecord[index]['state'] ?? 'Absent';
                              String statusDisplay;
                              Color statusColor;

                              if (state == 'Present') {
                                statusDisplay = '✓';
                                statusColor = Colors.green;
                              } else if (state == 'Late') {
                                statusDisplay = 'L';
                                statusColor = Colors.orange;
                              } else {
                                statusDisplay = 'X';
                                statusColor = Colors.red;
                              }

                              return Text(
                                statusDisplay,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            },
                          )
                        : Checkbox(
                            value: index < isPresent.length
                                ? isPresent[index]
                                : false,
                            onChanged: (value) {
                              setState(() {
                                if (index < isPresent.length) {
                                  isPresent[index] = value ?? false;
                                }
                              });

                              // Update student record with bounds checking
                              if (index < studentRecord.length) {
                                // When manually checked, determine if late or present
                                if (value == true) {
                                  final now = DateTime.now();
                                  final isLate = _isLate(now);

                                  if (isLate) {
                                    studentRecord[index]['status'] = 'late';
                                    studentRecord[index]['state'] = 'Late';
                                    studentRecord[index]['present'] = 'L';
                                  } else {
                                    studentRecord[index]['status'] = 'present';
                                    studentRecord[index]['state'] = 'Present';
                                    studentRecord[index]['present'] = '✓';
                                  }
                                  studentRecord[index]['time_in'] =
                                      _formatTime(now);
                                } else {
                                  studentRecord[index]['status'] = 'absent';
                                  studentRecord[index]['state'] = 'Absent';
                                  studentRecord[index]['present'] = 'X';
                                  studentRecord[index]['time_in'] = '';
                                }
                                // When manually checked, mark as manual type
                                studentRecord[index]['attendance_type'] =
                                    'manual';
                              }
                            },
                          ),
                  ),
                ),
                // Time In column
                DataCell(
                  SizedBox(
                    width: 80,
                    child: Text(
                      index < studentRecord.length
                          ? (studentRecord[index]['time_in'] ?? '')
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: (index < studentRecord.length &&
                                studentRecord[index]['time_in'] != null &&
                                studentRecord[index]['time_in']
                                    .toString()
                                    .isNotEmpty)
                            ? Colors.blue[700]
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // State column with dropdown
                DataCell(
                  SizedBox(
                    width: 80,
                    child: widget.isSubmitted
                        ? Text(
                            index < studentRecord.length
                                ? (studentRecord[index]['state'] ?? 'Absent')
                                : 'Absent',
                            style: TextStyle(
                              fontSize: 12,
                              color: index < studentRecord.length &&
                                      studentRecord[index]['state'] == 'Late'
                                  ? Colors.orange[700]
                                  : index < studentRecord.length &&
                                          studentRecord[index]['state'] ==
                                              'Present'
                                      ? Colors.green[700]
                                      : index < studentRecord.length &&
                                              studentRecord[index]['state'] ==
                                                  'Excuse'
                                          ? Colors.purple[700]
                                          : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : index < studentRecord.length
                            ? DropdownButton<String>(
                                value:
                                    studentRecord[index]['state'] ?? 'Absent',
                                isExpanded: true,
                                underline: Container(),
                                items: ['Present', 'Late', 'Absent', 'Excuse']
                                    .map((String value) {
                                  Color textColor;
                                  if (value == 'Late') {
                                    textColor = Colors.orange[700]!;
                                  } else if (value == 'Present') {
                                    textColor = Colors.green[700]!;
                                  } else if (value == 'Excuse') {
                                    textColor = Colors.purple[700]!;
                                  } else {
                                    textColor = Colors.red[700]!;
                                  }
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      index < studentRecord.length) {
                                    setState(() {
                                      studentRecord[index]['state'] = newValue;

                                      // Update checkbox and status based on state
                                      if (newValue == 'Absent') {
                                        // Uncheck the checkbox
                                        if (index < isPresent.length) {
                                          isPresent[index] = false;
                                        }
                                        studentRecord[index]['present'] = 'X';
                                        studentRecord[index]['status'] =
                                            'absent';
                                        studentRecord[index]['time_in'] = '';
                                      } else {
                                        // Check the checkbox
                                        if (index < isPresent.length) {
                                          isPresent[index] = true;
                                        }

                                        // Update status and present symbol based on state
                                        if (newValue == 'Late') {
                                          studentRecord[index]['status'] =
                                              'late';
                                          studentRecord[index]['present'] = 'L';
                                        } else if (newValue == 'Excuse') {
                                          studentRecord[index]['status'] =
                                              'excuse';
                                          studentRecord[index]['present'] = 'E';
                                        } else {
                                          studentRecord[index]['status'] =
                                              'present';
                                          studentRecord[index]['present'] = '✓';
                                        }

                                        // Record time when marking as present/late/excuse
                                        if (studentRecord[index]['time_in'] ==
                                                null ||
                                            studentRecord[index]['time_in']
                                                .toString()
                                                .isEmpty) {
                                          studentRecord[index]['time_in'] =
                                              _formatTime(DateTime.now());
                                        }
                                      }

                                      // Mark as manual type when changed via dropdown
                                      studentRecord[index]['attendance_type'] =
                                          'manual';
                                    });
                                  }
                                },
                              )
                            : Text(
                                'Absent',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                  ),
                ),
                // Type column with icon
                DataCell(
                  SizedBox(
                    width: 30,
                    child: index < studentRecord.length
                        ? Icon(
                            studentRecord[index]['attendance_type'] == 'face'
                                ? Icons.camera_alt
                                : Icons.touch_app,
                            color: studentRecord[index]['attendance_type'] ==
                                    'face'
                                ? Colors.blue
                                : Colors.orange,
                            size: 20,
                          )
                        : Icon(Icons.touch_app, color: Colors.orange, size: 20),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
