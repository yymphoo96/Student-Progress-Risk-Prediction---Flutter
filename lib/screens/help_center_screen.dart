import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact support card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text('Need Help?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Contact your instructor or admin for assistance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please contact support at support@edurisk.app'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: const Text('Contact Support',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // FAQ section
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFAQ(
            'How do I view my courses?',
            'Tap the "Courses" tab at the bottom of the screen to see all your enrolled courses. Tap on any course to view its dashboard with assignments and risk score.',
          ),
          _buildFAQ(
            'What is a Risk Score?',
            'The Risk Score is an assessment of your academic performance risk, calculated based on your assignment grades and completion rate. A lower score means you are performing well.',
          ),
          _buildFAQ(
            'How do I update my profile?',
            'Go to Profile > Personal Profile. You can edit your name, phone number, and country. Tap "Save Changes" when done.',
          ),
          _buildFAQ(
            'How are grades calculated?',
            'Grades are assigned by your instructors. You can view your grades on the course dashboard under each assignment.',
          ),
          _buildFAQ(
            'Can I enroll in new courses?',
            'Course enrollment is managed by your institution. Contact your administrator to be added to a course.',
          ),
          _buildFAQ(
            'How do I reset my password?',
            'On the login screen, contact your administrator for password reset assistance.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(question,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(answer,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }
}
