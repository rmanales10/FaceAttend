import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:app_attend/src/admin/firebase/firestore.dart';

// ignore: must_be_immutable
class TeacherPage extends StatelessWidget {
  TeacherPage({super.key});
  final Firestore _firestore = Get.put(Firestore());
  RxBool isTap = false.obs;

  @override
  Widget build(BuildContext context) {
    // Fetch users when the widget is built
    _firestore.fetchAllUsers();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 40,
                        color: const Color.fromARGB(255, 56, 131, 243),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Teachers Management',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monitor teachers and schedules',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 50),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    // Display a loading indicator while fetching
                    if (_firestore.allUsers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Build the DataTable rows dynamically
                    return DataTable(
                      columns: [
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Created at')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _firestore.allUsers.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        Map<String, dynamic> user = entry.value;

                        // Convert Firestore Timestamp to a formatted DateTime string
                        String formattedDate = user['createdAt'] != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(
                                (user['createdAt'] as Timestamp).toDate())
                            : 'N/A';

                        return DataRow(cells: [
                          DataCell(Text('$index')), // Row number
                          DataCell(Text(user['fullname'] ?? 'N/A')),

                          DataCell(Text(user['phone'] ?? 'N/A')),
                          DataCell(Text(formattedDate)), // Formatted DateTime
                          DataCell(Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.dialog(AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete this?'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _firestore.deleteUser(user['id']);
                                          Get.back(closeOverlays: true);
                                          Get.snackbar('Success',
                                              'User deleted successfully');
                                        },
                                        child: Text('Yes'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Get.back(closeOverlays: true),
                                        child: Text('No'),
                                      ),
                                    ],
                                  ));
                                },
                                icon: Icon(Icons.delete),
                                color: const Color.fromARGB(255, 56, 131, 243),
                              ),
                              SizedBox(width: 10),
                            ],
                          )),
                        ]);
                      }).toList(),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
