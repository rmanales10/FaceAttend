import 'dart:developer';

import 'package:app_attend/src/admin/dashboard/screens/homepage/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _controller = Get.put(HomeController());

  // Define holidays and their colors
  final Map<DateTime, Map<String, dynamic>> holidays = {
    // DateTime(2024, 12, 25): {
    //   'name': 'Christmas Day',
    //   'color': Colors.red,
    // },
    // DateTime(2024, 11, 30): {
    //   'name': 'Bonifacio Day',
    //   'color': Colors.blue,
    // },
    // DateTime(2025, 1, 1): {
    //   'name': 'New Year\'s Day',
    //   'color': Colors.green,
    // },
  };

  @override
  void initState() {
    super.initState();
    _controller.getTotal();
    _loadHolidays();
  }

  void _addHoliday(DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        String holidayName = "";
        Color holidayColor = Colors.red;
        return AlertDialog(
          title: const Text('Add Holiday'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Holiday Name'),
                onChanged: (value) {
                  holidayName = value;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Holiday Color:'),
                  DropdownButton<Color>(
                    value: holidayColor,
                    items: [
                      DropdownMenuItem(
                        value: Colors.red,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: Colors.red,
                        ),
                      ),
                      DropdownMenuItem(
                        value: Colors.blue,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: Colors.blue,
                        ),
                      ),
                      DropdownMenuItem(
                        value: Colors.green,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          holidayColor = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // ignore: deprecated_member_use
                final colorValue = holidayColor.value;
                await _controller.addHolidayToFirebase(
                  date: date,
                  name: holidayName,
                  color: colorValue,
                );
                await _loadHolidays();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadHolidays() async {
    Map<String, Map<String, dynamic>> loadedHolidays =
        await _controller.getHolidaysFromFirebase();
    setState(() {
      holidays.clear();
      holidays.addAll(loadedHolidays.map((key, value) {
        return MapEntry(value['date'], value);
      }));
    });
  }

  void _deleteHoliday(String docId, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Holiday'),
          content: const Text('Are you sure you want to delete this holiday?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(closeOverlays: true);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.deleteHolidayFromFirebase(docId);
                await _loadHolidays();
                Get.back(closeOverlays: true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      _buildCards(
                        'Teachers',
                        '${_controller.totalTeacher}',
                        'Track current number of teachers',
                        const Color.fromARGB(255, 189, 249, 192)
                            // ignore: deprecated_member_use
                            .withOpacity(.2),
                        const FaIcon(FontAwesomeIcons.userGroup),
                      ),
                      _buildCards(
                        'Sections',
                        '${_controller.totalSection}',
                        'Track current number of sections',
                        // ignore: deprecated_member_use
                        Colors.red.withOpacity(0.05),
                        // ignore: deprecated_member_use
                        const FaIcon(FontAwesomeIcons.gripHorizontal),
                      ),
                      _buildCards(
                        'Subjects',
                        '${_controller.totalSubject}',
                        'Track current number of subjects',
                        // ignore: deprecated_member_use
                        Colors.blue.withOpacity(.05),
                        const FaIcon(FontAwesomeIcons.bookOpen),
                      ),
                      _buildCards(
                        'Students',
                        '${_controller.totalStudent}',
                        'Track current number of students',
                        // ignore: deprecated_member_use
                        Colors.grey.withOpacity(.05),
                        const FaIcon(FontAwesomeIcons.graduationCap),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      height: 450,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay: DateTime(2000),
                              lastDay: DateTime(2100),
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              calendarFormat: _calendarFormat,
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              holidayPredicate: (day) => holidays.keys
                                  .any((holiday) => isSameDay(day, holiday)),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                holidayDecoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              eventLoader: (day) => holidays.containsKey(day)
                                  ? [holidays[day]!['name']]
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _selectedDay == null
                                ? null
                                : () => _addHoliday(_selectedDay!),
                            child: const Text('Add Holiday'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: 450,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upcoming Holidays',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: holidays.length,
                                itemBuilder: (context, index) {
                                  final entry =
                                      holidays.entries.toList()[index];
                                  final date = entry.key;
                                  final details = entry.value;

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: details['color'],
                                      radius: 10,
                                    ),
                                    title: Text(
                                      details['name'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      '${date.month}/${date.day}/${date.year}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        log(details['id']);
                                        _deleteHoliday(details['id'], date);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCards(
    String title,
    String total,
    String label,
    Color colors,
    FaIcon icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: colors,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              icon,
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              total,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Align(alignment: Alignment.topLeft, child: Text(label))
        ],
      ),
    );
  }
}
