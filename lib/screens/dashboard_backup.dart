import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  final int courseId;
  final String courseName;
  
  DashboardScreen({required this.courseId, required this.courseName});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getDashboard(widget.courseId);
      setState(() {
        _data = data;
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
        title: Text(_data?['course_info']?['course_code'] ?? widget.courseName),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildCourseHeader(),
                        _buildMainContent(),
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
            const Text(
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loadDashboard, child: Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    final courseInfo = _data?['course_info'];
    if (courseInfo == null) return SizedBox();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseInfo['course_title'] ?? '',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text(courseInfo['teacher_name'] ?? 'Teacher', style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(width: 16),
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text('${courseInfo['term']} ${courseInfo['year']}', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Week ${courseInfo['current_week']} of ${courseInfo['total_weeks'] ?? 7}',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentCard(),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRiskCard()),
              SizedBox(width: 16),
              Expanded(child: _buildEngagementSummary()),
            ],
          ),
          SizedBox(height: 16),
          _buildWeeklyProgressCard(),
          SizedBox(height: 16),
          _buildEngagementDetails(),
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    final student = _data?['student'];
    if (student == null) return SizedBox();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['name'] ?? 'Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('ID: ${student['student_id']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard() {
    final risk = _data?['risk'];
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

  Widget _buildEngagementSummary() {
    final overallEngagement = _data?['overall_engagement'];
    if (overallEngagement == null) return SizedBox();
    double avg = (overallEngagement as num?)?.toDouble() ?? 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 180,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Overall', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            SizedBox(height: 8),
            SizedBox(
              width: 85,
              height: 85,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: (avg / 100).clamp(0.0, 1.0),
                    strokeWidth: 7,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(avg >= 70 ? Colors.green : (avg >= 50 ? Colors.orange : Colors.red)),
                  ),
                  Text('${avg.toInt()}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: [
                Text('Engagement', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text('(excl. Labs)', style: TextStyle(fontSize: 8, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    final weeklyProgress = _data?['weekly_progress'];
    
    final List<Map<String, dynamic>> weeksWithData = [];
    if (weeklyProgress != null) {
      for (var w in weeklyProgress) {
        if (w is Map && w['has_data'] == true) {
          weeksWithData.add({
            'week': (w['week'] as num?)?.toInt() ?? 0,
            'student_score': (w['student_score'] as num?)?.toDouble() ?? 0.0,
            'class_average': (w['class_average'] as num?)?.toDouble() ?? 0.0,
          });
        }
      }
    }

    // Trigger placeholder if no data OR if only Week 1 data is available
    if (weeksWithData.isEmpty || (weeksWithData.length == 1 && weeksWithData.first['week'] == 1)) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 300,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 8, height: 20, color: Colors.grey[200]),
                  SizedBox(width: 4),
                  Container(width: 8, height: 40, color: Colors.grey[200]),
                  SizedBox(width: 4),
                  Container(width: 8, height: 25, color: Colors.grey[200]),
                ],
              ),
              SizedBox(height: 24),
              Text('Weekly Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 8),
              Text('No data available yet.', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.chevron_left, color: Colors.grey[400], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Week ${weeksWithData.first['week']}-${weeksWithData.last['week']}', 
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Average of Assignments & Quizzes', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Your Score', Colors.blue),
                SizedBox(width: 20),
                _buildLegend('Class Average', Colors.grey[400]!),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (weeksWithData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true, 
                    horizontalInterval: 25, 
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1, dashArray: [5, 5]),
                  ),
                  borderData: FlBorderData(show: false), // Border line removed
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < weeksWithData.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('W${weeksWithData[index]['week']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, 
                        interval: 25, 
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeksWithData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['student_score'])).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.blue, strokeWidth: 2, strokeColor: Colors.white),
                      ),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.08)),
                    ),
                    LineChartBarData(
                      spots: weeksWithData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['class_average'])).toList(),
                      isCurved: true,
                      color: Colors.grey[400]!,
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3.5, color: Colors.grey[400]!, strokeWidth: 2, strokeColor: Colors.white),
                      ),
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

  Widget _buildLegend(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      SizedBox(width: 6), 
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]))
    ]);
  }

  Widget _buildEngagementDetails() {
    final eng = _data?['engagement'];
    if (eng == null) return SizedBox();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Engagement Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEngagementCircle('Attendance', (eng['attendance'] as num).toDouble(), Colors.blue),
                _buildEngagementCircle('Assignments', (eng['assignments'] as num).toDouble(), Colors.green),
                _buildEngagementCircle('Quizzes', (eng['quizzes'] as num).toDouble(), Colors.orange),
                _buildEngagementCircle('Labs', (eng['lab_activity'] as num).toDouble(), Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementCircle(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 65, height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (value / 100).clamp(0.0, 1.0), 
                strokeWidth: 5, 
                backgroundColor: Colors.grey[100], 
                valueColor: AlwaysStoppedAnimation<Color>(color)
              ),
              Text('${value.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]), textAlign: TextAlign.center),
      ],
    );
  }
}