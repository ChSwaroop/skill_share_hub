// models/chat.dart
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
      return 'assets/images/group.png'; // Default group image
    } else {
      // For direct chats, return the other participant's profile picture
      final otherParticipant = participants.firstWhere(
        (user) => user.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.profilePicture!;
    }
  }
}
