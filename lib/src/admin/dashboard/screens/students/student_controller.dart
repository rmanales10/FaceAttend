import 'dart:developer';
import 'dart:math' as rnd;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StudentController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'student-$randomNumber';
  }

  Future<void> addStudent({
    required String fullname,
    required String department,
    required String yearLevel,
    required String section,
    required List subject,
    required String sectionYearBlock,
  }) async {
    String randomDoc = generateUniqueId();
    await _firestore.collection('students').doc(randomDoc).set({
      'id': randomDoc,
      'full_name': fullname,
      'year_level': yearLevel,
      'department': department,
      'section': section,
      'subject': subject,
      'section_year_block': sectionYearBlock,
    }, SetOptions(merge: true));
  }

  RxList<Map<String, dynamic>> allStudents = <Map<String, dynamic>>[].obs;
  Future<void> getAllStudents() async {
    QuerySnapshot querySnapshot = await _firestore.collection('students').get();

    allStudents.value = querySnapshot.docs
        .map((doc) => {
              'department': doc['department'],
              'full_name': doc['full_name'],
              'section': doc['section'],
              'section_year_block': doc['section_year_block'],
              'year_level': doc['year_level'],
              'id': doc['id'],
            })
        .toList();
  }

  RxMap<String, dynamic> studentRecord = <String, dynamic>{}.obs;
  Future<void> getStudentRecord({required String id}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('students').doc(id).get();
      if (documentSnapshot.exists) {
        studentRecord.value = documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> editStudent({
    required String id,
    required String fullname,
    required String department,
    required String yearLevel,
    required String section,
    required List subject,
    required String sectionYearBlock,
  }) async {
    await _firestore.collection('students').doc(id).set({
      'full_name': fullname,
      'year_level': yearLevel,
      'department': department,
      'section': section,
      'subject': subject,
      'section_year_block': sectionYearBlock,
    }, SetOptions(merge: true));
  }

  Future<void> deleteStudent({required String studentId}) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
    } catch (e) {
      log('Unable to delete');
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
}
