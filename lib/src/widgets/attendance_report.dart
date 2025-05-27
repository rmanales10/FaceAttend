import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceReportWidget extends StatelessWidget {
  final List<double> attendanceData;
  final double overallPercentage;

  const AttendanceReportWidget({
    super.key,
    required this.attendanceData,
    required this.overallPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Check Attendance Report",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: Stack(
            children: [
              // Bar Chart Layer
              BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'January',
                            'February',
                            'March',
                            'April',
                            'May',
                            'June'
                          ];
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: attendanceData
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: entry.key % 2 == 0
                                  ? Colors.blueGrey
                                  : Colors.lightBlueAccent,
                              width: 16,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              // Line Chart Layer
              LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: attendanceData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: false, // Hide titles for the line chart layer
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Over all percentage   ${overallPercentage.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
