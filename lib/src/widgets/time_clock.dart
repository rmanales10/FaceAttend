import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';

class TimeClockWidget extends StatelessWidget {
  final String time; // Pass the formatted time as a string, e.g., "05:32:28"
  final String role; // The role, e.g., "Bartending"

  const TimeClockWidget({super.key, required this.time, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
      child: Row(
        children: [
          Icon(Icons.login, color: blue), // Clock-in icon
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time clock',
                style: TextStyle(
                  fontSize: 14.0,
                  color: blue,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold, color: blue),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: blue.withOpacity(.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
