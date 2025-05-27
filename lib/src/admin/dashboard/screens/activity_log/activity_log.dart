import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'activity_log_controller.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final ActivityLogController controller = Get.put(ActivityLogController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust padding and column widths for desktop screens
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? screenWidth * 0.05 : screenWidth * 0.025,
          vertical: 50,
        ),
        child: Column(
          children: [
            // Title
            Text(
              'Activity Log',
              style: TextStyle(
                fontSize: isDesktop ? 36 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      controller.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search by email...",
                      hintStyle: const TextStyle(color: Colors.black45),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Row
            Obx(() {
              controller.fetchActivityLogs();
              return Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard(
                    title: "Total Users",
                    count: controller.totalUsers,
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.2),
                    onTap: () {
                      controller.setFilterType("All");
                    },
                  ),
                  _buildSummaryCard(
                    title: "Online Users",
                    count: controller.onlineUsers,
                    // ignore: deprecated_member_use
                    color: Colors.green.withOpacity(0.8),
                    onTap: () {
                      controller.setFilterType("Online");
                    },
                  ),
                  _buildSummaryCard(
                    title: "Offline Users",
                    count: controller.offlineUsers,
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.7),
                    onTap: () {
                      controller.setFilterType("Offline");
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),

            // Data Table
            Obx(() {
              controller.fetchActivityLogs();
              final filteredData = controller.filteredData;

              return Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? screenWidth * 0.8 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: isDesktop ? 80 : screenWidth * 0.05,
                      columns: [
                        _buildDataColumn("Email", isDesktop),
                        _buildDataColumn("IP Address", isDesktop),
                        _buildDataColumn("Date", isDesktop),
                        _buildDataColumn("Time", isDesktop),
                        _buildDataColumn("Action", isDesktop),
                        _buildDataColumn("Description", isDesktop),
                      ],
                      rows: filteredData.map((row) {
                        return DataRow(cells: [
                          DataCell(Text(row['email'], style: _cellTextStyle())),
                          DataCell(Text(row['ip'], style: _cellTextStyle())),
                          DataCell(Text(row['date'], style: _cellTextStyle())),
                          DataCell(Text(row['time'], style: _cellTextStyle())),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: row['action'] == "Online"
                                    // ignore: deprecated_member_use
                                    ? Colors.green.withOpacity(0.8)
                                    // ignore: deprecated_member_use
                                    : Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                row['action'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(row['description'], style: _cellTextStyle()),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, bool isDesktop) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  TextStyle _cellTextStyle() {
    return const TextStyle(color: Colors.black);
  }
}
