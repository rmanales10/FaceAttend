import 'dart:developer';

import 'package:app_attend/src/admin/dashboard/screens/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _controller = Get.put(DashboardController());

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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStatisticsCards(),
                    SizedBox(height: 24),
                    _buildCalendarAndHolidaysSection(),
                  ],
                ),
              ),
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
                  Icons.dashboard_outlined,
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
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monitor and manage your system',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                  'Total Records: ${_controller.totalTeacher.value + _controller.totalStudent.value + _controller.totalSubject.value + _controller.totalSection.value}',
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

  Widget _buildStatisticsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          // Responsive breakpoints
          if (constraints.maxWidth > 1200) {
            // Desktop: 4 columns
            return GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Teachers',
                  '${_controller.totalTeacher.value}',
                  'Track current number of teachers',
                  Color(0xFF10B981),
                  Icons.person_2_outlined,
                ),
                _buildStatCard(
                  'Sections',
                  '${_controller.totalSection.value}',
                  'Track current number of sections',
                  Color(0xFFEF4444),
                  Icons.group_outlined,
                ),
                _buildStatCard(
                  'Subjects',
                  '${_controller.totalSubject.value}',
                  'Track current number of subjects',
                  Color(0xFF3B82F6),
                  Icons.book_outlined,
                ),
                _buildStatCard(
                  'Students',
                  '${_controller.totalStudent.value}',
                  'Track current number of students',
                  Color(0xFF8B5CF6),
                  Icons.school_outlined,
                ),
              ],
            );
          } else if (constraints.maxWidth > 800) {
            // Tablet: 2 columns
            return GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Teachers',
                  '${_controller.totalTeacher.value}',
                  'Track current number of teachers',
                  Color(0xFF10B981),
                  Icons.person_2_outlined,
                ),
                _buildStatCard(
                  'Sections',
                  '${_controller.totalSection.value}',
                  'Track current number of sections',
                  Color(0xFFEF4444),
                  Icons.group_outlined,
                ),
                _buildStatCard(
                  'Subjects',
                  '${_controller.totalSubject.value}',
                  'Track current number of subjects',
                  Color(0xFF3B82F6),
                  Icons.book_outlined,
                ),
                _buildStatCard(
                  'Students',
                  '${_controller.totalStudent.value}',
                  'Track current number of students',
                  Color(0xFF8B5CF6),
                  Icons.school_outlined,
                ),
              ],
            );
          } else {
            // Mobile: Single column with horizontal scroll
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 4),
                  _buildStatCard(
                    'Teachers',
                    '${_controller.totalTeacher.value}',
                    'Track current number of teachers',
                    Color(0xFF10B981),
                    Icons.person_2_outlined,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    'Sections',
                    '${_controller.totalSection.value}',
                    'Track current number of sections',
                    Color(0xFFEF4444),
                    Icons.group_outlined,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    'Subjects',
                    '${_controller.totalSubject.value}',
                    'Track current number of subjects',
                    Color(0xFF3B82F6),
                    Icons.book_outlined,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    'Students',
                    '${_controller.totalStudent.value}',
                    'Track current number of students',
                    Color(0xFF8B5CF6),
                    Icons.school_outlined,
                  ),
                  SizedBox(width: 4),
                ],
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildCalendarAndHolidaysSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          // Desktop: Side by side layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildCalendarSection(),
              ),
              SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildHolidaysSection(),
              ),
            ],
          );
        } else {
          // Mobile/Tablet: Stacked layout
          return Column(
            children: [
              _buildCalendarSection(),
              SizedBox(height: 24),
              _buildHolidaysSection(),
            ],
          );
        }
      },
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Academic Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            height: 450,
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              holidayPredicate: (day) =>
                  holidays.keys.any((holiday) => isSameDay(day, holiday)),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  shape: BoxShape.circle,
                ),
                holidayDecoration: BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
                defaultTextStyle: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF667eea),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                rightChevronIcon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
              ),
              eventLoader: (day) =>
                  holidays.containsKey(day) ? [holidays[day]!['name']] : [],
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selectedDay == null
                      ? null
                      : () => _addHoliday(_selectedDay!),
                  icon: Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 18),
                  label: Text(
                    'Add Holiday',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDay = DateTime.now();
                      _focusedDay = DateTime.now();
                    });
                  },
                  icon: Icon(Icons.today, color: Color(0xFF667eea), size: 18),
                  label: Text(
                    'Today',
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF667eea)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaysSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event_available,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Upcoming Holidays',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${holidays.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 400,
            child: holidays.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No holidays scheduled',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final entry = holidays.entries.toList()[index];
                      final date = entry.key;
                      final details = entry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF667eea).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF667eea).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: details['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    details['name'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 20,
                              ),
                              onPressed: () {
                                log(details['id']);
                                _deleteHoliday(details['id'], date);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String total,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  total,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
