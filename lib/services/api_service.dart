// lib/services/api_service.dart - ADD OTP methods

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.2:8000/api';//local
  // static const String baseUrl = 'http://210.146.64.139:8088/api'; //production
  

  // Token management (keep existing methods)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ✅ NEW: Step 1 - Request OTP
  Future<Map<String, dynamic>> registerRequest({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    int? gender,
    String? country,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'username': username,
      'password': password,
      'password2': password,
      'first_name': firstName,
      'last_name': lastName,
      'student_id': studentId,
    };
    if (gender != null) body['gender'] = gender;
    if (country != null) body['country'] = country;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register_request/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      String errorMessage = 'Registration failed';
      
      if (error is Map) {
        if (error.containsKey('email')) {
          errorMessage = error['email'][0];
        } else if (error.containsKey('username')) {
          errorMessage = 'Username: ${error['username'][0]}';
        } else if (error.containsKey('student_id')) {
          errorMessage = 'Student ID: ${error['student_id'][0]}';
        } else if (error.containsKey('password')) {
          errorMessage = error['password'][0];
        } else if (error.containsKey('error')) {
          errorMessage = error['error'];
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  // ✅ NEW: Step 2 - Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify_otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      String errorMessage = 'Invalid OTP';
      
      if (error is Map) {
        if (error.containsKey('non_field_errors')) {
          errorMessage = error['non_field_errors'][0];
        } else if (error.containsKey('error')) {
          errorMessage = error['error'];
        } else if (error.containsKey('otp_code')) {
          errorMessage = error['otp_code'][0];
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  // ✅ NEW: Resend OTP
  Future<Map<String, dynamic>> resendOTP({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend_otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to resend OTP');
    }
  }

  // Login (keep existing)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      String errorMessage = 'Login failed';
      
      if (error is Map && error.containsKey('error')) {
        errorMessage = error['error'];
      }
      
      throw Exception(errorMessage);
    }
  }

  // Logout (keep existing)
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
    }
    await clearToken();
  }

  // Get profile (keep existing)
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Update profile (keep existing)
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? country,
    int? gender,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (country != null) body['country'] = country;
    if (gender != null) body['gender'] = gender;

    final response = await http.patch(
      Uri.parse('$baseUrl/auth/update_profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // Get courses (keep existing)
  Future<dynamic> getCourses() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/courses/my_courses/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('courses')) {
          return decoded['courses'];
        }
        return [decoded];
      }
      
      return [];
    } else {
      throw Exception('Failed to load courses: ${response.body}');
    }
  }

  // Get dashboard (keep existing)
  Future<Map<String, dynamic>> getDashboard(int courseId) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/student_dashboard/?course_id=$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }
  Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
  final token = await getToken();
  if (token == null) throw Exception('Not authenticated');

  final response = await http.get(
    Uri.parse('$baseUrl/courses/$courseId/course_details/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    },
  );

  print('Course Details Response Status: ${response.statusCode}');
  print('Course Details Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load course details: ${response.body}');
  }
  }

  // Forgot password - request OTP
  Future<Map<String, dynamic>> forgotPasswordRequest({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot_password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send reset code');
      } on FormatException {
        throw Exception('Failed to send reset code. Please try again.');
      }
    }
  }

  // Forgot password - reset with OTP
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset_password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      String errorMessage = 'Failed to reset password';
      if (error is Map) {
        if (error.containsKey('error')) {
          errorMessage = error['error'];
        } else if (error.containsKey('non_field_errors')) {
          errorMessage = error['non_field_errors'][0];
        }
      }
      throw Exception(errorMessage);
    }
  }
}