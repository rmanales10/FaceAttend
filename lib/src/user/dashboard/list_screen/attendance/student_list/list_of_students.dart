import 'dart:developer';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  final RxList<Map<String, dynamic>> studentRecord =
      <Map<String, dynamic>>[].obs;

  final RxList<bool> isPresent = <bool>[].obs;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    log('Loading students with:');
    log('Subject ID: ${widget.subjectId}');
    log('Section: ${widget.section}');
    log('Subject: ${widget.subject}');

    if (widget.subjectId.isNotEmpty) {
      await _controller.getStudentsList(
        section: widget.section,
        subject: widget.subject,
        subjectId: widget.subjectId,
      );

      log('Controller student list length: ${_controller.studentList.length}');

      // Initialize attendance status for each student (using growable list)
      isPresent.value =
          List.generate(_controller.studentList.length, (_) => false);
      // Initialize student records
      studentRecord.clear();
      for (var student in _controller.studentList) {
        studentRecord.add({
          'id': student['id'],
          'name': student['full_name'] ?? student['name'],
          'present': 'X',
        });
      }

      log('Student records initialized: ${studentRecord.length}');
    } else {
      log('Subject ID is empty, cannot load students');
    }
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoContainer('Subject:', widget.subject),
                      const SizedBox(width: 12),
                      _buildInfoContainer('Section:', widget.section),
                      const SizedBox(width: 12),
                      _buildInfoContainer('Date:', widget.date),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                if (!widget.isSubmitted)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceRecognitionPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.camera_enhance,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Face Recognition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                if (!widget.isSubmitted) const SizedBox(height: 16),
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
                        : 'Note! Generate to Word only',
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
                    onPressed: !widget.isSubmitted
                        ? () async {
                            await _profileController.fetchUserInfo();
                            await _controller.addAttendanceStudentRecord(
                              attendanceId: widget.attendanceId,
                              code: widget.subject.split(' ')[0],
                              datenow: widget.date,
                              room: '',
                              schedule: widget.date,
                              studentRecord: studentRecord,
                              subject: widget.subject,
                              teacher: _profileController.userInfo['fullname'],
                              section: widget.section,
                            );
                            Get.back();
                            showSuccess(
                                message: 'Attendance submitted successfully!');
                          }
                        : () async {
                            // Report generation removed
                            Get.back();
                            showSuccess(
                                message: 'Attendance already submitted!');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      !widget.isSubmitted ? 'Submit' : 'Generate Report...',
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
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Present ✓')),
            ],
            rows: data.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> student = entry.value;

              if (studentRecord.length < data.length) {
                studentRecord.add({
                  'id': student['id'],
                  'name': student['full_name'] ?? student['name'],
                  'present':
                      (index < isPresent.length && isPresent[index] == false)
                          ? 'X'
                          : '✓',
                });
              }

              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                    Text(student['full_name'] ?? student['name'] ?? 'N/A')),
                DataCell(widget.isSubmitted
                    ? Text(
                        student['present'] ?? 'N/A',
                        style: TextStyle(
                            color: student['present'] == '✓'
                                ? Colors.green
                                : Colors.red),
                      )
                    : Checkbox(
                        value:
                            index < isPresent.length ? isPresent[index] : false,
                        onChanged: (value) {
                          setState(() {
                            if (index < isPresent.length) {
                              isPresent[index] = value ?? false;
                            }
                          });

                          // Update student record with bounds checking
                          if (index < studentRecord.length) {
                            studentRecord[index]['present'] =
                                (index < isPresent.length &&
                                        isPresent[index] == false)
                                    ? 'X'
                                    : '✓';
                          }
                        },
                      )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
