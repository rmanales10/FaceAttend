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

      // For now, use all students with the subject since section field doesn't exist
      // TODO: Add section field to student documents or use a different approach
      QuerySnapshot querySnapshot = allStudentsSnapshot;

      log('Using all students with subject (section filtering not available)');

      studentList.value = querySnapshot.docs.map((doc) {
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
        'is_submitted': false,
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error adding attendance record: $e');
    }
  }

  // Observable for attendance record
  RxMap<String, dynamic> attendaceStudentRecord = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> studentPrintList = <Map<String, dynamic>>[].obs;

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
