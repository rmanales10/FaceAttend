import 'package:app_attend/src/admin/dashboard/screens/subjects/subject_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubjectPage extends StatelessWidget {
  SubjectPage({super.key});
  final _controller = Get.put(SubjectController());

  final selectedDepartment = 'BSIT'.obs;
  final List<String> department = [
    'BSIT',
    'BFPT',
    'BTLED - HE',
    'BTLED - ICT',
    'BTLED - IA',
  ];

  @override
  Widget build(BuildContext context) {
    final courseCode = TextEditingController();
    final subjectName = TextEditingController();
    final formkey = GlobalKey<FormState>();

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
                        Icons.menu_book_outlined,
                        size: 40,
                        color: const Color.fromARGB(255, 56, 131, 243),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Subjects Management',
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
                    'Track and manage subjects',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 56, 131, 243),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                          onPressed: () {
                            Get.dialog(AlertDialog(
                              title: Text('Add Subjects'),
                              content: SizedBox(
                                height: 250,
                                width: 300,
                                child: Form(
                                  key: formkey,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Align(
                                          alignment:
                                              AlignmentDirectional.topStart,
                                          child: Text('Course Code')),
                                      inputStudentField(
                                        'ex: IT-112',
                                        courseCode,
                                      ),
                                      SizedBox(height: 10),
                                      Align(
                                          alignment:
                                              AlignmentDirectional.topStart,
                                          child: Text('Subject Name')),
                                      inputStudentField(
                                        'ex: Mobile Programming',
                                        subjectName,
                                      ),
                                      SizedBox(height: 10),
                                      Align(
                                          alignment:
                                              AlignmentDirectional.topStart,
                                          child: Text('Department')),
                                      SizedBox(
                                        width: 300,
                                        child: _buildDropdownSection(
                                          selectedValue: selectedDepartment,
                                          options: department,
                                          onChanged: (newValue) {
                                            selectedDepartment.value =
                                                newValue!;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await _controller.addSubject(
                                          courseCode: courseCode.text,
                                          subjectName: subjectName.text,
                                          department: selectedDepartment.value);
                                      Get.back(closeOverlays: true);
                                      Get.snackbar('Success',
                                          'Subject Added Successfully!');
                                      courseCode.clear();
                                      subjectName.clear();
                                    },
                                    child: Text('Submit')),
                                ElevatedButton(
                                    onPressed: () {
                                      Get.back(closeOverlays: true);
                                    },
                                    child: Text('Cancel'))
                              ],
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Add New Subject',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )))
                ],
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 50),
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
                  _controller.fetchSubject();
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('No.')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Subject Name')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _controller.subjects.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Map<String, dynamic> subj = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('$index')), // Row number
                        DataCell(Text(subj['course_code'])), // Row number
                        DataCell(Text(subj['subject_name'])), // Row number
                        DataCell(Text(subj['department'])), // Row number

                        DataCell(Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.dialog(AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Are you sure you want to delete this?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _controller.deleteSubject(
                                            id: subj['id']);
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
                          ],
                        )),
                      ]);
                    }).toList(),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField inputStudentField(
      String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}

Widget _buildDropdownSection({
  required RxString selectedValue,
  required List<String> options,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(
          () => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue.value,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              dropdownColor: Colors.grey[300],
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    ],
  );
}
