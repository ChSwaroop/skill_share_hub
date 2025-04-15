import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skill_share_hub/models/todo_model.dart';

class TodoRepository {
  final String baseUrl;
  final Map<String, String> headers;

  TodoRepository({
    required this.baseUrl,
    required String token,
  }) : headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

  // Get all todos
  Future<Todo> getTodos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return todoFromJson(response.body);
    } else {
      throw Exception('Failed to load todos: ${response.body}');
    }
  }

  // Get a single todo
  Future<Datum> getTodo(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Datum.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load todo: ${response.body}');
    }
  }

  // Get todo count
  Future<int?> getTodoCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos/count'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['count'];
    } else {
      throw Exception('Failed to load todo: ${response.body}');
    }
  }

  // Create a new todo
  Future<Datum> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final Map<String, dynamic> data = {
      'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return Datum.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to create todo: ${response.body}');
    }
  }

  // Update a todo
  Future<Datum> updateTodo({
    required String id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
  }) async {
    final Map<String, dynamic> data = {};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (completed != null) data['completed'] = completed;
    if (dueDate != null) data['dueDate'] = dueDate.toIso8601String();

    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Datum.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to update todo: ${response.body}');
    }
  }

  // Mark a todo as completed
  Future<Datum> completeTodo(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id/complete'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // debugPrint("TODO completion: " + jsonResponse.body);
      return Datum.fromJson(jsonResponse['data']);
    } else {
      debugPrint("TODO completion: " + response.body);
      throw Exception('Failed to complete todo: ${response.body}');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo: ${response.body}');
    }
  }
}
