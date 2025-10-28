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
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('holidays').get();

      // Get current date without time for comparison
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);

      List<Map<String, dynamic>> allHolidays = querySnapshot.docs
          .map((doc) {
            DateTime date;

            // Handle both string dates (from web) and Timestamp dates
            var dateField = doc['date'];
            if (dateField is Timestamp) {
              date = dateField.toDate();
            } else if (dateField is String) {
              date = DateTime.parse(dateField);
            } else {
              log('Unknown date format for holiday: $dateField');
              return null;
            }

            return {
              'date': date,
              'notes': doc['name'] ?? 'Holiday',
              'color': doc['color'] ?? '#3b82f6',
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      // Filter for upcoming holidays and sort by date
      holidays.value = allHolidays.where((holiday) {
        DateTime holidayDate = holiday['date'];
        DateTime holidayDateOnly =
            DateTime(holidayDate.year, holidayDate.month, holidayDate.day);
        return holidayDateOnly.isAtSameMomentAs(todayDate) ||
            holidayDateOnly.isAfter(todayDate);
      }).toList()
        ..sort((a, b) => a['date'].compareTo(b['date']));

      log('Fetched ${holidays.length} upcoming holidays');
    } catch (e) {
      log('Error fetching holidays: $e');
      holidays.value = [];
    }
  }
}
