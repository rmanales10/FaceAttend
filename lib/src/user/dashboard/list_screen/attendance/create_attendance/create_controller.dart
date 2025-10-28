import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:math' as rnd;

class CreateController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'attendance-$randomNumber';
  }

  Future<void> createAttendance(
      {required var subject,
      required var section,
      required var date,
      required var time,
      required var isAsynchronous,
      required Map<String, dynamic> classSchedule}) async {
    String autoId = generateUniqueId();
    try {
      await _firestore.collection('classAttendance').doc(autoId).set({
        'id': autoId,
        'created_by': currentUser!.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'section': section,
        'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
        'time': time,
        'subject': subject,
        'is_submitted': false,
        'is_asynchronous': isAsynchronous,
        'status': 'pending', // pending, active, completed
        'class_schedule_id': classSchedule['id'],
        'class_schedule': {
          'subject_id': classSchedule['subject_id'],
          'subject_name': classSchedule['subject_name'],
          'course_code': classSchedule['course_code'],
          'course_year': classSchedule['course_year'],
          'year_level': classSchedule['year_level'],
          'schedule': classSchedule['schedule'],
          'building_room': classSchedule['building_room'],
          'teacher_id': classSchedule['teacher_id'],
          'teacher_name': classSchedule['teacher_name'],
          'department': classSchedule['department'],
        },
        'attendance_records': [], // Array to store student attendance records
        'total_students': 0,
        'present_count': 0,
        'absent_count': 0,
      }, SetOptions(merge: true));
    } catch (e) {
      log('error $e');
    }
  }

  RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  Future<void> fetchSubject({required var department}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('subjects')
        .where('department', isEqualTo: department)
        .get();
    subjects.value = querySnapshot.docs
        .map((doc) => {
              'id': doc['id'],
              'course_code': doc['course_code'],
              'department': doc['department'],
              'subject_name': doc['subject_name'],
            })
        .toList();
  }

  RxList<Map<String, dynamic>> sections = <Map<String, dynamic>>[].obs;
  Future<void> fetchSection({required var subject}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('students')
        .where('subject', arrayContains: subject)
        .get();
    sections.value = querySnapshot.docs
        .map((doc) => {
              'section_year_block': doc['section_year_block'],
            })
        .toList();
    log('$subject');
    log('$sections');
  }

  // Class schedules
  RxList<Map<String, dynamic>> classSchedules = <Map<String, dynamic>>[].obs;
  Future<void> fetchAllClassSchedules() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('classSchedules').get();

      classSchedules.value = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'subject_id': doc['subject_id'],
                'subject_name': doc['subject_name'],
                'course_code': doc['course_code'],
                'course_year': doc['course_year'],
                'year_level': doc['year_level'],
                'schedule': doc['schedule'],
                'building_room': doc['building_room'],
                'teacher_id': doc['teacher_id'],
                'teacher_name': doc['teacher_name'],
                'department': doc['department'],
                'created_at': doc['created_at'],
                'updated_at': doc['updated_at'],
              })
          .toList();

      log('Fetched ${classSchedules.length} class schedules');
    } catch (e) {
      log('Error fetching class schedules: $e');
      classSchedules.value = [];
    }
  }
}
