import 'package:flutter/material.dart';

class AttendanceSheet extends StatelessWidget {
  final List<String> students = [
    "ABAN, JOAN MARIE P.",
    "ABUTON, DYN MARK C.",
    "AGAN, MARVEN",
    "AGAPAY, JOHN LLOYD S.",
    "ALANDROQUE, LEVIE P.",
    "ARADANA, CHRISTINE NICOLE D.",
    "BACTOL, CAREN GRACE S.",
    "BACTOL, CAREN KRIS S.",
    "BARINAS, JANE MAE P.",
    "BORONGAN, CHERILYN A.",
    "BROÑOLA, KEVIN C.",
    "CADUSALE, GOHAN",
    "CALISO, CHENAYA O.",
    "CAPAPAS, ANALISA M.",
    "DE VERA, MARLON IÑIGO A.",
    "EBA, MUNCHER B.",
    "FRANCISCO, REY L.",
    "GAHUMAN, JETRIL JAVEÑA R.",
    "GALABIN, BRANDON JAMES C.",
  ];

  AttendanceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance and Punctuality Monitoring Sheet'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Table(
                border: TableBorder.all(color: Colors.black, width: 1),
                columnWidths: {
                  0: FixedColumnWidth(150), // Fixed width for each column
                  1: FixedColumnWidth(200),
                  2: FixedColumnWidth(250),
                  3: FixedColumnWidth(300),
                },
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Office / Unit:",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(""),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Class Schedule: MONDAY (10:00AM - 1:00PM) FRIDAY (1:00PM - 3:00PM)",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(""),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Subject: WEB SYSTEMS AND TECHNOLOGIES",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Course Code: IT223",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Bldg. and Room No.: LECTURE – MAKESHIFT-04 LABORATORY – COMPLAB 2",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(""),
                    ),
                  ]),
                ],
              ),
              SizedBox(height: 16.0),
              // Main Attendance Table
              DataTable(
                columns: [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Name of Student')),
                  DataColumn(label: Text('Course & Year')),
                  for (int i = 0;
                      i < 5;
                      i++) // Adjustable for number of columns
                    DataColumn(label: Text('Date ${i + 1}')),
                ],
                rows: List.generate(students.length, (index) {
                  return DataRow(cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(students[index])),
                    DataCell(Text('BSIT 2D')),
                    for (int i = 0; i < 5; i++)
                      DataCell(
                        Checkbox(
                          value: false,
                          onChanged: (bool? value) {
                            // Implement attendance state management here
                          },
                        ),
                      ),
                  ]);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
