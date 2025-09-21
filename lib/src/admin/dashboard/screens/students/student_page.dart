import 'package:app_attend/src/admin/dashboard/screens/students/student_controller.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _controller = Get.put(StudentController());
  final TextEditingController _searchController = TextEditingController();

  RxBool isAddStudent = false.obs;
  RxBool isEditStudent = false.obs;
  RxString searchQuery = ''.obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;

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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Initialize filtered students when allStudents changes
    ever(_controller.allStudents, (_) {
      if (_controller.allStudents.isNotEmpty) {
        _filterStudents();
      }
    });

    // Fetch students after setting up the listener
    _controller.getAllStudents();
  }

  void _onSearchChanged() {
    searchQuery.value = _searchController.text;
    _filterStudents();
  }

  void _filterStudents() {
    if (searchQuery.value.isEmpty) {
      filteredStudents.value = List.from(_controller.allStudents);
    } else {
      filteredStudents.value = _controller.allStudents.where((student) {
        final name = student['full_name']?.toString().toLowerCase() ?? '';
        final year = student['year_level']?.toString().toLowerCase() ?? '';
        final department =
            student['department']?.toString().toLowerCase() ?? '';
        final section = student['section']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        return name.contains(query) ||
            year.contains(query) ||
            department.contains(query) ||
            section.contains(query);
      }).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: Obx(() {
                if (isEditStudent.value && !isAddStudent.value) {
                  return _editRecord();
                } else if (isAddStudent.value && !isEditStudent.value) {
                  return _addRecord();
                }
                return _buildStudentsList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_2_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Students Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track and manage student records',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    isAddStudent.value = !isAddStudent.value;
                    if (isAddStudent.value) {
                      isEditStudent.value = false;
                    }
                  },
                  icon: Icon(
                    isAddStudent.value
                        ? Icons.remove_red_eye
                        : Icons.person_add_alt,
                    color: Colors.white,
                  ),
                  label: Text(
                    isAddStudent.value ? 'View Records' : 'Add New Student',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total Students: ${_controller.allStudents.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students by name, year, department, or section...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (_controller.allStudents.isEmpty) {
        return _buildLoadingState();
      }

      // Ensure filteredStudents is populated if it's empty but allStudents has data
      if (filteredStudents.isEmpty && _controller.allStudents.isNotEmpty) {
        _filterStudents();
      }

      if (filteredStudents.isEmpty && searchQuery.value.isNotEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _controller.getAllStudents();
          _filterStudents();
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredStudents.length,
          itemBuilder: (context, index) {
            final student = filteredStudents[index];
            return _buildStudentCard(student, index + 1);
          },
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading students...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(student['full_name']),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['full_name'] ?? 'Unknown Student',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Student #$index',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(student),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.school,
                          student['year_level'] ?? 'N/A',
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.business,
                          student['department'] ?? 'N/A',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.group,
                          student['section'] ?? 'N/A',
                          Colors.orange,
                        ),
                      ),
                      Expanded(child: SizedBox()), // Empty space for alignment
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> student) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _showDeleteDialog(student),
            icon: Icon(Icons.delete_outline, color: Colors.red[600]),
            tooltip: 'Delete Student',
          ),
        ),
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _showStudentDetails(student),
            icon: Icon(Icons.visibility_outlined, color: Colors.blue[600]),
            tooltip: 'View Details',
          ),
        ),
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _editStudent(student),
            icon: Icon(Icons.edit_outlined, color: Colors.green[600]),
            tooltip: 'Edit Student',
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> student) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${student['full_name']?.toString() ?? 'this student'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              await _controller.deleteStudent(studentId: student['id']);
              Get.back();
              showSuccess(message: 'Student deleted successfully');
              _controller.getAllStudents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Student Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', student['full_name']?.toString() ?? 'N/A'),
            _buildDetailRow(
                'Year Level', student['year_level']?.toString() ?? 'N/A'),
            _buildDetailRow(
                'Department', student['department']?.toString() ?? 'N/A'),
            _buildDetailRow('Section', student['section']?.toString() ?? 'N/A'),
            if (student['subject'] != null && student['subject'].isNotEmpty)
              _buildDetailRow('Subjects', student['subject'].join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editStudent(Map<String, dynamic> student) async {
    isEditStudent.value = true;
    studentId.value = student['id'];
    await _controller.getStudentRecord(id: student['id']);
    final studentRecord = _controller.studentRecord;
    name.text = studentRecord['full_name'];
    selectedYear.value = studentRecord['year_level'];
    selectedDepartment.value = studentRecord['department'];
    selectedSection.value = studentRecord['section'];
    dataS.value = studentRecord['subject'];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getInitial(dynamic fullname) {
    if (fullname == null) return '?';
    final name = fullname.toString().trim();
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  Widget _addRecord() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            _buildLabel('Full Name'),
            SizedBox(height: 8),
            TextFormField(
              controller: name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Enter student full name',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Year Level'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
                        selectedValue: selectedYear,
                        options: year,
                        onChanged: (newValue) {
                          selectedYear.value = newValue!;
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Department'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
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
                          if (subs.isNotEmpty) {
                            subSel.value = subs.first;
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Section'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
                        selectedValue: selectedSection,
                        options: _section,
                        onChanged: (newValue) {
                          selectedSection.value = newValue!;
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Subjects'),
                SizedBox(height: 8),
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
                SizedBox(height: 12),
                if (dataS.isNotEmpty) ...[
                  Text(
                    'Selected Subjects:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                        dataS.length,
                        (index) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF667eea),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${dataS[index]}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    dataS.remove(dataS[index]);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ))),
                  ),
                ],
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          isAddStudent.value = false;
                          name.clear();
                          dataS.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _controller.addStudent(
                              fullname: name.text,
                              department: selectedDepartment.value,
                              yearLevel: selectedYear.value,
                              section: selectedSection.value,
                              subject: dataS,
                              sectionYearBlock: getFormattedInfo());
                          isAddStudent.value = false;
                          dataS.clear();
                          name.clear();

                          showSuccess(
                              message: 'Student record saved successfully');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Save Student Record'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _editRecord() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            _buildLabel('Full Name'),
            SizedBox(height: 8),
            TextFormField(
              controller: name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Enter student full name',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Year Level'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
                        selectedValue: selectedYear,
                        options: year,
                        onChanged: (newValue) {
                          selectedYear.value = newValue!;
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Department'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
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
                          if (subs.isNotEmpty) {
                            subSel.value = subs.first;
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Section'),
                      SizedBox(height: 8),
                      _buildDropdownSection(
                        selectedValue: selectedSection,
                        options: _section,
                        onChanged: (newValue) {
                          selectedSection.value = newValue!;
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Subjects'),
                SizedBox(height: 8),
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
                SizedBox(height: 12),
                if (dataS.isNotEmpty) ...[
                  Text(
                    'Selected Subjects:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                        dataS.length,
                        (index) => Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF667eea),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${dataS[index]}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    dataS.remove(dataS[index]);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ))),
                  ),
                ],
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          isEditStudent.value = false;
                          name.clear();
                          dataS.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _controller.editStudent(
                              id: studentId.value,
                              fullname: name.text,
                              department: selectedDepartment.value,
                              yearLevel: selectedYear.value,
                              section: selectedSection.value,
                              subject: dataS,
                              sectionYearBlock: getFormattedInfo());
                          isEditStudent.value = false;
                          dataS.clear();
                          name.clear();

                          showSuccess(
                              message: 'Student record updated successfully');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Update Student Record'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: Obx(
      () => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue.value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          isExpanded: true,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          dropdownColor: Colors.white,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: Colors.grey[800]),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}
