import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SurveyScreen extends StatefulWidget {
  final int courseId;
  final int weekNumber;
  final String courseName;

  const SurveyScreen({
    super.key,
    required this.courseId,
    required this.weekNumber,
    required this.courseName,
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _api = ApiService();

  List<dynamic> _questions = [];
  final Map<int, int> _scores = {}; // question_id → score (1–5 integer)
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  static const _primary = Color(0xFF58CC02);
  static const _bg = Color(0xFFF7F7F7);
  static const _dark = Color(0xFF3C3C3C);
  static const _muted = Color(0xFF999999);

  static const _questionColors = [
    Color(0xFF1CB0F6),
    Color(0xFFFF9600),
    Color(0xFF58CC02),
    Color(0xFFA560E8),
    Color(0xFFFF4B4B),
  ];

  static const _questionIcons = [
    Icons.bolt_rounded,
    Icons.trending_up_rounded,
    Icons.sentiment_satisfied_alt_rounded,
    Icons.school_rounded,
    Icons.lightbulb_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _api.getSurveyQuestions();
      setState(() {
        _questions = questions;
        for (final q in questions) {
          _scores[q['question_id'] as int] = 3;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final answers = _scores.entries
          .map((e) => {'question_id': e.key, 'score': e.value})
          .toList();
      await _api.submitSurveyAnswers(
        courseId: widget.courseId,
        weekNumber: widget.weekNumber,
        answers: answers,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F8E0), shape: BoxShape.circle),
              child:
                  const Icon(Icons.check_circle_rounded, color: _primary, size: 52),
            ),
            const SizedBox(height: 16),
            const Text('Thank you!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _dark)),
            const SizedBox(height: 8),
            const Text('Your feedback has been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 15)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // signal completion to caller
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  String _label(int v) {
    if (v == 1) return 'Very Low';
    if (v == 2) return 'Low';
    if (v == 3) return 'Moderate';
    if (v == 4) return 'High';
    return 'Very High';
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
            Text(widget.courseName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _dark)),
            Text('Week ${widget.weekNumber} Survey',
                style: const TextStyle(fontSize: 12, color: _muted)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildBanner(),
                            const SizedBox(height: 24),
                            ..._questions.asMap().entries.map(
                                  (e) => _buildCard(e.key, e.value),
                                ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _buildSubmitButton(),
                  ],
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
            const Icon(Icons.error_outline_rounded, size: 56, color: Color(0xFFFF4B4B)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: _dark, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuestions,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF46A302)],
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
            child: const Icon(Icons.rate_review_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class Feedback',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Rate each area from 1 (Very Low) to 5 (Very High)',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, dynamic question) {
    final id = question['question_id'] as int;
    final title = question['title'] as String;
    final detail = question['detail'] as String;
    final color = _questionColors[index % _questionColors.length];
    final icon = _questionIcons[index % _questionIcons.length];
    final value = _scores[id] ?? 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _dark)),
                    Text(detail,
                        style: const TextStyle(fontSize: 12, color: _muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$value',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _scores[id] = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1 · Very Low',
                  style: TextStyle(fontSize: 11, color: _muted)),
              Text(_label(value),
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w700)),
              const Text('5 · Very High',
                  style: TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: (_submitting || _questions.isEmpty) ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : const Text('Submit Feedback',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
