import 'dart:developer';
import 'dart:ui';
import 'dart:math' as rnd;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final totalTeacher = 0.obs;
  final totalSubject = 0.obs;
  final totalSection = 0.obs;
  final totalStudent = 0.obs;

  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'holiday#$randomNumber';
  }

  Future<void> getTotal() async {
    try {
      QuerySnapshot teacherSnapshot =
          await _firestore.collection('users').get();
      totalTeacher.value = teacherSnapshot.docs.length;

      QuerySnapshot subjectSnapshot =
          await _firestore.collection('subjects').get();
      totalSubject.value = subjectSnapshot.docs.length;

      QuerySnapshot studentSnapshot =
          await _firestore.collection('students').get();
      totalStudent.value = studentSnapshot.docs.length;

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('students').get();

      Set<String> uniqueSectionYearBlocks = <String>{};

      for (var doc in snapshot.docs) {
        if (doc.data() != null &&
            (doc.data() as Map<String, dynamic>)
                .containsKey('section_year_block')) {
          String sectionYearBlock =
              (doc.data() as Map<String, dynamic>)['section_year_block'];
          uniqueSectionYearBlocks.add(sectionYearBlock);
        }
      }

      totalSection.value = uniqueSectionYearBlocks.length;
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> addHolidayToFirebase(
      {required DateTime date,
      required String name,
      required int color}) async {
    try {
      String genID = generateUniqueId();
      await _firestore.collection('holidays').doc(genID).set({
        'id': genID,
        'date': Timestamp.fromDate(date),
        'name': name,
        'color': color,
      });
      log('Holiday added successfully.');
    } catch (e) {
      log('Error adding holiday: $e');
    }
  }

  Future<void> deleteHolidayFromFirebase(String docId) async {
    try {
      await _firestore.collection('holidays').doc(docId).delete();
      log('Holiday deleted successfully.');
    } catch (e) {
      log('Error deleting holiday: $e');
    }
  }

  Future<Map<String, Map<String, dynamic>>> getHolidaysFromFirebase() async {
    Map<String, Map<String, dynamic>> holidayMap = {};
    try {
      QuerySnapshot snapshot = await _firestore.collection('holidays').get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime date = (data['date'] as Timestamp).toDate();
        holidayMap[doc.id] = {
          'date': date,
          'name': data['name'],
          'color': Color(data['color']),
        };
      }
    } catch (e) {
      log('Error fetching holidays: $e');
    }
    return holidayMap;
  }
}
