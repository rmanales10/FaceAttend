import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FaceTrainingViewMode { list, grid, compact }

class StudentFaceTrainingPage extends StatefulWidget {
  const StudentFaceTrainingPage({super.key});

  @override
  State<StudentFaceTrainingPage> createState() =>
      _StudentFaceTrainingPageState();
}

class _StudentFaceTrainingPageState extends State<StudentFaceTrainingPage> {
  final TextEditingController _searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  RxList<Map<String, dynamic>> filteredStudents = <Map<String, dynamic>>[].obs;
  Rx<FaceTrainingViewMode> currentViewMode = FaceTrainingViewMode.list.obs;

  // Mock data for demonstration
  final RxList<Map<String, dynamic>> allStudents = <Map<String, dynamic>>[
    {
      'id': '1',
      'full_name': 'John Doe',
      'year_level': '3rd Year',
      'department': 'BSIT',
      'section': 'Section A',
      'face_trained': true,
      'training_date': '2024-01-15',
      'accuracy': 95.5,
    },
    {
      'id': '2',
      'full_name': 'Jane Smith',
      'year_level': '2nd Year',
      'department': 'BFPT',
      'section': 'Section B',
      'face_trained': false,
      'training_date': null,
      'accuracy': null,
    },
    {
      'id': '3',
      'full_name': 'Mike Johnson',
      'year_level': '4th Year',
      'department': 'BTLED - ICT',
      'section': 'Section C',
      'face_trained': true,
      'training_date': '2024-01-20',
      'accuracy': 92.3,
    },
    {
      'id': '4',
      'full_name': 'Sarah Wilson',
      'year_level': '1st Year',
      'department': 'BTLED - HE',
      'section': 'Section A',
      'face_trained': false,
      'training_date': null,
      'accuracy': null,
    },
    {
      'id': '5',
      'full_name': 'David Brown',
      'year_level': '3rd Year',
      'department': 'BTLED - IA',
      'section': 'Section D',
      'face_trained': true,
      'training_date': '2024-01-18',
      'accuracy': 88.7,
    },
  ].obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadViewPreference();
    _filterStudents();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final viewModeIndex = prefs.getInt('face_training_view_mode') ?? 0;
    currentViewMode.value = FaceTrainingViewMode.values[viewModeIndex];
  }

  Future<void> _saveViewPreference(FaceTrainingViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('face_training_view_mode', mode.index);
  }

  void _onSearchChanged() {
    searchQuery.value = _searchController.text;
    _filterStudents();
  }

  void _filterStudents() {
    if (searchQuery.value.isEmpty) {
      filteredStudents.value = List.from(allStudents);
    } else {
      filteredStudents.value = allStudents.where((student) {
        final name = student['full_name']?.toString().toLowerCase() ?? '';
        final year = student['year_level']?.toString().toLowerCase() ?? '';
        final department =
            student['department']?.toString().toLowerCase() ?? '';
        final section = student['section']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();
        return name.contains(query) ||
            year.contains(query) ||
            department.contains(query) ||
            section.contains(query);
      }).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildStatsCards(),
            Expanded(
              child: _buildStudentsList(),
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
                  Icons.face_retouching_natural,
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
                      'Student Face Training',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Train and manage student face recognition data',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              _buildViewToggleButtons(),
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
                  'Total Students: ${allStudents.length}',
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

  Widget _buildViewToggleButtons() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewButton(
                  Icons.list, FaceTrainingViewMode.list, 'List View'),
              _buildViewButton(
                  Icons.grid_view, FaceTrainingViewMode.grid, 'Grid View'),
              _buildViewButton(Icons.view_agenda, FaceTrainingViewMode.compact,
                  'Compact View'),
            ],
          ),
        ));
  }

  Widget _buildViewButton(
      IconData icon, FaceTrainingViewMode mode, String tooltip) {
    final isSelected = currentViewMode.value == mode;
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          currentViewMode.value = mode;
          _saveViewPreference(mode);
        },
        icon: Icon(
          icon,
          color: isSelected ? Color(0xFF667eea) : Colors.white,
          size: 20,
        ),
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students by name, year, department or section...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final totalCount = allStudents.length;
      final registeredFacesCount =
          allStudents.where((s) => s['face_trained'] == true).length;
      final unregisteredFacesCount = allStudents.length - registeredFacesCount;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Total",
                count: totalCount,
                color: Colors.blue,
                icon: Icons.people_outline,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Registered Faces",
                count: registeredFacesCount,
                color: Colors.green,
                icon: Icons.face_retouching_natural,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Unregistered Faces",
                count: unregisteredFacesCount,
                color: Colors.orange,
                icon: Icons.face_outlined,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    String suffix = '',
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Text(
                '$count$suffix',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (filteredStudents.isEmpty && searchQuery.value.isNotEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          _filterStudents();
        },
        child: _buildStudentsView(),
      );
    });
  }

  Widget _buildStudentsView() {
    switch (currentViewMode.value) {
      case FaceTrainingViewMode.list:
        return _buildListView();
      case FaceTrainingViewMode.grid:
        return _buildGridView();
      case FaceTrainingViewMode.compact:
        return _buildCompactView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(student, index + 1);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentGridCard(student, index + 1);
      },
    );
  }

  Widget _buildCompactView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCompactCard(student, index + 1);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final isTrained = student['face_trained'] == true;
    final accuracy = student['accuracy'] as double?;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(student['full_name']),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['full_name'] ?? 'Unknown Student',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Student #$index',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrainingStatusChip(isTrained, accuracy),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.school,
                          student['year_level'] ?? 'N/A',
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.business,
                          student['department'] ?? 'N/A',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.group,
                          student['section'] ?? 'N/A',
                          Colors.orange,
                        ),
                      ),
                      if (isTrained && accuracy != null)
                        Expanded(
                          child: _buildInfoItem(
                            Icons.analytics,
                            '${accuracy.toStringAsFixed(1)}%',
                            Colors.purple,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trainStudent(student),
                    icon: Icon(Icons.face_retouching_natural, size: 18),
                    label: Text(isTrained ? 'Retrain' : 'Train'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTrained ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewTrainingDetails(student),
                    icon: Icon(Icons.visibility, size: 18),
                    label: Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGridCard(Map<String, dynamic> student, int index) {
    final isTrained = student['face_trained'] == true;
    final accuracy = student['accuracy'] as double?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _getInitial(student['full_name']),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              student['full_name'] ?? 'Unknown Student',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              'Student #$index',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 12, color: Colors.blue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student['year_level'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student['department'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            _buildTrainingStatusChip(isTrained, accuracy),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: (isTrained ? Colors.orange : Colors.blue)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () => _trainStudent(student),
                    icon: Icon(
                      Icons.face_retouching_natural,
                      color: isTrained ? Colors.orange : Colors.blue,
                      size: 16,
                    ),
                    tooltip: isTrained ? 'Retrain' : 'Train',
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    onPressed: () => _viewTrainingDetails(student),
                    icon: Icon(Icons.visibility,
                        color: Colors.blue[600], size: 16),
                    tooltip: 'Details',
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCompactCard(Map<String, dynamic> student, int index) {
    final isTrained = student['face_trained'] == true;
    final accuracy = student['accuracy'] as double?;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getInitial(student['full_name']),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['full_name'] ?? 'Unknown Student',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.school, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        student['year_level'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.business, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        student['department'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.group, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        student['section'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isTrained && accuracy != null) ...[
                        SizedBox(width: 16),
                        Icon(Icons.analytics,
                            size: 12, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${accuracy.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _buildTrainingStatusChip(isTrained, accuracy),
            SizedBox(width: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => _trainStudent(student),
                  icon: Icon(
                    Icons.face_retouching_natural,
                    color: isTrained ? Colors.orange : Colors.blue,
                    size: 18,
                  ),
                  tooltip: isTrained ? 'Retrain' : 'Train',
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => _viewTrainingDetails(student),
                  icon:
                      Icon(Icons.visibility, color: Colors.blue[600], size: 18),
                  tooltip: 'Details',
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingStatusChip(bool isTrained, double? accuracy) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTrained
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTrained ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTrained ? Icons.check_circle : Icons.pending,
            size: 16,
            color: isTrained ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            isTrained ? 'Trained' : 'Pending',
            style: TextStyle(
              color: isTrained ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isTrained && accuracy != null) ...[
            SizedBox(width: 4),
            Text(
              '(${accuracy.toStringAsFixed(1)}%)',
              style: TextStyle(
                color: isTrained ? Colors.green : Colors.orange,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _trainStudent(Map<String, dynamic> student) {
    // Show training dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.face_retouching_natural, color: Colors.blue),
            SizedBox(width: 8),
            Text('Face Training'),
          ],
        ),
        content: Text(
          'Start face training for ${student['full_name']}? This will open the camera for face capture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performFaceTraining(student);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                Text('Start Training', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performFaceTraining(Map<String, dynamic> student) {
    // Simulate training process
    Get.snackbar(
      'Training Started',
      'Face training initiated for ${student['full_name']}',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );

    // Simulate training completion after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      // Update student data
      final studentIndex =
          allStudents.indexWhere((s) => s['id'] == student['id']);
      if (studentIndex != -1) {
        allStudents[studentIndex] = {
          ...allStudents[studentIndex],
          'face_trained': true,
          'training_date': DateTime.now().toIso8601String().split('T')[0],
          'accuracy':
              85.0 + (studentIndex * 2.5), // Simulate different accuracies
        };
        _filterStudents();
      }

      Get.snackbar(
        'Training Complete',
        'Face training completed for ${student['full_name']} with 85% accuracy',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void _viewTrainingDetails(Map<String, dynamic> student) {
    final isTrained = student['face_trained'] == true;
    final accuracy = student['accuracy'] as double?;
    final trainingDate = student['training_date'] as String?;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Training Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', student['full_name']?.toString() ?? 'N/A'),
            _buildDetailRow(
                'Year Level', student['year_level']?.toString() ?? 'N/A'),
            _buildDetailRow(
                'Department', student['department']?.toString() ?? 'N/A'),
            _buildDetailRow('Section', student['section']?.toString() ?? 'N/A'),
            _buildDetailRow('Status', isTrained ? 'Trained' : 'Not Trained'),
            if (isTrained) ...[
              _buildDetailRow('Accuracy',
                  accuracy != null ? '${accuracy.toStringAsFixed(1)}%' : 'N/A'),
              _buildDetailRow('Training Date', trainingDate ?? 'N/A'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getInitial(dynamic fullname) {
    if (fullname == null) return '?';
    final name = fullname.toString().trim();
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
}
