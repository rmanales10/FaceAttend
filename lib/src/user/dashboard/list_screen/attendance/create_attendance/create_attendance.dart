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
  final _controller = Get.put(CreateController());

  // Dropdown reactive variables
  final selectedClassSchedule = Rxn<Map<String, dynamic>>();
  final classSchedules = RxList<Map<String, dynamic>>();
  final isLoading = RxBool(false);

  @override
  void initState() {
    super.initState();
    _loadClassSchedules();
  }

  Future<void> _loadClassSchedules() async {
    try {
      isLoading.value = true;
      await _controller.fetchAllClassSchedules();
      classSchedules.value = _controller.classSchedules;
    } catch (e) {
      _showErrorSnackbar('Failed to load class schedules');
    } finally {
      isLoading.value = false;
    }
  }

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
            _buildClassScheduleDropdown(),
            const SizedBox(height: 24),
            if (selectedClassSchedule.value != null) _buildScheduleDetails(),
            const SizedBox(height: 40),
            if (selectedClassSchedule.value != null)
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isAsynchronous ? Colors.blue[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isAsynchronous
                  ? Colors.blue[300]!
                  : Colors.green[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isAsynchronous ? Icons.access_time : Icons.person,
                size: 16,
                color: widget.isAsynchronous
                    ? Colors.blue[700]
                    : Colors.green[700],
              ),
              const SizedBox(width: 6),
              Text(
                widget.isAsynchronous ? 'Asynchronous' : 'Face to Face',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isAsynchronous
                      ? Colors.blue[700]
                      : Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassScheduleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Class Schedule:',
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
            child: DropdownButton<Map<String, dynamic>>(
              value: selectedClassSchedule.value,
              isExpanded: true,
              hint: Text('Select a class schedule',
                  style: TextStyle(color: Colors.grey[600])),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
              items: classSchedules.map((Map<String, dynamic> schedule) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: schedule,
                  child: Text(
                    '${schedule['course_code']} - ${schedule['subject_name']}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: classSchedules.isEmpty
                  ? null
                  : (Map<String, dynamic>? newValue) {
                      selectedClassSchedule.value = newValue;
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDetails() {
    return Obx(() {
      if (selectedClassSchedule.value == null) return const SizedBox.shrink();

      final schedule = selectedClassSchedule.value!;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Schedule Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Subject',
                '${schedule['course_code']} - ${schedule['subject_name']}'),
            _buildDetailRow('Course Year', schedule['course_year']),
            _buildDetailRow('Year Level', schedule['year_level']),
            _buildDetailRow('Schedule', schedule['schedule']),
            _buildDetailRow('Teacher', schedule['teacher_name']),
            _buildDetailRow('Room', schedule['building_room']),
            _buildDetailRow('Department', schedule['department']),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAttendanceButton(Size size) {
    return Obx(() {
      final canCreateAttendance = selectedClassSchedule.value != null;

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
    if (selectedClassSchedule.value == null) {
      _showErrorSnackbar('Please select a class schedule');
      return;
    }

    try {
      isLoading.value = true;
      final schedule = selectedClassSchedule.value!;
      final now = DateTime.now();
      await _controller.createAttendance(
        subject: '${schedule['course_code']} ${schedule['subject_name']}',
        section: schedule['course_year'],
        date: now,
        time: DateFormat("hh:mm a").format(now),
        isAsynchronous: widget.isAsynchronous,
        classSchedule: selectedClassSchedule.value!,
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
