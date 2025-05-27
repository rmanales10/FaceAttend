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

  // Get the list of students
  Future<void> getStudentsList({
    required var section,
    required var subject,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('students')
          .where('section_year_block', isEqualTo: section)
          .get();

      studentList.value = querySnapshot.docs
          .map((doc) => {
                'id': doc['id'],
                'section_year_block': doc['section_year_block'],
                'subject': doc['subject'],
                'full_name': doc['full_name'],
              })
          .toList();
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
