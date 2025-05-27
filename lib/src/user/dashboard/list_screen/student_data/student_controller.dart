import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StudentController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  RxList<Map> studentData = [{}].obs;

  Future<bool> saveStudentToFirestore(
      String name, String imageBase64, String section) async {
    final user = _auth.currentUser;
    try {
      if (user == null) {
        log('No authenticated user');
        return false;
      }

      await _firestore.collection('studentData').add({
        'userId': user.uid,
        'name': name,
        'section': section,
        'imageBase64': imageBase64,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      log('Error saving to Firestore: $e');
      return false;
    }
  }

  Future<void> fetchStudentData(String section) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        log('No authenticated user');
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('studentData')
          .where('userId', isEqualTo: user.uid)
          .where('section', isEqualTo: section)
          .get();

      studentData.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? 'Unknown',
          'imageBase64': data['imageBase64'] as String? ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toString() ??
              'No date',
          ...data, // Include any other fields that might be in the document
        };
      }).toList();

      if (studentData.isEmpty) {
        log('No student data found for the current user');
      } else {
        log('Fetched ${studentData.length} student records');
      }
    } catch (e) {
      log('Error fetching student data: $e');
    }
  }

  Future<bool> deleteStudentData(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }
}
