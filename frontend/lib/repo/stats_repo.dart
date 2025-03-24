import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/messageStatsModel.dart';
import 'package:http/http.dart' as http;

class StatsRepo {
  Future<MessageStats?> getMessageStats(String userId, int number) async {
    debugPrint("userId: " + userId);
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/message-stats/$userId/?days=$number'));

      if (response.statusCode == 200) {
        debugPrint("message stats in repo: ${response.body}");
        final data = messageStatsFromJson(response.body);
        return data;
      } else {
        debugPrint("Error fetching message stats: " + response.body);
        return null;
      }
    } catch (err) {
      debugPrint("Error fetching message stats: ${err.toString()}");
      return null;
    }
  }
}
