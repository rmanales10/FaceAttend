import 'package:app_attend/src/user/dashboard/list_screen/attendance/create_attendance/create_controller.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAttendance extends StatefulWidget {
  final bool isAsynchronous;
  const CreateAttendance({super.key, required this.isAsynchronous});

  @override
  State<CreateAttendance> createState() => _CreateAttendanceState();
}

class _CreateAttendanceState extends State<CreateAttendance> {
  final TextEditingController _timeController = TextEditingController();
  final DateFormat _timeFormat = DateFormat("hh:mm a");
  final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
  final selectedTime = RxString('');
  final selectedDate = Rxn<DateTime>();
  final _controller = Get.put(CreateController());

  // Dropdown reactive variables
  final selectedDepartment = RxnString();
  final List<String> department = [
    'BSIT',
    'BFPT',
    'BTLED - HE',
    'BTLED - ICT',
    'BTLED - IA',
  ];
  final selectedSection = RxnString();
  final sections = RxList<String>();
  final selectedSubject = RxnString();
  final subjects = RxList<String>();
  final isLoading = RxBool(false);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Obx(() => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildAttendanceForm(size)),
      ),
    );
  }

  Widget _buildAttendanceForm(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildDepartmentDropdown(),
            const SizedBox(height: 24),
            if (selectedDepartment.value != null) _buildSubjectDropdown(),
            const SizedBox(height: 24),
            if (selectedSubject.value != null) _buildSectionDropdown(),
            const SizedBox(height: 24),
            if (selectedSection.value != null) _buildTimeSelector(),
            const SizedBox(height: 24),
            if (selectedSection.value != null) _buildDateSelector(context),
            const SizedBox(height: 40),
            if (selectedSection.value != null)
              Center(child: _buildAddAttendanceButton(size)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.blue[700],
                )),
            Text(
              'Create Attendance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details to create a new attendance record',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return _buildDropdownSection(
      label: 'Select Department:',
      selectedValue: selectedDepartment,
      options: department,
      onChanged: (newValue) async {
        try {
          isLoading.value = true;
          selectedDepartment.value = newValue!;
          subjects.clear();
          selectedSubject.value = null;
          selectedSection.value = null;

          await _controller.fetchSubject(department: selectedDepartment.value!);

          for (var s in _controller.subjects) {
            final courseSubject = '${s['course_code']} ${s['subject_name']}';
            if (!subjects.contains(courseSubject)) {
              subjects.add(courseSubject);
            }
          }

          if (subjects.isNotEmpty) {
            selectedSubject.value = subjects.first;
          }
        } catch (e) {
          _showErrorSnackbar('Failed to fetch subjects');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Widget _buildSubjectDropdown() {
    return _buildDropdownSection(
      label: 'Select Subject:',
      selectedValue: selectedSubject,
      options: subjects,
      onChanged: (newValue) async {
        try {
          isLoading.value = true;
          selectedSubject.value = newValue!;
          sections.clear();
          selectedSection.value = null;

          await _controller.fetchSection(subject: selectedSubject.value!);

          for (var s in _controller.sections) {
            final sectionBlock = s['section_year_block'];
            if (!sections.contains(sectionBlock)) {
              sections.add(sectionBlock);
            }
          }

          if (sections.isNotEmpty) {
            selectedSection.value = sections.first;
          }
        } catch (e) {
          _showErrorSnackbar('Failed to fetch sections');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Widget _buildSectionDropdown() {
    return _buildDropdownSection(
      label: 'Select Section:',
      selectedValue: selectedSection,
      options: sections,
      onChanged: (newValue) => selectedSection.value = newValue!,
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required RxnString selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue.value,
              isExpanded: true,
              hint: Text('Select an option',
                  style: TextStyle(color: Colors.grey[600])),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: options.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
      // Force UI update
      setState(() {});
    }
  }

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date:',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700]),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue[50],
            ),
            child: Row(
              children: [
                Obx(() => Text(
                      selectedDate.value != null
                          ? dateFormat.format(selectedDate.value!)
                          : 'MM/DD/YYYY',
                      style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                    )),
                const Spacer(),
                Icon(Icons.calendar_today, size: 20, color: Colors.blue[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _timeController.text = _timeFormat.format(selectedDateTime);
      selectedTime.value = _timeController.text;
    }
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time:',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _timeController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select time',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            filled: true,
            fillColor: Colors.blue[50],
            suffixIcon: IconButton(
              icon: Icon(Icons.access_time, color: Colors.blue[700]),
              onPressed: _selectTime,
            ),
          ),
          style: TextStyle(fontSize: 16, color: Colors.blue[800]),
          onTap: () {
            if (_timeController.text.isEmpty) {
              final now = DateTime.now();
              _timeController.text = _timeFormat.format(now);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAddAttendanceButton(Size size) {
    return Obx(() {
      final canCreateAttendance = selectedDepartment.value != null &&
          selectedSubject.value != null &&
          selectedSection.value != null &&
          selectedDate.value != null &&
          _timeController.text.isNotEmpty;

      return SizedBox(
        width: size.width * 0.7,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: canCreateAttendance ? _createAttendance : null,
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: const Text('Add Attendance', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[400],
            elevation: 3,
          ),
        ),
      );
    });
  }

  Future<void> _createAttendance() async {
    if (selectedDepartment.value == null ||
        selectedSubject.value == null ||
        selectedSection.value == null ||
        selectedDate.value == null ||
        _timeController.text.isEmpty) {
      _showErrorSnackbar('Please fill in all required fields');
      return;
    }

    try {
      isLoading.value = true;
      await _controller.createAttendance(
        subject: selectedSubject.value!,
        section: selectedSection.value!,
        date: selectedDate.value!,
        time: _timeController.text,
        isAsynchronous: widget.isAsynchronous,
      );

      Get.back();
      showSuccess(
        message: 'Attendance created successfully!',
      );
    } catch (e) {
      _showErrorSnackbar('Failed to create attendance: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    showError(message: message);
  }
}
