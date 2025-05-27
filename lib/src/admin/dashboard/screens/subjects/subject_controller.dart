import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:math' as rnd;

class SubjectController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  String generateUniqueId() {
    var random = rnd.Random();
    int randomNumber = 1000000 + random.nextInt(9000000);
    return 'subject-$randomNumber';
  }

  Future<void> addSubject({
    required var courseCode,
    required var subjectName,
    required var department,
  }) async {
    String autoID = generateUniqueId();
    await _firestore.collection('subjects').doc(autoID).set({
      'id': autoID,
      'course_code': courseCode,
      'subject_name': subjectName,
      'department': department,
    });
  }

  RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  Future<void> fetchSubject() async {
    QuerySnapshot querySnapshot = await _firestore.collection('subjects').get();
    subjects.value = querySnapshot.docs
        .map((doc) => {
              'id': doc['id'],
              'course_code': doc['course_code'],
              'department': doc['department'],
              'subject_name': doc['subject_name'],
            })
        .toList();
  }

  Future<void> deleteSubject({required var id}) async {
    await _firestore.collection('subjects').doc(id).delete();
  }
}
