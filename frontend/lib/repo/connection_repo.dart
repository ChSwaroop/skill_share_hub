import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/connection_model.dart';

class ConnectionRepo {
  Future<Connection> getMyConnections(
      String status, int page, int limit, String token) async {
    final response = await http.get(
      Uri.parse(
          '${baseUrl}/api/connections?status=$status&page=$page&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      debugPrint("$status connections: " + response.body);
      return Connection.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load connections');
    }
  }

  Future<dynamic> updateConnectionStatus(
      String connectionId, String status, String token) async {
    final response = await http.put(
      Uri.parse('${baseUrl}/api/connections/$connectionId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint(
          "Error while updating the status of a connections: " + response.body);
      throw Exception('Failed to update connection status');
    }
  }

  Future<dynamic> createConnection(
      String recipientId, String connectionNotes, String token) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/api/connections'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'recipientId': recipientId,
        'connectionNotes': connectionNotes,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create connection request');
    }
  }

  Future<dynamic> deleteConnection(String connectionId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}/api/connections/$connectionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Connection removed");
        return json.decode(response.body);
      } else {
        debugPrint("Exception in removing in the connection: " + response.body);
        throw Exception('Failed to delete connection');
      }
    } catch (e) {
      debugPrint("Exception in removing in the connection: " + e.toString());
      throw Exception('Failed to delete connection');
    }
  }
}
