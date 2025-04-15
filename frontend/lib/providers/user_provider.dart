import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:skill_share_hub/models/login_model.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';

class UserProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  User? _user;
  List<User> _connectedUsers = [];
  int _connectionsCount = 0;

  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _token != null;
  List<User> get connectedUsers => _connectedUsers;
  int get connectionsCount => _connectionsCount;

  //Method to get connections count
  Future<void> getConnectionsCount() async {
    final response = await ConnectionRepo().getConnectionsCount(_token!);
    _connectionsCount = response ?? 0;
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'auth_token', value: token);
    notifyListeners();
  }

  Future<void> loadUser() async {
    String? storedUser = await _storage.read(key: 'user_details');
    if (storedUser != null) {
      _user = User.fromJson(json.decode(storedUser));
      notifyListeners();
    }
  }

  Future<void> setUser(User user) async {
    _user = user;
    String userJson = json.encode(user.toJson());
    await _storage.write(key: 'user_details', value: userJson);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _connectedUsers = [];
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_details');
    await _storage.delete(key: 'connected_users');
    notifyListeners();
  }

  Future<void> loadConnectedUsers() async {
    String? storedUsers = await _storage.read(key: 'connected_users');
    if (storedUsers != null) {
      List<dynamic> userJsonList = json.decode(storedUsers);
      _connectedUsers =
          userJsonList.map((userJson) => User.fromJson(userJson)).toList();
      notifyListeners();
    }
  }

  Future<void> setConnectedUsers(List<User> users) async {
    _connectedUsers = users;
    String usersJson = json.encode(users.map((user) => user.toJson()).toList());
    await _storage.write(key: 'connected_users', value: usersJson);
    notifyListeners();
  }

  Future<void> addConnectedUser(User user) async {
    if (!_connectedUsers.any((existingUser) => existingUser.id == user.id)) {
      _connectedUsers.add(user);
      await setConnectedUsers(_connectedUsers);
    }
  }

  Future<void> removeConnectedUser(String userId) async {
    _connectedUsers.removeWhere((user) => user.id == userId);
    await setConnectedUsers(_connectedUsers);
  }
}
