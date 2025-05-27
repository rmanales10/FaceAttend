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
          .collection('users')
          .doc(currentUser!.uid)
          .collection('attendance')
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
              })
          .toList();
      // log('success : $allAttendance');
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> deleteAttendanceRecord(var attendanceId, var isSubmitted) async {
    !isSubmitted
        ? await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('attendance')
            .doc(attendanceId)
            .delete()
        : await _firestore.collection('record').doc(attendanceId).delete();
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('attendance')
        .doc(attendanceId)
        .delete();
  }
}
