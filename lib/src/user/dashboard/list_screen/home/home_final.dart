import 'dart:convert';
import 'dart:developer';

import 'package:app_attend/src/user/api_services/auth_service.dart';

import 'package:app_attend/src/user/dashboard/list_screen/home/home_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/status_widget.dart';
import 'package:app_attend/src/widgets/time_clock.dart';
import 'package:app_attend/src/widgets/time_controller.dart';
import 'package:app_attend/src/widgets/upcoming_reminder.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeFinal extends StatefulWidget {
  const HomeFinal({super.key});

  @override
  State<HomeFinal> createState() => _HomeFinalState();
}

class _HomeFinalState extends State<HomeFinal> {
  late TimeController timeController;
  late AuthService authService;

  late HomeController _controller;
  late final ProfileController _profileController =
      Get.put(ProfileController());
  final selectedSubject = RxnString();
  final subjectNames = RxList<String>();
  Rx<DateTime> date = DateTime.now().obs;
  RxString time = "".obs;
  RxInt totalPresent = 0.obs;
  RxInt totalAbsent = 0.obs;
  RxInt totalStudent = 0.obs;

  @override
  void initState() {
    super.initState();
    timeController = Get.put(TimeController());
    authService = Get.put(AuthService());

    _controller = Get.put(HomeController());

    _controller.fetchAllRecord();
    for (var attend in _controller.allRecord) {
      if (subjectNames.contains(attend['subject'])) break;
      subjectNames.addNonNull(attend['subject'].toString());
    }
    _controller.fetchHolidays();
  }

  void _updateDateTimeFromSelection(String selected) {
    log('Selected item: $selected');
    final parts = selected.split(' ');
    if (parts.length < 2) return;
    final selectedDateTimeStr =
        '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
    try {
      final selectedDateTime =
          DateFormat('MM/dd/yyyy hh:mm a').parse(selectedDateTimeStr);
      date.value = selectedDateTime;
      time.value = DateFormat('hh:mm a').format(selectedDateTime);
    } catch (e) {
      log('Error parsing date and time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildUserProfile(),
                  const SizedBox(height: 24),
                  _buildTimeClock(),
                  const SizedBox(height: 24),
                  _buildSubjectDropdown(size),
                  const SizedBox(height: 24),
                  _buildInOutStatus(),
                  const SizedBox(height: 24),
                  _buildUpcomingReminders(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: blue,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.notifications, color: blue),
            onPressed: () {
              // Handle notifications
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Obx(() {
      _profileController.fetchUserInfo();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: blue.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: blue,
                child: _profileController.userInfo['base64image'] == null
                    ? Icon(Icons.person, size: 40, color: Colors.white)
                    : ClipOval(
                        child: Image.memory(
                          base64Decode(
                              _profileController.userInfo['base64image']),
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                          gaplessPlayback: true,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileController.userInfo['fullname'] as String? ??
                        'Loading...',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blue,
                        letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Instructor',
                      style: TextStyle(
                        fontSize: 14,
                        color: blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeClock() {
    return Obx(() => TimeClockWidget(
          time: timeController.currentTime.value,
          role: timeController.timeOfDay.value,
        ));
  }

  Widget _buildSubjectDropdown(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSubject.value,
              icon: Icon(
                Icons.arrow_drop_down,
                color: blue,
                size: 28,
              ),
              elevation: 16,
              hint: Text(
                'Select a subject',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextStyle(
                color: blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  totalStudent.value = 0;
                  totalPresent.value = 0;
                  totalAbsent.value = 0;
                  selectedSubject.value = newValue;
                  _updateDateTimeFromSelection(newValue);
                  _controller.fetchSubjectOnly(subject: selectedSubject.value);
                  for (var present in _controller.subjectOnly) {
                    for (var record in present['student_record']) {
                      if (record['present'] == '✓') {
                        totalPresent.value++;
                      }
                      if (record['present'] == 'X') {
                        totalAbsent.value++;
                      }
                      totalStudent.value++;
                    }
                  }
                }
              },
              items: subjectNames.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              isExpanded: true,
            ),
          )),
    );
  }

  Widget _buildInOutStatus() {
    return Obx(() => InOutStatusWidget(
          inCount: totalPresent.value,
          breakCount: totalStudent.value,
          outCount: totalAbsent.value,
          dateTime:
              '${DateFormat('EEEE, d MMM yyyy').format(date.value)} ${time.value}',
          firstIn: time.value,
          lastOut: "",
        ));
  }

  Widget _buildUpcomingReminders() {
    return Obx(() {
      List<Reminder> reminders = mapHolidaysToReminders(_controller.holidays);
      return UpcomingRemindersWidget(reminders: reminders);
    });
  }

  List<Reminder> mapHolidaysToReminders(List<Map<String, dynamic>> holidays) {
    return holidays.map((holiday) {
      DateTime date = holiday['date'];
      return Reminder(
        month: _getMonthName(date.month),
        day: date.day,
        notes: [holiday['notes']],
      );
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}
