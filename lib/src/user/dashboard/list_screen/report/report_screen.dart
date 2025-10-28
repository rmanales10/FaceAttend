import 'package:app_attend/src/user/dashboard/list_screen/report/report_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatelessWidget {
  final _controller = Get.put(ReportController());
  final TextEditingController _searchController = TextEditingController();

  ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Reports',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: blue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() {
                    _controller.getReports();
                    final reports = _controller.filteredReports;

                    if (reports.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined,
                                size: 80, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'No reports available',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildReportCard(
                          sectionLabel:
                              '${report['subject']}\n${report['section']}',
                          date: '${report['date']}',
                          fileType: '${report['type']}',
                          url: '${report['url']}',
                          id: report['attendance_id'],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search reports...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search, color: blue, size: 24),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
            onPressed: () {
              _searchController.clear();
              _controller.updateSearchQuery('');
            },
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(
          color: blue,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (query) {
          _controller.updateSearchQuery(query);
        },
      ),
    );
  }

  Widget _buildReportCard({
    required String sectionLabel,
    required String date,
    required String fileType,
    required String url,
    required String id,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sectionLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blue,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _buildActionButton(Icons.download, Colors.green, () {
                  final String downloadUrl =
                      'https://ustp-face-attend.site/report-download-public?attendanceId=$id';
                  final Uri downloadLink = Uri.parse(downloadUrl);
                  launchUrl(downloadLink, mode: LaunchMode.externalApplication);
                }),
                SizedBox(width: 10),
                _buildActionButton(Icons.delete, Colors.red, () {
                  _showDeleteConfirmation(id);
                }),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _buildInfoChip(Icons.calendar_today, date),
                SizedBox(width: 10),
                _buildInfoChip(Icons.file_present, fileType),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: blue),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: blue, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel', style: TextStyle(color: blue)),
          ),
          TextButton(
            onPressed: () async {
              await _controller.deleteReports(id);
              Get.back();
              showSuccess(message: 'Report deleted successfully!');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
