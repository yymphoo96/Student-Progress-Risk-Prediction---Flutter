import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _assignmentReminders = true;
  bool _gradeAlerts = true;
  bool _riskScoreAlerts = true;
  bool _courseUpdates = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('NOTIFICATION PREFERENCES'),
          SwitchListTile(
            secondary: const Icon(Icons.assignment_late, color: Colors.orange),
            title: const Text('Assignment Reminders'),
            subtitle: const Text('Get reminded about upcoming deadlines'),
            value: _assignmentReminders,
            activeColor: Colors.blue,
            onChanged: (v) {
              setState(() => _assignmentReminders = v);
              _showSavedSnackbar();
            },
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(Icons.grade, color: Colors.green),
            title: const Text('Grade Alerts'),
            subtitle: const Text('Notify when grades are posted'),
            value: _gradeAlerts,
            activeColor: Colors.blue,
            onChanged: (v) {
              setState(() => _gradeAlerts = v);
              _showSavedSnackbar();
            },
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber, color: Colors.red),
            title: const Text('Risk Score Alerts'),
            subtitle: const Text('Alert when risk score changes significantly'),
            value: _riskScoreAlerts,
            activeColor: Colors.blue,
            onChanged: (v) {
              setState(() => _riskScoreAlerts = v);
              _showSavedSnackbar();
            },
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(Icons.campaign, color: Colors.blue),
            title: const Text('Course Updates'),
            subtitle: const Text('News and announcements from courses'),
            value: _courseUpdates,
            activeColor: Colors.blue,
            onChanged: (v) {
              setState(() => _courseUpdates = v);
              _showSavedSnackbar();
            },
          ),
          _buildSectionHeader('DISPLAY'),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showLanguagePicker(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preference saved'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...['English', 'Japanese', 'Myanmar'].map(
              (lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(ctx);
                  _showSavedSnackbar();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
