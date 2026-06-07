import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TeacherCourseScreen extends StatefulWidget {
  final int courseId;
  final String courseCode;
  final String courseTitle;

  const TeacherCourseScreen({
    super.key,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
  });

  @override
  State<TeacherCourseScreen> createState() => _TeacherCourseScreenState();
}

class _TeacherCourseScreenState extends State<TeacherCourseScreen> {
  final _api = ApiService();

  List<dynamic> _weeks = [];
  int _maxWeek = 0;
  int _studentCount = 0;
  bool _loading = true;
  String? _error;
  // weekNumber → is currently releasing (button loading state)
  final Map<int, bool> _releasing = {};

  static const _primary = Color(0xFF58CC02);
  static const _bg = Color(0xFFF7F7F7);
  static const _dark = Color(0xFF3C3C3C);
  static const _muted = Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadWeeks();
  }

  Future<void> _loadWeeks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getSurveyWeekStatus(widget.courseId);
      setState(() {
        _weeks = data['weeks'] as List<dynamic>;
        _maxWeek = data['max_week'] as int? ?? 0;
        _studentCount = data['student_count'] as int? ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _release(int weekNumber) async {
    setState(() => _releasing[weekNumber] = true);
    try {
      await _api.releaseSurvey(widget.courseId, weekNumber);
      if (!mounted) return;
      // Update local state so button becomes disabled immediately
      setState(() {
        final idx = _weeks.indexWhere((w) => w['week'] == weekNumber);
        if (idx != -1) {
          _weeks[idx] = Map<String, dynamic>.from(_weeks[idx] as Map)
            ..['released'] = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $weekNumber survey released to students.'),
          backgroundColor: _primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _releasing.remove(weekNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseCode,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: _dark)),
            Text(widget.courseTitle,
                style: const TextStyle(fontSize: 12, color: _muted),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadWeeks,
                  color: _primary,
                  child: _maxWeek == 0
                      ? _buildNoAttendance()
                      : _buildContent(),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: Color(0xFFFF4B4B)),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _dark, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadWeeks,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAttendance() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note_rounded,
                    size: 52, color: _primary),
              ),
              const SizedBox(height: 20),
              const Text('No attendance data yet',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _dark)),
              const SizedBox(height: 8),
              const Text(
                'Survey weeks are determined by\nattendance records.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          ..._weeks.map((w) => _buildWeekCard(w as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final released = _weeks.where((w) => w['released'] == true).length;
    final total = _weeks.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB0F6), Color(0xFF0F8FD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.assignment_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Survey Management',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_studentCount student${_studentCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.bar_chart_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _maxWeek > 0 ? 'Week $_maxWeek current' : 'No class yet',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$released of $total week${total != 1 ? 's' : ''} released',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(Map<String, dynamic> weekData) {
    final week = weekData['week'] as int;
    final released = weekData['released'] as bool;
    final studentCount = weekData['student_count'] as int? ?? 0;
    final doneCount = weekData['done_count'] as int? ?? 0;
    final isReleasing = _releasing[week] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: released
            ? Border.all(color: _primary.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: (released ? _primary : Colors.grey)
                .withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Week number badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: released
                  ? _primary.withValues(alpha: 0.12)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: released ? _primary : _muted,
                  ),
                ),
                Text(
                  'Wk',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: released ? _primary : _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Week $week Survey',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _dark)),
                const SizedBox(height: 3),
                Text(
                  released
                      ? '$doneCount of $studentCount done'
                      : '$studentCount student${studentCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: released
                        ? (doneCount == studentCount && studentCount > 0
                            ? _primary
                            : _muted)
                        : _muted,
                    fontWeight: released ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status chip + Release button
          released
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          color: _primary, size: 16),
                      SizedBox(width: 5),
                      Text('Released',
                          style: TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                )
              : SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: isReleasing ? null : () => _release(week),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB0F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isReleasing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('Release',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                  ),
                ),
        ],
      ),
    );
  }
}
