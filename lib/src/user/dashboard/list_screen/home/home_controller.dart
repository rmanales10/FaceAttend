import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> allRecord = <Map<String, dynamic>>[].obs;
  Future<void> fetchAllRecord() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('record')
        .where('user_id', isEqualTo: currentUser!.uid)
        .get();
    allRecord.value = querySnapshot.docs
        .map((doc) => {
              'section': doc['section'],
              'datenow': doc['datenow'],
              'subject': doc['subject'],
              'student_record': doc['student_record'],
            })
        .toList();
    log('$allRecord');
  }

  RxList<Map<String, dynamic>> allAttendance = <Map<String, dynamic>>[].obs;
  Future<void> fetchAllAttendance() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('attendance')
        .get();
    allRecord.value = querySnapshot.docs
        .map((doc) => {
              'date': doc['date'],
              'id': doc['id'],
              'is_submitted': doc['is_submitted'],
              'section': doc['section'],
              'subject': doc['subject'],
              'time': doc['time'],
            })
        .toList();
  }

  RxList<Map<String, dynamic>> subjectOnly = <Map<String, dynamic>>[].obs;
  Future<void> fetchSubjectOnly({required var subject}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('record')
        .where('subject', isEqualTo: subject)
        .where('user_id', isEqualTo: currentUser!.uid)
        .get();
    subjectOnly.value = querySnapshot.docs
        .map((doc) => {
              'student_record': doc['student_record'],
            })
        .toList();
    log('$subjectOnly');
  }

  RxList<Map<String, dynamic>> holidays = <Map<String, dynamic>>[].obs;

  Future<void> fetchHolidays() async {
    QuerySnapshot querySnapshot = await _firestore.collection('holidays').get();
    holidays.value = querySnapshot.docs.map((doc) {
      Timestamp timestamp = doc['date'];
      DateTime date = timestamp.toDate();
      return {
        'date': date,
        'notes': doc['name'],
      };
    }).toList();
  }
}
