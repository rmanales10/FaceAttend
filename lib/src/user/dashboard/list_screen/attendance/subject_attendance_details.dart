import 'dart:convert';
import 'dart:io';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SubjectAttendanceDetails extends StatefulWidget {
  final String subject;
  final List<Map<String, dynamic>> attendanceRecords;

  const SubjectAttendanceDetails({
    super.key,
    required this.subject,
    required this.attendanceRecords,
  });

  @override
  State<SubjectAttendanceDetails> createState() =>
      _SubjectAttendanceDetailsState();
}

class _SubjectAttendanceDetailsState extends State<SubjectAttendanceDetails> {
  bool _isGeneratingReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: Text(
          widget.subject,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: widget.attendanceRecords.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final controller = Get.find<AttendanceController>();
                        await controller.refreshAttendance();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = widget.attendanceRecords[index];

                          // Handle date field safely
                          String formattedDate = 'No date';
                          try {
                            if (record['date'] != null) {
                              if (record['date'] is Timestamp) {
                                final timestamp = record['date'] as Timestamp;
                                final dateTime = timestamp.toDate();
                                formattedDate =
                                    DateFormat('MMMM d, y').format(dateTime);
                              } else if (record['date'] is DateTime) {
                                formattedDate = DateFormat('MMMM d, y')
                                    .format(record['date'] as DateTime);
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
                              context: context,
                              record: record,
                              formattedDate: formattedDate,
                            ),
                            onDelete: () => _confirmDelete(
                              context: context,
                              attendanceId: record['id'],
                              isSubmitted: record['is_submitted'],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Save Report Button at the bottom
                  _buildSaveReportButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildSaveReportButton() {
    // Filter submitted attendance records and limit to 10
    final submittedRecords = widget.attendanceRecords
        .where((record) => record['is_submitted'] == true)
        .toList();

    // Sort by date (most recent first)
    submittedRecords.sort((a, b) {
      try {
        DateTime? dateA;
        DateTime? dateB;

        if (a['date'] is Timestamp) {
          dateA = (a['date'] as Timestamp).toDate();
        } else if (a['date'] is DateTime) {
          dateA = a['date'] as DateTime;
        }

        if (b['date'] is Timestamp) {
          dateB = (b['date'] as Timestamp).toDate();
        } else if (b['date'] is DateTime) {
          dateB = b['date'] as DateTime;
        }

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // Most recent first
      } catch (e) {
        return 0;
      }
    });

    final limitedRecords = submittedRecords.take(10).toList();

    if (limitedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGeneratingReport
                ? null
                : () => _generateCompleteReport(limitedRecords),
            icon: _isGeneratingReport
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, size: 20),
            label: Text(
              _isGeneratingReport
                  ? 'Generating Report...'
                  : 'Save Report (${limitedRecords.length} dates)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateCompleteReport(
      List<Map<String, dynamic>> records) async {
    if (records.isEmpty) {
      showError(message: 'No submitted attendance records found.');
      return;
    }

    setState(() {
      _isGeneratingReport = true;
    });

    try {
      // Extract attendance IDs
      final attendanceIds = records
          .map((record) => record['id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .toList();

      if (attendanceIds.isEmpty) {
        showError(message: 'No valid attendance IDs found.');
        return;
      }

      // Call the API endpoint
      const apiUrl =
          'https://ustp-face-attend.site/api/generate-complete-report';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'attendanceIds': attendanceIds}),
      );

      if (response.statusCode == 200) {
        // Save report record to Firestore FIRST (so it appears in Generated Reports)
        String? reportId;
        try {
          final firstRecord = records.first;
          final section = firstRecord['section'] ?? 'Unknown';
          final userId = FirebaseAuth.instance.currentUser?.uid;

          if (userId != null) {
            // Create a deterministic report ID based on sorted attendance IDs
            // This ensures the same set of attendance IDs always maps to the same report
            final sortedIds = List<String>.from(attendanceIds)..sort();
            final attendanceIdsHash = sortedIds.join('_');

            // Create a deterministic ID: complete_subject_section_attendanceIdsHash
            // This will be the same for the same subject, section, and attendance IDs
            final subjectKey =
                widget.subject.replaceAll(' ', '_').toLowerCase();
            final sectionKey = section.replaceAll(' ', '_').toLowerCase();
            reportId =
                'complete_${subjectKey}_${sectionKey}_${attendanceIdsHash.hashCode.abs()}';

            // Check if a report with the same attendance IDs already exists
            final existingReportQuery = await FirebaseFirestore.instance
                .collection('reports')
                .where('user_id', isEqualTo: userId)
                .where('type', isEqualTo: 'Complete Attendance Report')
                .where('subject', isEqualTo: widget.subject)
                .where('section', isEqualTo: section)
                .get();

            // Check if any existing report has the same attendance IDs
            bool reportExists = false;
            String? existingReportId;

            for (var doc in existingReportQuery.docs) {
              final existingAttendanceIds =
                  (doc.data()['attendance_id'] as String?)
                          ?.split(',')
                          .where((id) => id.isNotEmpty)
                          .toList() ??
                      [];

              // Sort and compare
              final existingSorted = List<String>.from(existingAttendanceIds)
                ..sort();
              if (existingSorted.length == sortedIds.length &&
                  existingSorted.every((id) => sortedIds.contains(id))) {
                reportExists = true;
                existingReportId = doc.id;
                break;
              }
            }

            // If report exists, update it; otherwise create new one
            final reportData = {
              'attendance_id':
                  attendanceIds.join(','), // Store all IDs as comma-separated
              'subject': widget.subject,
              'section': section,
              'date': DateFormat('MMMM d, y').format(DateTime.now()),
              'type': 'Complete Attendance Report',
              'url': '', // No URL since it's saved locally
              'user_id': userId,
              'updated_at': FieldValue.serverTimestamp(),
              'date_range': records.length > 1
                  ? '${records.length} dates'
                  : DateFormat('MMMM d, y').format(DateTime.now()),
            };

            if (reportExists && existingReportId != null) {
              // Update existing report
              await FirebaseFirestore.instance
                  .collection('reports')
                  .doc(existingReportId)
                  .update(reportData);
              reportId = existingReportId; // Use existing ID
            } else {
              // Create new report with deterministic ID
              reportData['created_at'] = FieldValue.serverTimestamp();
              await FirebaseFirestore.instance
                  .collection('reports')
                  .doc(reportId)
                  .set(reportData, SetOptions(merge: true));
            }
          }
        } catch (e) {
          // Log error but continue with file save
          print('Error saving report to Firestore: $e');
        }

        // Try to save file to app's documents directory (no special permissions needed)
        try {
          // Use application documents directory (works without special permissions)
          final directory = await getApplicationDocumentsDirectory();

          // Create a Reports subdirectory
          final reportsDir = Directory('${directory.path}/Reports');
          if (!await reportsDir.exists()) {
            await reportsDir.create(recursive: true);
          }

          // Generate filename in format: IT413_IT_ELECTIVE_2_BSIT4D.docx
          // Extract course code and subject name
          String courseCode = '';
          String subjectNameForFile = '';
          String sectionForFile = '';

          // Get section from first record
          if (records.isNotEmpty) {
            sectionForFile = (records.first['section'] ?? 'Unknown')
                .toString()
                .replaceAll(' ', '_')
                .toUpperCase();
          }

          // Extract course code and subject name from widget.subject
          // Format: "IT413 Social and Professional Issues"
          final subjectParts = widget.subject.split(' ');
          if (subjectParts.isNotEmpty) {
            courseCode = subjectParts[0].toUpperCase();
            if (subjectParts.length > 1) {
              // Get subject name without course code
              subjectNameForFile =
                  subjectParts.sublist(1).join('_').toUpperCase();
            } else {
              subjectNameForFile =
                  widget.subject.replaceAll(' ', '_').toUpperCase();
            }
          } else {
            courseCode = widget.subject.replaceAll(' ', '_').toUpperCase();
            subjectNameForFile = courseCode;
          }

          final fileName =
              '${courseCode}_${subjectNameForFile}_${sectionForFile}.docx';
          final filePath = '${reportsDir.path}/$fileName';

          // Save the file
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          showSuccess(
              message:
                  'Report saved successfully!\nYou can find it in Generated Reports or in the app\'s Documents folder.');
        } catch (e) {
          // If file save fails, still show success since it's saved to Firestore
          print('Error saving file: $e');
          showSuccess(
              message:
                  'Report saved to Generated Reports!\n(File save failed, but you can download it from Generated Reports)');
        }
      } else {
        final errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Failed to generate report. Status: ${response.statusCode}';
        showError(message: errorMessage);
      }
    } catch (e) {
      showError(message: 'Error generating report: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
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
            'No attendance records found for this subject.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
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
              // Section
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
                  Row(
                    children: [
                      _buildStatusChip(status, isSubmitted),
                      const SizedBox(width: 8),
                      _buildAttendanceTypeChip(isAsynchronous),
                    ],
                  ),
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
    required BuildContext context,
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
        final controller = Get.find<AttendanceController>();
        controller.refreshAttendance();
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
        final controller = Get.find<AttendanceController>();
        controller.refreshAttendance();
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
                        final controller = Get.find<AttendanceController>();
                        controller.refreshAttendance();
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
                        final controller = Get.find<AttendanceController>();
                        controller.refreshAttendance();
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

  void _confirmDelete(
      {required BuildContext context,
      required String attendanceId,
      required bool isSubmitted}) {
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
                    final controller = Get.find<AttendanceController>();
                    await controller.deleteAttendanceRecord(
                        attendanceId, isSubmitted);
                    await controller.refreshAttendance(); // Refresh the list
                    showSuccess(message: 'Attendance deleted successfully.');
                    // Navigate back to the attendance screen
                    Get.back();
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
