import 'dart:convert';
import 'dart:developer';

import 'package:app_attend/src/user/api_services/auth_service.dart';

import 'package:app_attend/src/user/dashboard/list_screen/home/home_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/notifications/notification_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/notifications/notification_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
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
  late final NotificationController _notificationController =
      Get.put(NotificationController());
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
                  _buildSubjectAndAttendance(size),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ),
            Obx(() {
              if (_notificationController.unreadCount.value > 0) {
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _notificationController.unreadCount.value > 9
                            ? '9+'
                            : '${_notificationController.unreadCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
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

  Widget _buildSubjectAndAttendance(Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color: blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Subject',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedSubject.value != null
                        ? blue.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSubject.value,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.expand_more,
                        color: blue,
                        size: 20,
                      ),
                    ),
                    elevation: 0,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.subject,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Choose a subject to view attendance',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return subjectNames.map((String value) {
                        // Split the subject to show code and name separately
                        List<String> parts = value.split(' ');
                        String code = parts.isNotEmpty ? parts[0] : value;
                        String name =
                            parts.length > 1 ? parts.sublist(1).join(' ') : '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name.isNotEmpty ? name : code,
                                  style: TextStyle(
                                    color: blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        totalStudent.value = 0;
                        totalPresent.value = 0;
                        totalAbsent.value = 0;
                        selectedSubject.value = newValue;
                        _updateDateTimeFromSelection(newValue);
                        _controller.fetchSubjectOnly(
                            subject: selectedSubject.value);
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
                      // Split the subject to show code and name separately
                      List<String> parts = value.split(' ');
                      String code = parts.isNotEmpty ? parts[0] : value;
                      String name =
                          parts.length > 1 ? parts.sublist(1).join(' ') : '';

                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedSubject.value == value
                                ? blue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selectedSubject.value == value
                                      ? blue
                                      : blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  code,
                                  style: TextStyle(
                                    color: selectedSubject.value == value
                                        ? Colors.white
                                        : blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name.isNotEmpty ? name : code,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectedSubject.value == value
                                        ? blue
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (selectedSubject.value == value)
                                Icon(
                                  Icons.check_circle,
                                  color: blue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                  ),
                ),
              )),

          // Attendance Stats Section
          Obx(() {
            if (selectedSubject.value == null) {
              return SizedBox.shrink();
            }

            return Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 16),

                // Date and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Who\'s In/Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blue,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMM yyyy').format(date.value),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Present',
                        totalPresent.value.toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        totalStudent.value.toString(),
                        Colors.blue,
                        Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Absent',
                        totalAbsent.value.toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // First In / Last Out
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'First in',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Last out',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
        color: holiday['color'] ?? '#3b82f6',
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
