import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _courses = [];
  Map<int, Map<String, dynamic>> _dashboards = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final courses = await _apiService.getCourses();
      final dashboards = <int, Map<String, dynamic>>{};

      for (final course in courses) {
        final courseId = course['id'] as int;
        try {
          final dashboard = await _apiService.getDashboard(courseId);
          dashboards[courseId] = dashboard;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _courses = courses;
          _dashboards = dashboards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOverviewCard(),
                      const SizedBox(height: 16),
                      ..._courses.map((course) => _buildCourseStatCard(course)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No courses enrolled yet',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    int totalCourses = _courses.length;
    int totalAssignments = 0;
    int gradedAssignments = 0;
    double avgScore = 0;
    int scoreCount = 0;

    for (final dash in _dashboards.values) {
      final assignments = dash['assignments'] as List? ?? [];
      totalAssignments += assignments.length;
      for (final a in assignments) {
        if (a['status'] == 'Graded') {
          gradedAssignments++;
          final score = a['score'];
          if (score != null) {
            avgScore += (score as num).toDouble();
            scoreCount++;
          }
        }
      }
    }

    final displayAvg = scoreCount > 0 ? (avgScore / scoreCount) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Courses', '$totalCourses', Colors.blue),
                _buildStatItem(
                    'Assignments', '$totalAssignments', Colors.orange),
                _buildStatItem('Graded', '$gradedAssignments', Colors.green),
                _buildStatItem(
                    'Avg Score', '${displayAvg.toStringAsFixed(1)}%', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCourseStatCard(dynamic course) {
    final courseId = course['id'] as int;
    final dashboard = _dashboards[courseId];
    final courseName = course['name'] ?? 'Course';
    final assignments = (dashboard?['assignments'] as List?) ?? [];
    final graded = assignments.where((a) => a['status'] == 'Graded').length;
    final pending =
        assignments.where((a) => a['status'] != 'Graded').length;
    final riskScore = dashboard?['risk_score'];

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMiniStat('Total', '${assignments.length}', Colors.blue),
                _buildMiniStat('Graded', '$graded', Colors.green),
                _buildMiniStat('Pending', '$pending', Colors.orange),
                if (riskScore != null)
                  _buildMiniStat(
                    'Risk',
                    '${riskScore.toStringAsFixed(0)}%',
                    riskScore >= 70
                        ? Colors.red
                        : riskScore >= 40
                            ? Colors.orange
                            : Colors.green,
                  ),
              ],
            ),
            if (assignments.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: assignments.isEmpty
                      ? 0
                      : graded / assignments.length,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$graded of ${assignments.length} assignments graded',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
