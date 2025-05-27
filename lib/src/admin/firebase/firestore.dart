import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable list of users
  RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

  Future<void> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      allUsers.value = querySnapshot.docs.map((doc) {
        // Include the document ID in the user data
        Map<String, dynamic> user = doc.data() as Map<String, dynamic>;
        user['id'] = doc.id;
        return user;
      }).toList();
    } catch (e) {
      log("Error fetching users: $e");
    }
  }

  Future<void> deleteUser(String? id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      // Remove the user from the local list
      allUsers.removeWhere((user) => user['id'] == id);
    } catch (e) {
      log("Error deleting user: $e");
    }
  }

  RxList<Map<String, dynamic>> studentData = <Map<String, dynamic>>[].obs;

  Future<void> getAllStudent() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('students').get();
      studentData.value = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'year_level': doc['year_level'],
          'section': doc['section'],
        };
      }).toList();
    } catch (e) {
      log("Error fetching students: $e");
      studentData.clear();
    }
  }

  Future<void> addStudent(
      {required String fullname,
      required String idnumber,
      required String section}) async {
    try {
      await _firestore.collection('students').add({
        'fullname': fullname,
        'idnumber': idnumber,
        'section': section,
      });
    } catch (e) {
      log('Error Adding Data $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _firestore.collection('students').doc(id).delete();
    } catch (e) {
      log('Error $e');
    }
  }
}
