// lib/screens/courses_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'survey_screen.dart';
import 'teacher_course_screen.dart';

// Duolingo-inspired color palette
class _AppColors {
  static const Color primary = Color(0xFF58CC02);      // Duolingo green
  static const Color background = Color(0xFFF7F7F7);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF3C3C3C);
  static const Color textMuted = Color(0xFF999999);
  static const Color shadow = Color(0x1A000000);

  static const List<List<Color>> courseGradients = [
    [Color(0xFF58CC02), Color(0xFF46A302)],   // green
    [Color(0xFF1CB0F6), Color(0xFF0F8FD0)],   // blue
    [Color(0xFFFF9600), Color(0xFFE08600)],   // orange
    [Color(0xFFFF4B4B), Color(0xFFD93B3B)],   // red
    [Color(0xFFA560E8), Color(0xFF8B48C8)],   // purple
    [Color(0xFFFF86D0), Color(0xFFE070B8)],   // pink
  ];

  static const List<IconData> courseIcons = [
    Icons.code_rounded,
    Icons.science_rounded,
    Icons.calculate_rounded,
    Icons.psychology_rounded,
    Icons.hub_rounded,
    Icons.storage_rounded,
  ];
}

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  List<dynamic> _courses = [];
  String _userType = 'student';
  // courseId → {pending: bool, week_number: int?}
  final Map<int, Map<String, dynamic>> _surveyStatus = {};
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadCourses();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String userType = await _apiService.getUserType() ?? '';
      if (userType.isEmpty) {
        // user_type not yet cached (logged in before this feature) — fetch from profile
        final profile = await _apiService.getProfile();
        userType = (profile['user_type'] as String?) ?? 'student';
        await _apiService.saveUserType(userType);
      }

      List<dynamic> coursesList;
      if (userType == 'teacher' || userType == 'admin') {
        coursesList = await _apiService.getTeacherCourses();
      } else {
        final coursesData = await _apiService.getCourses();
        if (coursesData is List) {
          coursesList = coursesData;
        } else if (coursesData is Map) {
          coursesList = [coursesData];
        } else {
          coursesList = [];
        }
      }

      setState(() {
        _courses = coursesList;
        _userType = userType;
        _isLoading = false;
      });
      _animController.forward(from: 0);
      if (userType == 'student') _loadSurveyStatuses(coursesList);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSurveyStatuses(List<dynamic> courses) async {
    for (final course in courses) {
      final courseId = course['course_id'] as int;
      try {
        final status = await _apiService.getAnySurveyPending(courseId);
        if (mounted) setState(() => _surveyStatus[courseId] = status);
      } catch (_) {
        // non-critical — skip silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded,
                color: _AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                if (!_isLoading && _error == null && _courses.isNotEmpty)
                  Text(
                    _userType == 'teacher' || _userType == 'admin'
                        ? '${_courses.length} course${_courses.length != 1 ? 's' : ''} teaching'
                        : '${_courses.length} course${_courses.length != 1 ? 's' : ''} enrolled',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Streak-style badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFFF9600), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_courses.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF9600),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_courses.isEmpty) {
      return _buildEmptyState();
    }
    return _buildCourseList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_AppColors.primary),
              backgroundColor: _AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading courses...',
            style: TextStyle(
              color: _AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B4B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 48, color: Color(0xFFFF4B4B)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load your courses.\nPlease check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            _buildPrimaryButton('Try Again', _loadCourses),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 56, color: _AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No courses yet!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userType == 'teacher' || _userType == 'admin'
                  ? 'Your assigned courses will\nappear here.'
                  : 'Your enrolled courses will\nappear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    return RefreshIndicator(
      onRefresh: _loadCourses,
      color: _AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(index);
        },
      ),
    );
  }

  Widget _buildCourseCard(int index) {
    final course = _courses[index];
    final colors =
        _AppColors.courseGradients[index % _AppColors.courseGradients.length];
    final icon =
        _AppColors.courseIcons[index % _AppColors.courseIcons.length];
    final courseId = course['course_id'] as int;
    final isStudent = _userType == 'student';
    final status = isStudent ? _surveyStatus[courseId] : null;
    final hasPending = status != null && status['pending'] == true;

    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(
          (index * 0.15).clamp(0.0, 0.8),
          ((index * 0.15) + 0.4).clamp(0.2, 1.0),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          if (hasPending)
            _buildSurveyBanner(
              courseId: courseId,
              weekNumber: status['week_number'] as int,
              courseName: course['course_code'] ?? '',
            ),
          _buildCardContent(course, colors, icon),
        ],
      ),
    );
  }

  Widget _buildSurveyBanner({
    required int courseId,
    required int weekNumber,
    required String courseName,
  }) {
    return GestureDetector(
      onTap: () async {
        final submitted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SurveyScreen(
              courseId: courseId,
              weekNumber: weekNumber,
              courseName: courseName,
            ),
          ),
        );
        if (submitted == true && mounted) {
          setState(() => _surveyStatus[courseId] = {'pending': false, 'week_number': weekNumber});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC02).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rate_review_rounded,
                  color: Color(0xFFE6A800), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Survey Pending',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7A5500))),
                  Text('Week $weekNumber feedback awaits',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFB07800))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFE6A800)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(
      dynamic course, List<Color> colors, IconData icon) {
    final courseCode = course['course_code'] ?? 'Unknown';
    final courseTitle = course['course_title'] ?? 'No Title';
    final term = course['term'] ?? '';
    final year = course['year']?.toString() ?? '';
    final isTeacher = _userType == 'teacher' || _userType == 'admin';
    final studentCount = course['student_count'] as int? ?? 0;
    final currentWeek = course['current_week'] as int? ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _userType == 'teacher' || _userType == 'admin'
              ? TeacherCourseScreen(
                  courseId: course['course_id'] as int,
                  courseCode: courseCode,
                  courseTitle: courseTitle,
                )
              : DashboardScreen(
                  courseId: course['course_id'],
                  courseName: courseCode,
                ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: _AppColors.shadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top colored banner with icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          courseTitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  if (isTeacher) ...[
                    _buildInfoChip(Icons.people_rounded,
                        '$studentCount student${studentCount != 1 ? 's' : ''}', colors[0]),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.bar_chart_rounded,
                        currentWeek > 0 ? 'Week $currentWeek' : 'No class yet', colors[0]),
                  ] else
                    _buildInfoChip(Icons.calendar_today_rounded,
                        '$term $year', colors[0]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTeacher ? 'Manage' : 'Continue',
                          style: TextStyle(
                            color: colors[0],
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            color: colors[0], size: 18),
                      ],
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: _AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: _AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
