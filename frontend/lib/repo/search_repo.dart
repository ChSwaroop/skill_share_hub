import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/user_search_model.dart'; // Ensure correct path

class UserService {
  // final String baseUrl =
  //     "https://your-api-url.com"; // Replace with actual API URL

  Future<UserSearchModel?> searchUsersBySkill(
      String skill, String authToken) async {
    final Uri url = Uri.parse("$baseUrl/api/users/search/skill?skill=$skill");

    try {
      debugPrint("Calling API: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer $authToken", // Add authentication if required
        },
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return userSearchModelFromJson(response.body);
      } else {
        debugPrint(
            "API Error: ${jsonDecode(response.body)["message"] ?? "Unknown error"}");
        return null;
      }
    } catch (e) {
      debugPrint("Error in searchUsersBySkill: $e");
      return null;
    }
  }
}
