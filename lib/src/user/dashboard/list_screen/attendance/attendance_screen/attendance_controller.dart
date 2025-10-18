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
      allAttendance.value = querySnapshot.docs
          .map((doc) => {
                'id': doc['id'],
                'date': doc['date'],
                'subject': doc['subject'],
                'section': doc['section'],
                'time': doc['time'],
                'is_submitted': doc['is_submitted'],
                'is_asynchronous': doc['is_asynchronous'],
                'status': doc['status'],
                'created_at': doc['created_at'],
                'class_schedule': doc['class_schedule'],
                'total_students': doc['total_students'],
                'present_count': doc['present_count'],
                'absent_count': doc['absent_count'],
              })
          .toList();
      log('Fetched ${allAttendance.length} attendance records from classAttendance');
    } catch (e) {
      log('Error fetching attendance records: $e');
    }
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
