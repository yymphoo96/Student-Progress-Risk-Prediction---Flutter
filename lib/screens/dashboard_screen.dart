// lib/screens/dashboard_screen.dart - COMPLETE WORKING VERSION

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  DashboardScreen({required this.courseId, required this.courseName});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _courseDetails;
  bool _isLoading = true;
  String? _error;
  int _startWeek = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dashboardData = await _apiService.getDashboard(widget.courseId);
      final courseDetails = await _apiService.getCourseDetails(widget.courseId);
      
      setState(() {
        _dashboardData = dashboardData;
        _courseDetails = courseDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.courseName),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseHeader(),
                        SizedBox(height: 16),
                        _buildStudentCard(),
                        SizedBox(height: 16),
                        // _buildQuickAccessButtons(),
                        // SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildRiskCard()),
                            SizedBox(width: 16),
                            Expanded(child: _buildOverallEngagementCard()),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildWeeklyProgressCard(),
                        SizedBox(height: 16), 
                        _buildQuickAccessButtons(),
                        SizedBox(height: 16),
                        _buildEngagementTrackerCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    final assignments = _courseDetails?['assignments'] as List<dynamic>? ?? [];
    final quizzes = _courseDetails?['quizzes'] as List<dynamic>? ?? [];

    int assignmentsCompleted = assignments.where((a) {
      String status = a['submission_status'] ?? 'not_submitted';
      return status == 'submitted' || status == 'graded';
    }).length;

    int quizzesCompleted = quizzes.where((q) {
      String quiz_status = q['submission_status'] ?? 'not_submitted';
      return quiz_status == 'submitted' || quiz_status == 'graded';
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildAccessCard(
            title: 'Assignments',
            icon: Icons.assignment,
            color: Colors.blue,
            total: assignments.length,
            completed: assignmentsCompleted,
            onTap: () => _showAssignmentsBottomSheet(),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildAccessCard(
            title: 'Quizzes',
            icon: Icons.quiz,
            color: Colors.orange,
            total: quizzes.length,
            completed: quizzesCompleted,
            onTap: () => _showQuizzesBottomSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required int total,
    required int completed,
    required VoidCallback onTap,
  }) {
    double progress = total > 0 ? completed / total : 0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completed/$total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignmentsBottomSheet() {
    final assignments = _courseDetails?['assignments'] as List<dynamic>? ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.assignment, color: Colors.blue, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Assignments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${assignments.length}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: assignments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'No assignments yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: assignments.length,
                        itemBuilder: (context, index) {
                          return _buildAssignmentItem(assignments[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizzesBottomSheet() {
    final quizzes = _courseDetails?['quizzes'] as List<dynamic>? ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.quiz, color: Colors.orange, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Quizzes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${quizzes.length}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: quizzes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'No quizzes yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          return _buildQuizItem(quizzes[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildAssignmentItem(Map<String, dynamic> assignment) {
  String status = assignment['submission_status'] ?? 'not_submitted';
  
  // ✅ FIX: Convert to double safely
  var scoreValue = assignment['score'];
  double? score;
  if (scoreValue != null) {
    score = (scoreValue is int) ? scoreValue.toDouble() : scoreValue as double;
  }
  
  var maxScoreValue = assignment['max_score'];
  int maxScore = 100;
  if (maxScoreValue != null) {
    maxScore = (maxScoreValue is double) ? maxScoreValue.toInt() : maxScoreValue as int;
  }
  
  IconData statusIcon;
  Color statusColor;
  String statusText;
  
  if (status == 'graded') {
    statusIcon = Icons.check_circle;
    statusColor = Colors.green;
    statusText = 'Graded';
  } else if (status == 'submitted') {
    statusIcon = Icons.pending;
    statusColor = Colors.blue;
    statusText = 'Submitted';
  } else if (status == 'missing') {
    statusIcon = Icons.cancel;
    statusColor = Colors.red;
    statusText = 'Missing';
  } else {
    statusIcon = Icons.radio_button_unchecked;
    statusColor = Colors.grey;
    statusText = 'Not Submitted';
  }

  return Card(
    margin: EdgeInsets.only(bottom: 12),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] ?? 'Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Week ${assignment['week_number'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (score != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score, maxScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getScoreColor(score, maxScore)),
                  ),
                  child: Text(
                    '${score.toInt()}/$maxScore',
                    style: TextStyle(
                      color: _getScoreColor(score, maxScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuizItem(Map<String, dynamic> quiz) {
  String status = quiz['submission_status'] ?? 'not_taken';
  
  var scoreValue = quiz['score'];
  double? score;
  if (scoreValue != null) {
    score = (scoreValue is int) ? scoreValue.toDouble() : scoreValue as double;
  }
  
  var maxScoreValue = quiz['max_score'];
  int maxScore = 100;
  if (maxScoreValue != null) {
    maxScore = (maxScoreValue is double) ? maxScoreValue.toInt() : maxScoreValue as int;
  }
    
    IconData statusIcon;
    Color statusColor;
    String statusText;
    
    if (status == 'graded') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      statusText = 'Graded';
    } else {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = Colors.grey;
      statusText = 'Not Taken';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['title'] ?? 'Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Week ${quiz['week_number'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (score != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score, maxScore).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getScoreColor(score, maxScore)),
                    ),
                    child: Text(
                      '$score/$maxScore',
                      style: TextStyle(
                        color: _getScoreColor(score, maxScore),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Color _getScoreColor(dynamic score, int maxScore) {
    if (score == null) return Colors.grey;
    
    // ✅ Convert to double safely
    double scoreDouble;
    if (score is int) {
      scoreDouble = score.toDouble();
    } else if (score is double) {
      scoreDouble = score;
    } else {
      return Colors.grey;
    }
    
    double percentage = (scoreDouble / maxScore) * 100;
    
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCourseHeader() {
    final courseInfo = _dashboardData?['course_info'];
    if (courseInfo == null) return SizedBox();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseInfo['course_title'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text(
                  courseInfo['teacher_name'] ?? 'Not Assigned',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '${courseInfo['term']} ${courseInfo['year']}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Week ${courseInfo['current_week']} of ${courseInfo['total_weeks']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildStudentCard() {
    final student = _dashboardData?['student'];
    if (student == null) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                (student['name'] ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ID: ${student['student_id'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard() {
    final risk = _dashboardData?['risk'];
    if (risk == null) return SizedBox();
    Color cardColor = risk['risk_color'] == 'red' ? Colors.red[400]! : (risk['risk_color'] == 'orange' ? Colors.orange : Colors.green);
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(risk['risk_score']?.toString() ?? '0.0', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(risk['risk_level'] ?? 'UNKNOWN', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(risk['feedback'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallEngagementCard() {
    final overallEngagement = _dashboardData?['overall_engagement'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Overall',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${overallEngagement.toInt()}%',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Engagement',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Text(
              '(excl. Labs)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    final weeklyProgress = _dashboardData?['weekly_progress'] as List<dynamic>?;
    if (weeklyProgress == null || weeklyProgress.isEmpty) return SizedBox();

    List<Map<String, dynamic>> validWeeks = weeklyProgress
        .where((w) => w['has_data'] == true)
        .map((w) => Map<String, dynamic>.from(w))
        .toList();

    if (validWeeks.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No weekly progress data available yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    List<Map<String, dynamic>> displayWeeks = validWeeks.skip(_startWeek).take(4).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Average of Assignments & Quizzes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_startWeek > 0)
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _startWeek = (_startWeek - 1).clamp(0, validWeeks.length - 1);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    SizedBox(width: 8),
                    Text(
                      'Week ${_startWeek + 1}-${(_startWeek + 4).clamp(0, validWeeks.length)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    if (_startWeek + 4 < validWeeks.length)
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _startWeek = (_startWeek + 1).clamp(0, validWeeks.length - 4);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 6),
                Text('Your Score', style: TextStyle(fontSize: 12)),
                SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 6),
                Text('Class Average', style: TextStyle(fontSize: 12)),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < displayWeeks.length) {
                            int weekNumber = (displayWeeks[index]['week'] as num).toInt();
                            return Text(
                              'W$weekNumber',
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayWeeks.asMap().entries.map((entry) {
                        int index = entry.key;
                        var week = entry.value;
                        double score = (week['student_score'] ?? 0).toDouble();
                        return FlSpot(index.toDouble(), score);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: displayWeeks.asMap().entries.map((entry) {
                        int index = entry.key;
                        var week = entry.value;
                        double avg = (week['class_average'] ?? 0).toDouble();
                        return FlSpot(index.toDouble(), avg);
                      }).toList(),
                      isCurved: true,
                      color: Colors.grey,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementTrackerCard() {
    final engagement = _dashboardData?['engagement'];
    if (engagement == null) return SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEngagementItem(
                  'Attendance',
                  (engagement['attendance'] ?? 0).toDouble(),
                  Colors.blue,
                ),
                _buildEngagementItem(
                  'Assignments',
                  (engagement['assignments'] ?? 0).toDouble(),
                  Colors.green,
                ),
                _buildEngagementItem(
                  'Quizzes',
                  (engagement['quizzes'] ?? 0).toDouble(),
                  Colors.orange,
                ),
                _buildEngagementItem(
                  'Labs',
                  (engagement['lab_activity'] ?? 0).toDouble(),
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementItem(String label, double percentage, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}