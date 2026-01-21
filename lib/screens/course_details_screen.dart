
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import 'dashboard_screen.dart';

// class CourseDetailsScreen extends StatefulWidget {
//   final int courseId;
//   final String courseName;
  
//   CourseDetailsScreen({required this.courseId, required this.courseName});

//   @override
//   _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
// }

// class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
//   final _apiService = ApiService();
//   Map<String, dynamic>? _data;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadCourseDetails();
//   }

//   Future<void> _loadCourseDetails() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final data = await _apiService.getCourseDetails(widget.courseId);
//       setState(() {
//         _data = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(widget.courseName),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.analytics),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => DashboardScreen(
//                     courseId: widget.courseId,
//                     courseName: widget.courseName,
//                   ),
//                 ),
//               );
//             },
//             tooltip: 'View Analytics',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _error != null
//               ? _buildErrorState()
//               : RefreshIndicator(
//                   onRefresh: _loadCourseDetails,
//                   child: SingleChildScrollView(
//                     physics: AlwaysScrollableScrollPhysics(),
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildCourseHeader(),
//                         SizedBox(height: 24),
//                         _buildAssignmentsSection(),
//                         SizedBox(height: 24),
//                         _buildQuizzesSection(),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 60, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               'Failed to load course details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(_error!, textAlign: TextAlign.center),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadCourseDetails,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCourseHeader() {
//     final course = _data?['course'];
//     if (course == null) return SizedBox();

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue, Colors.blue[700]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               course['course_code'] ?? '',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               course['course_title'] ?? '',
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Icon(Icons.calendar_today, color: Colors.white70, size: 16),
//                 SizedBox(width: 8),
//                 Text(
//                   '${course['term']} ${course['year']}',
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAssignmentsSection() {
//     final assignments = _data?['assignments'] as List<dynamic>?;
    
//     if (assignments == null || assignments.isEmpty) {
//       return _buildEmptySection('Assignments', Icons.assignment);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.assignment, color: Colors.blue, size: 28),
//             SizedBox(width: 12),
//             Text(
//               'Assignments',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             Spacer(),
//             _buildCompletionBadge(assignments),
//           ],
//         ),
//         SizedBox(height: 12),
//         ...assignments.map((assignment) => _buildAssignmentCard(assignment)).toList(),
//       ],
//     );
//   }

//   Widget _buildQuizzesSection() {
//     final quizzes = _data?['quizzes'] as List<dynamic>?;
    
//     if (quizzes == null || quizzes.isEmpty) {
//       return _buildEmptySection('Quizzes', Icons.quiz);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.quiz, color: Colors.orange, size: 28),
//             SizedBox(width: 12),
//             Text(
//               'Quizzes',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             Spacer(),
//             _buildCompletionBadge(quizzes),
//           ],
//         ),
//         SizedBox(height: 12),
//         ...quizzes.map((quiz) => _buildQuizCard(quiz)).toList(),
//       ],
//     );
//   }

//   Widget _buildCompletionBadge(List<dynamic> items) {
//     int completed = items.where((item) {
//       String status = item['submission_status'] ?? 'not_submitted';
//       return status == 'submitted' || status == 'graded' || status == 'completed';
//     }).length;
    
//     int total = items.length;
//     Color badgeColor = completed == total ? Colors.green : Colors.orange;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: badgeColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: badgeColor),
//       ),
//       child: Text(
//         '$completed/$total',
//         style: TextStyle(
//           color: badgeColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
//     String status = assignment['submission_status'] ?? 'not_submitted';
//     var score = assignment['score'];
//     int maxScore = assignment['max_score'] ?? 100;
    
//     IconData statusIcon;
//     Color statusColor;
//     String statusText;
    
//     if (status == 'graded') {
//       statusIcon = Icons.check_circle;
//       statusColor = Colors.green;
//       statusText = 'Graded';
//     } else if (status == 'submitted') {
//       statusIcon = Icons.pending;
//       statusColor = Colors.blue;
//       statusText = 'Submitted';
//     } else if (status == 'missing') {
//       statusIcon = Icons.cancel;
//       statusColor = Colors.red;
//       statusText = 'Missing';
//     } else {
//       statusIcon = Icons.radio_button_unchecked;
//       statusColor = Colors.grey;
//       statusText = 'Not Submitted';
//     }

//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // TODO: Navigate to assignment details
//         },
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(Icons.assignment, color: Colors.blue, size: 20),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           assignment['title'] ?? 'Assignment',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Week ${assignment['week_number'] ?? 'N/A'}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Divider(height: 1),
//               SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(statusIcon, color: statusColor, size: 18),
//                       SizedBox(width: 6),
//                       Text(
//                         statusText,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (score != null)
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: _getScoreColor(score, maxScore).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '$score/$maxScore',
//                         style: TextStyle(
//                           color: _getScoreColor(score, maxScore),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuizCard(Map<String, dynamic> quiz) {
//     String status = quiz['submission_status'] ?? 'not_taken';
//     var score = quiz['score'];
//     int maxScore = quiz['max_score'] ?? 100;
    
//     IconData statusIcon;
//     Color statusColor;
//     String statusText;
    
//     if (status == 'completed') {
//       statusIcon = Icons.check_circle;
//       statusColor = Colors.green;
//       statusText = 'Completed';
//     } else {
//       statusIcon = Icons.radio_button_unchecked;
//       statusColor = Colors.grey;
//       statusText = 'Not Taken';
//     }

//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // TODO: Navigate to quiz details
//         },
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(Icons.quiz, color: Colors.orange, size: 20),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           quiz['title'] ?? 'Quiz',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Week ${quiz['week_number'] ?? 'N/A'}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Divider(height: 1),
//               SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(statusIcon, color: statusColor, size: 18),
//                       SizedBox(width: 6),
//                       Text(
//                         statusText,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (score != null)
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: _getScoreColor(score, maxScore).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '$score/$maxScore',
//                         style: TextStyle(
//                           color: _getScoreColor(score, maxScore),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptySection(String title, IconData icon) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: Colors.grey, size: 28),
//             SizedBox(width: 12),
//             Text(
//               title,
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),
//         Card(
//           elevation: 1,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: EdgeInsets.all(32),
//             child: Center(
//               child: Column(
//                 children: [
//                   Icon(icon, size: 48, color: Colors.grey[300]),
//                   SizedBox(height: 12),
//                   Text(
//                     'No $title yet',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getScoreColor(dynamic score, int maxScore) {
//     if (score == null) return Colors.grey;
    
//     double percentage = (score / maxScore) * 100;
    
//     if (percentage >= 80) return Colors.green;
//     if (percentage >= 60) return Colors.orange;
//     return Colors.red;
//   }
// }