import 'package:flutter/material.dart';

class UpcomingRemindersWidget extends StatelessWidget {
  final List<Reminder> reminders;

  const UpcomingRemindersWidget({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upcoming Holidays',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          reminders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No upcoming holidays',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: reminders
                      .map((reminder) => _buildReminderRow(reminder))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildReminderRow(Reminder reminder) {
    Color reminderColor = _parseColor(reminder.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: reminderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: reminderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: reminderColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reminder.month.toUpperCase().substring(0, 3),
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: reminderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.day.toString(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: reminderColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reminder.notes
                  .map((note) => Text(
                        note,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ))
                  .toList(),
            ),
          ),
          Icon(
            Icons.calendar_month,
            color: reminderColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class Reminder {
  final String month;
  final int day;
  final List<String> notes;
  final String color;

  Reminder({
    required this.month,
    required this.day,
    required this.notes,
    this.color = '#3b82f6', // Default blue color
  });
}
