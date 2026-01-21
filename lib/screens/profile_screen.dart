// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.blue),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.blue,
                  child: Column(
                    children: [
                      CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                      SizedBox(height: 10),
                      Text(_profile!['full_name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(_profile!['student_id'], style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text(_profile!['email']),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone'),
                  subtitle: Text(_profile!['phone'] ?? 'Not set'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Country'),
                  subtitle: Text(_profile!['country'] ?? 'Not set'),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}