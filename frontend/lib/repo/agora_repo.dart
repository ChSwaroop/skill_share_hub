import 'dart:convert';
import 'package:http/http.dart' as http;

class AgoraRepo {
  final String baseUrl;

  AgoraRepo({required this.baseUrl});

  Future<Map<String, dynamic>> generateToken({
    required String channelName,
    int? uid,
    String role = 'publisher',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rtc-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid,
          'role': role,
          'expirationTimeInSeconds': 3600, // 1 hour
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate token: $e');
    }
  }

  Future<String> startCall({
    required String callType, // 'audio' or 'video'
    required List<String> participants,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/start-call'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'callType': callType,
          'participants': participants,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['channelName'];
      } else {
        throw Exception('Failed to start call: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to start call: $e');
    }
  }
}
