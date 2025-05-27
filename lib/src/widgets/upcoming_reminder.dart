import 'package:flutter/material.dart';

class UpcomingRemindersWidget extends StatelessWidget {
  final List<Reminder> reminders;

  const UpcomingRemindersWidget({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Reminders',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: reminders
                .map((reminder) => _buildReminderRow(reminder))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderRow(Reminder reminder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                reminder.month.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
              Text(
                reminder.day.toString(),
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reminder.notes
                  .map((note) => Text(
                        note,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ))
                  .toList(),
            ),
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

  Reminder({
    required this.month,
    required this.day,
    required this.notes,
  });
}
