import 'package:app_attend/src/admin/dashboard/screens/students/student_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _controller = Get.put(StudentController());

  RxBool isAddStudent = false.obs;

  RxBool isEditStudent = false.obs;

  final studentId = ''.obs;

  final name = TextEditingController();

  final section = TextEditingController();

  final formkey = GlobalKey<FormState>();

  final selectedYear = '1st Year'.obs;

  final List<String> year = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  final selectedDepartment = 'BSIT'.obs;

  final List<String> department = [
    'BSIT',
    'BFPT',
    'BTLED - HE',
    'BTLED - ICT',
    'BTLED - IA',
  ];

  final selectedSection = 'Section A'.obs;

  final List<String> _section = [
    'Section A',
    'Section B',
    'Section C',
    'Section D',
    'Section E',
    'Section F',
  ];

  final selectedsubject = 'Elective'.obs;

  final RxList<String> subject = [
    'Elective',
    'Mobile Programming',
    'Database',
  ].obs;

  RxList<String> subs = <String>[].obs;
  RxString subSel = ''.obs;

  final RxList dataS = [].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_2_outlined,
                        size: 40,
                        color: const Color.fromARGB(255, 56, 131, 243),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Students Management',
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
                    'Track and manage students records',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 56, 131, 243),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () {
                        isEditStudent.value = !isEditStudent.value;
                      },
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              !isAddStudent.value && !isEditStudent.value
                                  ? Icons.person_add_alt
                                  : Icons.remove_red_eye,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              !isAddStudent.value && !isEditStudent.value
                                  ? 'Add New Student'
                                  : 'View Records',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Obx(() {
                _controller.getAllStudents();
                if (isEditStudent.value && !isAddStudent.value) {
                  return _editRecord();
                } else if (isAddStudent.value && !isEditStudent.value) {
                  return _addRecord();
                }
                return _studentRecord();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Container _studentRecord() {
    return Container(
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
      child: DataTable(
        columns: [
          DataColumn(label: Text('No.')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Year Level')),
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Section')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _controller.allStudents.asMap().entries.map((entry) {
          int index = entry.key + 1;
          Map<String, dynamic> user = entry.value;
          return DataRow(cells: [
            DataCell(Text('$index')), // Row number
            DataCell(Text(user['full_name'])),
            DataCell(Text(user['year_level'])),
            DataCell(Text(user['department'])),
            DataCell(Text(user['section'])),
            DataCell(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Get.dialog(AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Are you sure you want to delete this?'),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            await _controller.deleteStudent(
                                studentId: user['id']);
                            Get.back(closeOverlays: true);
                            Get.snackbar(
                                'Success', 'User deleted successfully');
                            _controller.getAllStudents();
                          },
                          child: Text('Yes'),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.back(closeOverlays: true),
                          child: Text('No'),
                        ),
                      ],
                    ));
                  },
                  icon: Icon(Icons.delete),
                  color: const Color.fromARGB(255, 56, 131, 243),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    isEditStudent.value = !isEditStudent.value;

                    studentId.value = user['id'];
                    await _controller.getStudentRecord(id: user['id']);
                    final studentRecord = _controller.studentRecord;
                    name.text = studentRecord['full_name'];
                    selectedYear.value = studentRecord['year_level'];
                    selectedDepartment.value = studentRecord['department'];
                    selectedSection.value = studentRecord['section'];
                    dataS.value = studentRecord['subject'];

                    // Get.snackbar(
                    //     'Info', 'Edit functionality not yet implemented.');
                  },
                  icon: Icon(Icons.edit_document),
                  color: const Color.fromARGB(255, 56, 131, 243),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Container _addRecord() {
    return Container(
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
      margin: EdgeInsets.only(top: 50),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          TextFormField(
            controller: name,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Year Level'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedYear,
                      options: year,
                      onChanged: (newValue) {
                        selectedYear.value = newValue!;
                      },
                    ),
                  )
                ],
              ),
              SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Department'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedDepartment,
                      options: department,
                      onChanged: (newValue) async {
                        subs.clear();
                        selectedDepartment.value = newValue!;
                        await _controller.fetchSubject(
                            department: selectedDepartment.value);

                        for (var s in _controller.subjects) {
                          if (subs.contains(s['course_code'])) {
                            break;
                          }
                          subs.addNonNull(
                              '${s['course_code']} ${s['subject_name']}');
                        }
                        subSel.value = subs.first;
                      },
                    ),
                  )
                ],
              ),
              SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Section'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedSection,
                      options: _section,
                      onChanged: (newValue) {
                        selectedSection.value = newValue!;
                      },
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Subjects'),
              _buildDropdownSection(
                selectedValue: subSel,
                options: subs,
                onChanged: (newValue) {
                  subSel.value = newValue!;

                  if (!dataS.contains(newValue)) {
                    dataS.add(newValue);
                  }
                },
              ),
              ...List.generate(
                  dataS.length,
                  (index) => Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 56, 131, 243),
                      ),
                      child: TextButton(
                        onPressed: () {
                          dataS.remove(dataS[index]);
                        },
                        child: Text('${dataS[index]}',
                            style: TextStyle(color: Colors.white)),
                      ))),
              SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 56, 131, 243),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                      onPressed: () async {
                        await _controller.addStudent(
                            fullname: name.text,
                            department: selectedDepartment.value,
                            yearLevel: selectedYear.value,
                            section: selectedSection.value,
                            subject: dataS,
                            sectionYearBlock: getFormattedInfo());
                        isAddStudent.value = !isAddStudent.value;
                        dataS.clear();

                        Get.snackbar(
                            'Success', 'Student record saved successfully');
                      },
                      child: Text(
                        'Save Student Record',
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          )
        ],
      ),
    );
  }

  Container _editRecord() {
    return Container(
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
      margin: EdgeInsets.only(top: 50),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          TextFormField(
            controller: name,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Year Level'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedYear,
                      options: year,
                      onChanged: (newValue) {
                        selectedYear.value = newValue!;
                      },
                    ),
                  )
                ],
              ),
              SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Department'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedDepartment,
                      options: department,
                      onChanged: (newValue) async {
                        subs.clear();
                        selectedDepartment.value = newValue!;
                        await _controller.fetchSubject(
                            department: selectedDepartment.value);
                        for (var s in _controller.subjects) {
                          if (subs.contains(s['course_code'])) {
                            break;
                          }
                          subs.addNonNull(
                              '${s['course_code']} ${s['subject_name']}');
                          // ignore: collection_methods_unrelated_type
                        }

                        subSel.value = subs.first;
                      },
                    ),
                  )
                ],
              ),
              SizedBox(width: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Section'),
                  SizedBox(
                    width: 280,
                    child: _buildDropdownSection(
                      selectedValue: selectedSection,
                      options: _section,
                      onChanged: (newValue) {
                        selectedSection.value = newValue!;
                      },
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Subjects'),
              _buildDropdownSection(
                selectedValue: subSel,
                options: subs,
                onChanged: (newValue) {
                  subSel.value = newValue!;

                  if (!dataS.contains(newValue)) {
                    dataS.add(newValue);
                  }
                },
              ),
              ...List.generate(
                  dataS.length,
                  (index) => Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 56, 131, 243),
                      ),
                      child: TextButton(
                        onPressed: () {
                          dataS.remove(dataS[index]);
                        },
                        child: Text('${dataS[index]}',
                            style: TextStyle(color: Colors.white)),
                      ))),
              SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 56, 131, 243),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                      onPressed: () async {
                        isEditStudent.value = !isEditStudent.value;
                        isAddStudent.value = !isAddStudent.value;
                        await _controller.editStudent(
                            id: studentId.value,
                            fullname: name.text,
                            department: selectedDepartment.value,
                            yearLevel: selectedYear.value,
                            section: selectedSection.value,
                            subject: dataS,
                            sectionYearBlock: getFormattedInfo());
                        isAddStudent.value = !isAddStudent.value;
                        dataS.clear();

                        Get.snackbar(
                            'Success', 'Student record saved successfully');
                      },
                      child: Text(
                        'Save Student Record',
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          )
        ],
      ),
    );
  }

  String getFormattedInfo() {
    String year = selectedYear.value[0];
    String sectionLetter = selectedSection.value.split(" ")[1];
    return "$selectedDepartment $year$sectionLetter";
  }

  Text _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid value';
    }
    return null;
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
