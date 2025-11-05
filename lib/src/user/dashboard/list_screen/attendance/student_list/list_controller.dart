import 'dart:developer';
import 'dart:math' as rnd;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:app_attend/src/services/notification_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/notifications/notification_controller.dart';

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
      // Calculate attendance statistics based on state
      int totalStudents = studentRecord.length;
      int presentCount = studentRecord
          .where((record) =>
              (record['state'] == 'Present' || record['status'] == 'present') &&
              record['state'] != 'Late' &&
              record['state'] != 'Absent')
          .length;
      int lateCount = studentRecord
          .where((record) =>
              record['state'] == 'Late' || record['status'] == 'late')
          .length;
      int absentCount = studentRecord
          .where((record) =>
              record['state'] == 'Absent' || record['status'] == 'absent')
          .length;

      log('Attendance Summary:');
      log('Total Students: $totalStudents');
      log('Present: $presentCount');
      log('Late: $lateCount');
      log('Absent: $absentCount');

      // Update student records to ensure status matches state
      for (var record in studentRecord) {
        String state = record['state'] ?? 'Absent';
        if (state == 'Absent') {
          record['status'] = 'absent';
          record['present'] = 'X';
        } else if (state == 'Late') {
          record['status'] = 'late';
          record['present'] = 'L';
        } else {
          // Present
          record['status'] = 'present';
          record['present'] = '✓';
        }
      }

      // Update the classAttendance document with student records and statistics
      await _firestore.collection('classAttendance').doc(attendanceId).update({
        'attendance_records': studentRecord,
        'total_students': totalStudents,
        'present_count': presentCount,
        'late_count': lateCount,
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

      // Create internal notification
      await _createInternalNotification(
        subject: subject,
        section: section,
        date: datenow,
        presentCount: presentCount,
        absentCount: absentCount,
        totalStudents: totalStudents,
      );

      // Send notifications after successful submission
      await _sendNotifications(
        subject: subject,
        section: section,
        date: datenow,
        teacherName: teacher,
        presentCount: presentCount,
        absentCount: absentCount,
        totalStudents: totalStudents,
        studentIds: studentRecord
            .map((r) => r['student_id'] ?? r['id'])
            .whereType<String>()
            .toList(),
      );
    } catch (e) {
      log('Error adding attendance record: $e');
    }
  }

  /// Send notifications to students and teacher
  Future<void> _sendNotifications({
    required String subject,
    required String section,
    required String date,
    required String teacherName,
    required int presentCount,
    required int absentCount,
    required int totalStudents,
    required List<String> studentIds,
  }) async {
    try {
      final notificationService = NotificationService();
      List<String> phoneNumbers = [];
      List<String> emailAddresses = [];

      // Get teacher contact info
      if (currentUser != null) {
        DocumentSnapshot teacherDoc =
            await _firestore.collection('users').doc(currentUser!.uid).get();

        if (teacherDoc.exists) {
          var teacherData = teacherDoc.data() as Map<String, dynamic>;
          String? teacherPhone = teacherData['phone']?.toString();
          String? teacherEmail = teacherData['email']?.toString();

          if (teacherPhone != null && teacherPhone.isNotEmpty) {
            phoneNumbers.add(teacherPhone);
          }
          if (teacherEmail != null && teacherEmail.isNotEmpty) {
            emailAddresses.add(teacherEmail);
          }
        }
      }

      // Get student contact info
      for (String studentId in studentIds) {
        try {
          DocumentSnapshot studentDoc =
              await _firestore.collection('students').doc(studentId).get();

          if (studentDoc.exists) {
            var studentData = studentDoc.data() as Map<String, dynamic>;
            String? studentPhone = studentData['phone']?.toString();
            String? studentEmail = studentData['email']?.toString();

            if (studentPhone != null && studentPhone.isNotEmpty) {
              phoneNumbers.add(studentPhone);
            }
            if (studentEmail != null && studentEmail.isNotEmpty) {
              emailAddresses.add(studentEmail);
            }
          }
        } catch (e) {
          log('Error fetching student contact info for $studentId: $e');
        }
      }

      // Send notifications if we have contact info
      if (phoneNumbers.isNotEmpty || emailAddresses.isNotEmpty) {
        log('Sending notifications to ${phoneNumbers.length} phone numbers and ${emailAddresses.length} email addresses');

        final results = await notificationService.sendAttendanceNotifications(
          phoneNumbers: phoneNumbers,
          emailAddresses: emailAddresses,
          subject: subject,
          section: section,
          date: date,
          teacherName: teacherName,
          presentCount: presentCount,
          absentCount: absentCount,
          totalStudents: totalStudents,
        );

        log('Notification results - SMS: ${results['sms']}, Email: ${results['email']}');
      } else {
        log('No contact information found for notifications');
      }
    } catch (e) {
      log('Error sending notifications: $e');
      // Don't throw - notifications are not critical for attendance submission
    }
  }

  /// Create internal notification for attendance submission
  Future<void> _createInternalNotification({
    required String subject,
    required String section,
    required String date,
    required int presentCount,
    required int absentCount,
    required int totalStudents,
  }) async {
    try {
      if (currentUser != null) {
        await NotificationController.createNotification(
          userId: currentUser!.uid,
          title: 'Attendance Submitted',
          message:
              '$subject ($section) - Present: $presentCount, Absent: $absentCount, Total: $totalStudents on $date',
          type: 'attendance',
          data: {
            'subject': subject,
            'section': section,
            'date': date,
            'present_count': presentCount,
            'absent_count': absentCount,
            'total_students': totalStudents,
          },
        );
        log('Internal notification created for attendance submission');
      }
    } catch (e) {
      log('Error creating internal notification: $e');
      // Don't throw - internal notifications are not critical
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

  // Save report to Firebase (for viewing in Generated Reports screen)
  Future<void> saveReportToFirebase({
    required String attendanceId,
    required String subject,
    required String section,
    required String date,
  }) async {
    try {
      await _firestore.collection('reports').doc(attendanceId).set({
        'attendance_id': attendanceId,
        'subject': subject,
        'section': section,
        'date': date,
        'type': 'Attendance Report',
        'url': '', // No URL for now, just displaying details
        'user_id': currentUser!.uid,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      log('Report saved successfully for attendance: $attendanceId');
    } catch (e) {
      log('Error saving report: $e');
      rethrow;
    }
  }
}
