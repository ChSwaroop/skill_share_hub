import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/connection_model.dart';

class ConnectionRepo {
  Future<void> createConnection({
    required String recipientId,
    String? connectionNotes,
    required String authToken, // Authentication token
  }) async {
    final String url = "$baseUrl/api/connections"; // Replace with your API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $authToken", // Add authentication if required
        },
        body: jsonEncode({
          "recipientId": recipientId,
          "connectionNotes": connectionNotes,
        }),
      );
      debugPrint("connection request sent");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(
            "Connection request created successfully: ${responseData['data']}");
        return responseData;
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        print("Error: $errorMessage");
        return null;
      }
    } catch (e) {
      print("Error while making API call: $e");
      return null;
    }
  }

  Future<Connection> getMyConnections(
      String? status, int page, int limit, String authToken) async {
    final Uri uri = Uri.parse('$baseUrl/api/connections');

    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final Uri finalUri = uri.replace(queryParameters: queryParams);

    try {
      print('Fetching connections from: $finalUri'); // Debug: Print the URL

      final response = await http.get(
        finalUri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print(
          'Response status code: ${response.statusCode}'); // Debug: Print status code
      print(
          'Response body: ${response.body}'); // Debug: Print the response body

      if (response.statusCode == 200) {
        final Connection connection = connectionFromJson(response.body);
        print(
            'Connections fetched successfully: ${connection.data?.length} items'); // Debug: number of items.
        return connection;
      } else {
        print(
            'Failed to load connections: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to load connections: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error loading connections: $error');
      throw Exception('Error loading connections: $error');
    }
  }
}
