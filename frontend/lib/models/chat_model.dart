// models/chat.dart
import 'package:flutter/material.dart';
import 'package:skill_share_hub/models/login_model.dart';
import 'package:skill_share_hub/models/message_model.dart';

class Chat {
  final String id;
  final String chatType;
  final List<User> participants;
  final String? name;
  final String? createdBy;
  final List<String> admins;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.chatType,
    required this.participants,
    this.name,
    this.createdBy,
    required this.admins,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      chatType: json['chatType'],
      participants: (json['participants'] as List)
          .map((participant) => User.fromJson(participant))
          .toList(),
      name: json['name'],
      createdBy: json['createdBy'],
      admins: List<String>.from(json['admins'] ?? []),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String getChatName(String currentUserId) {
    if (chatType == 'group') {
      return name ?? 'Group Chat';
    } else {
      // For direct chats, return the other participant's name
      final otherParticipant = participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.username!;
    }
  }

  String getChatImage(String currentUserId) {
    if (chatType == 'group') {
      return 'https://img.freepik.com/premium-vector/radial-family-hub-central-connection-design_1069666-4776.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid&w=740'; // Default group image
    } else {
      // For direct chats, return the other participant's profile picture
      final otherParticipant = participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
      if (otherParticipant.profilePicture == null ||
          otherParticipant.profilePicture!.isEmpty) {
        debugPrint(
            "other participants gender: " + (otherParticipant.gender ?? ''));
        if (otherParticipant.gender != "Male") {
          return 'https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid';
        } else {
          return 'https://img.freepik.com/premium-vector/career-woman-employee-ai-generated-image_362642-3848.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid';
        }
      }
      return otherParticipant.profilePicture!;
    }
  }
}
