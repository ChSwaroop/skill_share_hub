import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/login_model.dart';

class AuthRepo {
  final _storage = const FlutterSecureStorage();
  // final UserProvider userProvider;

  // AuthRepo(this.userProvider);

  Future<LoginModel> registerUser(
      {required String firstName,
      required String lastName,
      required String userName,
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
        'username': userName,
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
      debugPrint("-------------------------------------------------");
      debugPrint("registration result: " + responseData.toString());

      if (response.statusCode == 201) {
        // Registration successful
        // final String token = responseData['token'];
        // await Provider.of<UserProvider>(context).setToken(token);
        final data = loginModelFromJson(response.body);
        // return {
        //   'success': true,
        //   'message': responseData['message'] ?? 'User registered successfully',
        //   'loggedin': responseData['loggedin'] ?? false,
        // };
        return data;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        debugPrint(errorData['message'] ?? 'registration failed');
        throw Exception(errorData['message'] ?? 'registration failed');
        // return null;
      }
    } catch (e) {
      debugPrint("Error while register in: " + e.toString());
      rethrow;
      // return null;
    }
  }

  Future<LoginModel> login(String email, String password) async {
    try {
      debugPrint("login called");
      final url = Uri.parse('${baseUrl}/api/auth/login');

      final body = jsonEncode({
        'username': email,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> data = jsonDecode(response.body);
        final loginModel = loginModelFromJson(response.body);
        debugPrint("name: ${loginModel.user!.firstName}");
        debugPrint("id: ${loginModel.user!.id}");

        // Save the token securely if needed
        // await userProvider.setToken(loginModel.token);

        return loginModel;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        debugPrint(errorData['message'] ?? 'Login failed');
        throw Exception(errorData['message'] ?? 'Login failed');
        // return null;
      }
    } catch (e) {
      debugPrint("Error while logging in: " + e.toString());
      rethrow;
      // return null;
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
