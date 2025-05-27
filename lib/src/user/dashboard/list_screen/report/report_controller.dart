import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> reports =
      <Map<String, dynamic>>[].obs; // Original list of reports
  RxList<Map<String, dynamic>> filteredReports =
      <Map<String, dynamic>>[].obs; // Filtered list of reports
  RxString searchQuery = ''.obs; // Search query to track user input

  @override
  void onInit() {
    super.onInit();
    // Fetch reports initially
    getReports();

    // React to search query updates
    searchQuery.listen((query) {
      filterReports(query);
    });
  }

  // Fetch reports from Firestore for the current user
  Future<void> getReports() async {
    if (currentUser == null) {
      return;
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reports')
          .where('user_id', isEqualTo: currentUser!.uid)
          .get();

      reports.value = querySnapshot.docs
          .map((doc) => {
                'attendance_id': doc['attendance_id'],
                'date': doc['date'],
                'section': doc['section'],
                'subject': doc['subject'],
                'type': doc['type'],
                'url': doc['url'],
              })
          .toList();

      // Initially, filtered reports match all reports
      filteredReports.value = reports;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch reports: $e');
    }
  }

  // Update the search query to trigger filtering
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Filter reports based on the search query
  void filterReports(String query) {
    if (query.isEmpty) {
      filteredReports.value = reports;
    } else {
      filteredReports.value = reports.where((report) {
        final subject = report['subject'].toString().toLowerCase();
        final section = report['section'].toString().toLowerCase();
        final queryLower = query.toLowerCase();
        return subject.contains(queryLower) || section.contains(queryLower);
      }).toList();
    }
  }

  Future<void> deleteReports(String id) async {
    await _firestore.collection('reports').doc(id).delete();
  }
}
