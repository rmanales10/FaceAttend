import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> activityData = <Map<String, dynamic>>[].obs;
  RxString searchQuery = "".obs;
  RxString filterType = "All".obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivityLogs();
  }

  // Function to fetch activity logs from Firestore
  void fetchActivityLogs() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('activityLogs').get();

      activityData.value = querySnapshot.docs.map((doc) {
        return {
          "email": doc['email'],
          "ip": doc['ipAddress'],
          "date": doc['timestamp'].toDate().toString().split(" ")[0],
          "time": doc['timestamp'].toDate().toString().split(" ")[1],
          "action": doc['action'],
          "description": doc['description'],
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to retrieve activity logs');
    }
  }

  // Function to filter logs based on search and filter type
  List<Map<String, dynamic>> get filteredData {
    return activityData
        .where((row) =>
            (filterType.value == "All" || row['action'] == filterType.value) &&
            row['email']
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // Function to set the search query
  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  // Function to set the filter type
  void setFilterType(String value) {
    filterType.value = value;
  }

  // Calculate summary counts
  int get totalUsers => activityData.length;
  int get onlineUsers =>
      activityData.where((row) => row['action'] == "Online").length;
  int get offlineUsers =>
      activityData.where((row) => row['action'] == "Offline").length;
}
