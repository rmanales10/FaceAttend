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
      required var isAsynchronous}) async {
    String autoId = generateUniqueId();
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('attendance')
          .doc(autoId)
          .set({
        'id': autoId,
        'section': section,
        'date': date,
        'time': time,
        'subject': subject,
        'is_submitted': false,
        'is_asynchronous': isAsynchronous,
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
}
