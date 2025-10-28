import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> allAttendance = <Map<String, dynamic>>[].obs;
  Future<void> getAllAttendance() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('classAttendance')
          .where('created_by', isEqualTo: currentUser!.uid)
          .orderBy('created_at', descending: true)
          .get();

      allAttendance.value = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': data['id'] ?? doc.id,
          'date': data['date'],
          'subject': data['subject'],
          'section': data['section'],
          'time': data['time'],
          'is_submitted': data['is_submitted'] ?? false,
          'is_asynchronous': data['is_asynchronous'] ?? false,
          'status': data['status'] ?? 'pending',
          'created_at': data['created_at'],
          'class_schedule': data['class_schedule'],
          'total_students': data['total_students'] ?? 0,
          'present_count': data['present_count'] ?? 0,
          'absent_count': data['absent_count'] ?? 0,
          'schedule_id': data['class_schedule_id'] ?? '',
        };
      }).toList();

      log('Fetched ${allAttendance.length} attendance records from classAttendance');
    } catch (e) {
      log('Error fetching attendance records: $e');
      allAttendance.clear();
    }
  }

  Future<void> refreshAttendance() async {
    await getAllAttendance();
  }

  Future<void> deleteAttendanceRecord(var attendanceId, var isSubmitted) async {
    try {
      if (!isSubmitted) {
        // Delete from classAttendance collection
        await _firestore
            .collection('classAttendance')
            .doc(attendanceId)
            .delete();
        log('Deleted attendance record: $attendanceId');
      } else {
        // If submitted, also delete from record collection
        await _firestore.collection('record').doc(attendanceId).delete();
        await _firestore
            .collection('classAttendance')
            .doc(attendanceId)
            .delete();
        log('Deleted submitted attendance record: $attendanceId');
      }
    } catch (e) {
      log('Error deleting attendance record: $e');
    }
  }
}
