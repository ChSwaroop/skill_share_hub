import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skill_share_hub/constants.dart';

class AuthRepo {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> registerUser(
      {required String firstName,
      required String lastName,
      required String dateOfBirth,
      required String gender,
      required String email,
      required String phoneNumber,
      required String occupation,
      required String company,
      required String education,
      required String workExperience,
      required String internshipExperience,
      required List<String> skills,
      required List<String> certifications,
      required String password,
      required String startYear,
      required String endYear}) async {
    try {
      // API endpoint
      final url = Uri.parse('$baseUrl/api/auth/register');

      List<Map<String, dynamic>> ct = [];
      for (var i = 0; i < certifications.length; i++) {
        ct.add({
          "title": certifications[i],
        });
      }

      // Request body
      final body = jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'email': email,
        'phoneNumber': phoneNumber,
        'occupation': occupation,
        'company': company,
        'education': [
          {"level": education, "startDate": startYear, "endDate": endYear}
        ],
        'workExperience': [
          {
            "role": workExperience,
          }
        ],
        'internshipExperience': [
          {"role": internshipExperience}
        ],
        'skills': skills,
        'certifications': certifications,
        'password': password,
      });

      debugPrint("Signup Request: $body");

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Decode the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registration successful
        return {
          'success': true,
          'message': responseData['message'] ?? 'User registered successfully',
          'loggedin': responseData['loggedin'] ?? false,
        };
      } else {
        // Handle specific errors returned from the server
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please try again.'
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Server returned an unexpected response format.'
      };
    } catch (e) {
      debugPrint("Error in registration: $e");
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}'
      };
    }
  }

  // Login method that takes email and password
  Future<String> login(String email, String password) async {
    try {
      // Prepare the API endpoint
      debugPrint("login called");
      final url = Uri.parse('${baseUrl}/api/auth/login');

      // Prepare the request body
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      // Make the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Check response status
      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the token
        final String token = data['token'];

        // Save the token securely
        await _storage.write(key: 'auth_token', value: token);

        // Return the token
        return token;
      } else {
        // Handle error responses
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        debugPrint(errorData['message'] ?? 'Login failed');
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Handle exceptions
      debugPrint("Error while logging in:" + e.toString());
      rethrow;
    }
  }

  // Method to get the saved token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Method to check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Method to logout (clear token)
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
