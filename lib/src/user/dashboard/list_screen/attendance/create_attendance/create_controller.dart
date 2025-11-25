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

  Future<String?> createAttendance(
      {required var subject,
      required var section,
      required var date,
      required var time,
      required var isAsynchronous,
      required Map<String, dynamic> classSchedule}) async {
    try {
      // Format date to compare only the date part (without time)
      final dateOnly = DateTime(date.year, date.month, date.day);
      final startOfDay = Timestamp.fromDate(dateOnly);
      final endOfDay =
          Timestamp.fromDate(dateOnly.add(const Duration(days: 1)));

      // Check if attendance already exists for the same subject and date
      final existingQuery = await _firestore
          .collection('classAttendance')
          .where('class_schedule_id', isEqualTo: classSchedule['id'])
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .where('created_by', isEqualTo: currentUser!.uid)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Attendance already exists, return the existing ID
        final existingDoc = existingQuery.docs.first;
        final existingId = existingDoc.id;
        log('Attendance already exists for this subject and date. Using existing ID: $existingId');

        // Update the updated_at timestamp
        await _firestore.collection('classAttendance').doc(existingId).update({
          'updated_at': FieldValue.serverTimestamp(),
        });

        return existingId;
      }

      // No existing attendance found, create a new one
      String autoId = generateUniqueId();
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

      return autoId;
    } catch (e) {
      log('error $e');
      return null;
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
      if (currentUser == null) {
        log('No authenticated user');
        classSchedules.value = [];
        return;
      }

      // Filter class schedules by the current teacher's UID
      QuerySnapshot querySnapshot = await _firestore
          .collection('classSchedules')
          .where('teacher_id', isEqualTo: currentUser!.uid)
          .get();

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

      log('Fetched ${classSchedules.length} class schedules for teacher ${currentUser!.uid}');
    } catch (e) {
      log('Error fetching class schedules: $e');
      classSchedules.value = [];
    }
  }

  // Check if attendance exists for a given class schedule and date
  Future<String?> checkExistingAttendance({
    required String classScheduleId,
    required DateTime date,
  }) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final startOfDay = Timestamp.fromDate(dateOnly);
      final endOfDay =
          Timestamp.fromDate(dateOnly.add(const Duration(days: 1)));

      final existingQuery = await _firestore
          .collection('classAttendance')
          .where('class_schedule_id', isEqualTo: classScheduleId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .where('created_by', isEqualTo: currentUser!.uid)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return existingQuery.docs.first.id;
      }
      return null;
    } catch (e) {
      log('Error checking existing attendance: $e');
      return null;
    }
  }
}
