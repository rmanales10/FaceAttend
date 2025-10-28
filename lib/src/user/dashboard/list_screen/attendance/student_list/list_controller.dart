import 'dart:developer';
import 'dart:math' as rnd;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  // Generate a unique ID for records
  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'record-$randomNumber';
  }

  // Observable student list
  RxList<Map<String, dynamic>> studentList = <Map<String, dynamic>>[].obs;

  // Get the list of students based on subject
  Future<void> getStudentsList({
    required var section,
    required var subject,
    required String subjectId,
  }) async {
    try {
      log('Searching for students with:');
      log('Section: $section');
      log('Subject: $subject');
      log('Subject ID: $subjectId');

      // First, let's try without section filter to see if students exist
      QuerySnapshot allStudentsSnapshot = await _firestore
          .collection('students')
          .where('subject', arrayContains: subjectId)
          .get();

      log('Found ${allStudentsSnapshot.docs.length} students with subject ID: $subjectId');

      // Debug: Check what fields are available in student documents
      if (allStudentsSnapshot.docs.isNotEmpty) {
        var firstStudent = allStudentsSnapshot.docs.first;
        var studentData = firstStudent.data() as Map<String, dynamic>?;
        if (studentData != null) {
          log('First student fields: ${studentData.keys.toList()}');
          log('First student data: $studentData');
        }
      }

      // Filter students by section using section_year_block field
      // The section parameter should match the student's section_year_block
      log('Filtering students by section: $section');

      studentList.value = allStudentsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'section_year_block':
              data['section_year_block'] ?? data['course_year'] ?? 'Unknown',
          'subject': data['subject'],
          'full_name': data['full_name'],
          'block': data['block'],
          'department': data['department'],
          'year_level': data['year_level'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
        };
      }).where((student) {
        // Filter by matching section_year_block to the provided section
        String studentSection = (student['section_year_block'] ?? '')
            .toString()
            .trim()
            .toUpperCase();
        String targetSection = section.toString().trim().toUpperCase();

        // Generate fallback section if section_year_block is missing
        if (studentSection.isEmpty || studentSection == 'UNKNOWN') {
          String department = (student['department'] ?? '').toString();
          String departmentCode = department.split(' - ').isNotEmpty
              ? department.split(' - ')[0].trim()
              : '';
          String yearLevel = (student['year_level'] ?? '').toString();
          String yearNumber = yearLevel.contains('1st')
              ? '1'
              : yearLevel.contains('2nd')
                  ? '2'
                  : yearLevel.contains('3rd')
                      ? '3'
                      : '4';
          String block = (student['block'] ?? '').toString();
          studentSection =
              '$departmentCode $yearNumber$block'.trim().toUpperCase();
        }

        log('Comparing student section "$studentSection" with target "$targetSection"');
        return studentSection == targetSection;
      }).toList();

      log('Final student list: ${studentList.length} students');
      for (var student in studentList) {
        log('Student: ${student['full_name']}, Section: ${student['section_year_block']}, Block: ${student['block']}');
      }
    } catch (e) {
      log('Error fetching student list: $e');
    }
  }

  // Add attendance student record
  Future<void> addAttendanceStudentRecord({
    required var attendanceId,
    required var code,
    required var datenow,
    required var room,
    required var schedule,
    required var studentRecord,
    required var subject,
    required var teacher,
    required var section,
  }) async {
    try {
      // Calculate attendance statistics
      int totalStudents = studentRecord.length;
      int presentCount =
          studentRecord.where((record) => record['present'] == '✓').length;
      int absentCount = totalStudents - presentCount;

      log('Attendance Summary:');
      log('Total Students: $totalStudents');
      log('Present: $presentCount');
      log('Absent: $absentCount');

      // Update the classAttendance document with student records and statistics
      await _firestore.collection('classAttendance').doc(attendanceId).update({
        'attendance_records': studentRecord,
        'total_students': totalStudents,
        'present_count': presentCount,
        'absent_count': absentCount,
        'is_submitted': true,
        'status': 'completed',
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Also save to record collection for backward compatibility
      await _firestore.collection('record').doc(attendanceId).set({
        'attendance_id': attendanceId,
        'code': code,
        'datenow': datenow,
        'room': room,
        'schedule': schedule,
        'student_record': studentRecord,
        'subject': subject,
        'teacher': teacher,
        'user_id': currentUser!.uid,
        'section': section,
        'is_submitted': true,
      }, SetOptions(merge: true));

      log('Attendance records saved successfully!');
    } catch (e) {
      log('Error adding attendance record: $e');
    }
  }

  // Observable for attendance record
  RxMap<String, dynamic> attendaceStudentRecord = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> studentPrintList = <Map<String, dynamic>>[].obs;

  // Get existing attendance records for a specific attendance ID
  Future<List<Map<String, dynamic>>> getExistingAttendanceRecords({
    required String attendanceId,
  }) async {
    try {
      log('Fetching existing attendance records for ID: $attendanceId');

      DocumentSnapshot documentSnapshot = await _firestore
          .collection('classAttendance')
          .doc(attendanceId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;

        // Check if attendance_records field exists
        if (data['attendance_records'] != null) {
          final List<dynamic> rawRecords = data['attendance_records'];
          var records = rawRecords
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          log('Found ${records.length} existing attendance records');
          return records;
        }
      }

      log('No existing attendance records found');
      return [];
    } catch (e) {
      log('Error fetching existing attendance records: $e');
      return [];
    }
  }

  // Get and print attendance student record
  Future<void> printAttendanceStudentRecord({
    required var attendanceId,
  }) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('record').doc(attendanceId).get();

      if (documentSnapshot.exists) {
        attendaceStudentRecord.value =
            documentSnapshot.data() as Map<String, dynamic>;

        // Extract and process student_record
        if (attendaceStudentRecord['student_record'] != null) {
          final List<dynamic> rawStudentList =
              attendaceStudentRecord['student_record'];
          studentPrintList.value = rawStudentList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          // log('Student List: $studentPrintList');
        }
      }
    } catch (e) {
      log('Error fetching attendance record: $e');
    }
  }

  // Mark record as submitted
  Future<void> isSubmitted({
    required var attendanceId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('attendance')
          .doc(attendanceId)
          .set({'is_submitted': true}, SetOptions(merge: true));
    } catch (e) {
      log('Error updating submission status: $e');
    }
  }

  Future<void> storedUrl({
    required var attendanceId,
    required var subject,
    required var section,
    required var date,
    required var type,
    required var url,
  }) async {
    await _firestore.collection('reports').doc(attendanceId).set({
      'attendance_id': attendanceId,
      'subject': subject,
      'section': section,
      'date': date,
      'type': type,
      'url': url,
      'user_id': currentUser!.uid,
    }, SetOptions(merge: true));
  }
}
