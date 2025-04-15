import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/recommendation%20models/personalized_recommendations_model.dart';

class RecommendationRepo {
  Future<PersonalizedRecommendation?> fetchPersonalizedRecommendations(
      String token,
      {int limit = 10}) async {
    final String apiUrl =
        '$baseUrl/api/recommendations/personalized'; // Replace with actual API endpoint

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          // Add auth headers if needed, e.g.
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = personalizedRecommendationFromJson(response.body);
        return data;
      } else {
        print('Failed to load recommendations: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching personalized recommendations: $e');
      return null;
    }
  }
}
