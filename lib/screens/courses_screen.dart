// lib/screens/courses_screen.dart - REPLACE ALL

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _apiService = ApiService();
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

Future<void> _loadCourses() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final coursesData = await _apiService.getCourses();
    
    // ✅ Convert to List regardless of response type
    List<dynamic> coursesList = [];
    
    if (coursesData is List) {
      coursesList = coursesData;
    } else if (coursesData is Map) {
      // If single object, wrap in list
      coursesList = [coursesData];
    }
    
    setState(() {
      _courses = coursesList;
      _isLoading = false;
    });
    
    print('✅ Loaded ${coursesList.length} courses');
  } catch (e) {
    print('❌ Error loading courses: $e');
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error loading courses'),
                      SizedBox(height: 8),
                      Text(_error!, style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadCourses();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No courses enrolled',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCourses,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.book, color: Colors.white),
                              ),
                              title: Text(
                                course['course_code'] ?? 'Unknown',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(course['course_title'] ?? 'No Title'),
                                  SizedBox(height: 4),
                                  Text(
                                    '${course['term']} ${course['year']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DashboardScreen(
                                    courseId: course['course_id'],
                                    courseName: course['course_code'] ?? 'Course',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),
    );
  }
}