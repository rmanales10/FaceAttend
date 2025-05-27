import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';

class InOutStatusWidget extends StatelessWidget {
  final int inCount;
  final int breakCount;
  final int outCount;
  final String
      dateTime; // Formatted date and time, e.g., "Monday, 25 May 5:28 pm"
  final String firstIn; // Time of the first in, e.g., "8:32 am"
  final String lastOut; // Time of the last out, e.g., "--:--"

  const InOutStatusWidget({
    super.key,
    required this.inCount,
    required this.breakCount,
    required this.outCount,
    required this.dateTime,
    required this.firstIn,
    required this.lastOut,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Who's In/Out",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
              Text(
                dateTime,
                style: TextStyle(
                  fontSize: 14.0,
                  color: blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusColumn(inCount, "Present"),
              _buildStatusColumn(breakCount, "Total"),
              _buildStatusColumn(outCount, "Absent"),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "First in $firstIn",
                style: TextStyle(
                  fontSize: 14.0,
                  color: blue,
                ),
              ),
              Text(
                "Last out $lastOut",
                style: TextStyle(
                  fontSize: 14.0,
                  color: blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: blue),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: blue,
          ),
        ),
      ],
    );
  }
}
